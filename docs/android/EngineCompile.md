# Flutter Engine 编译


## 介绍
通过上一篇文件的介绍，已经了解了Flutter Engine相关的一下概念，接下来，继续分析执行编译命令调用的命令，文件，和相关的逻辑，有与篇幅问题，只介绍相关的这些逻辑和构建的文件说明(纸上得来终觉浅,....)，整个思维架构打通了之后，剩下的就是时间问题，这个可以克服。。。。。。。

[GNTools](../GNTools) 是一款构建系统，用于编译大规模代码生成ninja文件
[Ninja](https://ninja-build.org/)
[Flutter Engine Complie](https://github.com/flutter/flutter/wiki/Compiling-the-engine)
!!! info "优点"

    * 1.可读性好
    * 2.速度更快
    * 3.修改gn 之后 构建ninja文件时候会自动更新
    * 4.依赖分明


!!! info "两种文件类型"

    * BUILID.gn
    * .gni

经过几天的摸索发现这种构建系统非常有层次性，通常每个模块可以单独写一个gn文件，但是一般采用层级结构
文件根目录下通常有一个BUILD.gn文件，该文件是所有的代码模块组装的集合

.gni 文件：一般用来添加一些参数的配置，在gn文件中import这些文件或者里面定义的变量参数值

本文描述了许多GN的语法细节和行为。


## 预处理编译文件

!!! info "预处理编译文件"

    * ./flutter/tools/gn --android --unoptimized for device-side executables.
    * ./flutter/tools/gn --android --android-cpu x86 --unoptimized for x86 emulators.
    * ./flutter/tools/gn --android --android-cpu x64 --unoptimized for x64 emulators.
    * ./flutter/tools/gn --unoptimized for host-side executables, needed to compile the code.


通过这些上述的命令，跟踪命令的执行过程:`./flutter/tools/gn --android --unoptimized`，参加[Flutter Engine 编译模式](../ComplieMode)

* `flutter/tools/gn` python脚本下列代码
* `--android` 指定平台
* `--android-cpu x86` cpu架构
* `--unoptimized` 是否需要优化

执行下列脚本主要是在构建`GN`构建脚本参数:

```Python

SRC_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
/* 根据传入的参数判断平台的输出路径 */
def get_out_dir(args):
    if args.target_os is not None:
        target_dir = [args.target_os]
    else:
        target_dir = ['host']
    ........
    return os.path.join(args.out_dir, 'out', '_'.join(target_dir))

def to_command_line(gn_args):
    def merge(key, value):
        if type(value) is bool:
            return '%s=%s' % (key, 'true' if value else 'false')
        return '%s="%s"' % (key, value)
    return [merge(x, y) for x, y in gn_args.iteritems()]

def cpu_for_target_arch(arch):
  if arch in ['ia32', 'arm', 'armv6', 'armv5te', 'mips',
              'simarm', 'simarmv6', 'simarmv5te', 'simmips', 'simdbc',
              'armsimdbc']:
    return 'x86'
  if arch in ['x64', 'arm64', 'simarm64', 'simdbc64', 'armsimdbc64']:
    return 'x64'

def to_gn_args(args):
    gn_args = {}

    # Skia GN args.
    gn_args['skia_enable_flutter_defines'] = True # Enable Flutter API guards in Skia.
    gn_args['skia_use_dng_sdk'] = False    # RAW image handling.
    gn_args['skia_use_sfntly'] = False     # PDF handling depedency.
  ...............

    return gn_args

def parse_args(args):
  args = args[1:]
  parser = argparse.ArgumentParser(description='A script run` gn gen`.')

  parser.add_argument('--unoptimized', default=False, action='store_true')

  parser.add_argument('--runtime-mode', type=str, choices=['debug', 'profile', 'release'], default='debug')
..........
  return parser.parse_args(args)

def main(argv):
  args = parse_args(argv)

  if sys.platform.startswith(('cygwin', 'win')):
    subdir = 'win'
  elif sys.platform == 'darwin':
    subdir = 'mac-x64'
  elif sys.platform.startswith('linux'):
     subdir = 'linux-x64'
  else:
    raise Error('Unknown platform: ' + sys.platform)

  command = [
    '%s/buildtools/%s/gn' % (SRC_ROOT, subdir),
    'gen',
    '--check',
  ]

  if sys.platform == 'darwin':
    # On the Mac, also generate Xcode projects for ease of editing.
    command.append('--ide=xcode')

  if sys.platform.startswith('win'):
    # On Windows, also generate Visual Studio project for ease of editing.
    command.append('--ide=vs')

  gn_args = to_command_line(to_gn_args(args))
  out_dir = get_out_dir(args)
  print "gn gen --check in %s" % out_dir
  command.append(out_dir)
  command.append('--args=%s' % ' '.join(gn_args))
  gn_call_result = subprocess.call(command, cwd=SRC_ROOT)
  print command [1]

  if gn_call_result == 0:
    # Generate/Replace the compile commands database in out.
    compile_cmd_gen_cmd = [
      'ninja',
      '-C',
      out_dir,
      '-t',
      'compdb',
      'cc',
      'cxx',
      'objc',
      'objcxx',
      'asm',
    ]
    print  compile_cmd_gen_cmd [2]
    调用`GN`生成构建文件

    contents = subprocess.check_output(compile_cmd_gen_cmd, cwd=SRC_ROOT)
    compile_commands = open('%s/out/compile_commands.json' % SRC_ROOT, 'w+')
    compile_commands.write(contents)
    compile_commands.close()

  return gn_call_result

if __name__ == '__main__':
    sys.exit(main(sys.argv))
```
## 生成的GN命令参数

`./flutter/tools/gn --android --unoptimized`

[1] 处使用打印命令输出这些构建命令生成的参数类型,通过查看生成的命令行参数，就能够理解在[Flutter Engine 编译模式](../ComplieMode)提到的不同模式，是怎么组织代码和相关的编译文件相关的内容，基本的思路和框架理解了之后，接下来就是`GN`工具调用`BUILD.gn`相关的文件，提供给Ninja去编译的文件

```Gson

['buildtools/mac-x64/gn', 'gen', '--check', '--ide=xcode',
'out/android_debug_unopt', '--args=skia_enable_pdf=false enable_lto=false
use_clang_static_analyzer=false
full_dart_sdk=false
dart_runtime_mode="develop"
skia_use_fontconfig=false
skia_use_dng_sdk=false
skia_enable_flutter_defines=true
use_goma=false
dart_custom_version_for_pub="flutter"
embedder_for_target=false
is_official_build=true
host_cpu="x86" # 编译主机架构
is_clang=true
skia_use_sfntly=false
 dart_target_arch="arm"
flutter_runtime_mode="debug"
goma_dir="None"
android_full_debug=true
target_os="android"  # 生成的目标平台
mac_sdk_path=""
skia_use_x11=false
enable_coverage=false
target_cpu="arm"  # 目标cpu架构
skia_use_expat=true
dart_lib_export_symbols=false
is_debug=true  # debug模式
flutter_aot=false' # 不需要优化
]

```
[2] 处构建的命令

```Gson

['ninja', '-C', 'out/android_debug_unopt', '-t', 'compdb', 'cc', 'cxx', 'objc', 'objcxx', 'asm']
```

在[1]构建的命令中指定使用的`GN`路径`'buildtools/mac-x64/gn'`接着会调用执行`/engine/src# ./flutter/tools/gn`的Build.gn文件`engine/src/BUILD.gn`,会根据当前目录中的`BUILD.gn`文件配置一层一层的目录去查找指定的目录中的`BUILD.gn`,文件每一个目录中都会定义当前目录编译的规则和依赖参数，所以可以理解为一颗倒挂的树：从叶子结点开始配置，配置父节点，如果需要添加新的功能模块，就在上一级模块中把下一级的`BUILD.gn`文件引用就能够向下包含需要的文件依赖。最终生成`ninja`的配置文件。

```Shell
/* This target will be built if no target is specified when invoking ninja. */
group("default") {
  testonly = true
  deps = [
    "//flutter",
  ]
}
group("dist") {
  testonly = true
  deps = [
    "//flutter:dist",
  ]
}
```
接着进入 `//Flutter`目录查找`# Copyright 2013 The Flutter Authors. All rights reserved.
```Shell

import("$flutter_root/common/config.gni")
import("//third_party/dart/build/dart/dart_action.gni")

<!-- # Temporary snapshot copy rules until we can use the full SDK. -->
_flutter_sdk_snapshots = [
  [
    "dart2js",
    "//third_party/dart/utils/compiler:dart2js",
  ],
  [
    "kernel_worker",
    "//third_party/dart/utils/bazel:kernel_worker",
  ],
]

group("flutter") {
  testonly = true

  public_deps = [
    "$flutter_root/lib/snapshot:generate_snapshot_bin",
    "$flutter_root/lib/snapshot:kernel_platform_files",
    "$flutter_root/shell/platform/embedder:flutter_engine",
    "$flutter_root/sky",
  ]

  if (current_toolchain == host_toolchain) {
    public_deps += [ "$flutter_root/shell/testing" ]
  }

  if (!is_fuchsia && !is_fuchsia_host) {
    if (current_toolchain == host_toolchain) {
      public_deps += [
        "$flutter_root/frontend_server",
        "//third_party/dart:create_sdk",
        "$flutter_root/lib/stub_ui:stub_ui",
        ":dart2js_platform_files",
        ":flutter_dartdevc_kernel_sdk",
      ]
      foreach(snapshot, _flutter_sdk_snapshots) {
        public_deps += [ ":copy_flutter_${snapshot[0]}_snapshot" ]
      }
    }
  }

  <!-- # If on the host, compile all unittests targets. -->
  if (current_toolchain == host_toolchain) {
    if (is_mac) {
      public_deps +=
          [ "$flutter_root/shell/platform/darwin:flutter_channels_unittests" ]
    }

    public_deps += [
      "$flutter_root/flow:flow_unittests",
      "$flutter_root/fml:fml_unittests",
      "$flutter_root/runtime:runtime_unittests",
      "$flutter_root/shell/common:shell_unittests",
      "$flutter_root/shell/platform/embedder:embedder_unittests",
      "$flutter_root/shell/platform/embedder:embedder_a11y_unittests", # TODO(cbracken) build these into a different kernel blob in the embedder tests and load that in a test in embedder_unittests
      "$flutter_root/synchronization:synchronization_unittests",
      "$flutter_root/third_party/txt:txt_unittests",
    ]

    if (!is_win) {
      public_deps += [ "$flutter_root/shell/common:shell_benchmarks" ]
    }
  }
}

config("config") {
  include_dirs = [ ".." ]
}

group("dist") {
  testonly = true

  deps = [
    "$flutter_root/sky/dist",
  ]
}

foreach(snapshot, _flutter_sdk_snapshots) {
  copy("copy_flutter_${snapshot[0]}_snapshot") {
    deps = [
      snapshot[1],
    ]
    sources = [
      "$root_gen_dir/${snapshot[0]}.dart.snapshot",
    ]
    outputs = [
      "$root_out_dir/dart-sdk/bin/snapshots/flutter_{{source_file_part}}",
    ]
  }
}

copy("dart2js_platform_files") {
  deps = [
    "//third_party/dart/utils/compiler:compile_dart2js_platform"
  ]

  sources = [
    "$root_out_dir/dart2js_outline.dill",
    "$root_out_dir/dart2js_platform.dill",
  ]

  outputs = [
    "$root_out_dir/flutter_patched_sdk/{{source_file_part}}",
  ]
}


prebuilt_dart_action("flutter_dartdevc_kernel_sdk") {
  deps = [
     "//third_party/dart:create_sdk",
  ]

  packages = "//third_party/dart/.packages"

  script = "//third_party/dart/pkg/dev_compiler/tool/kernel_sdk.dart"

  inputs = [
    "//third_party/dart/pkg/dev_compiler/tool/kernel_sdk.dart",
  ]

  outputs = [
    "$target_gen_dir/kernel/amd/dart_sdk.js",
    "$target_gen_dir/kernel/amd/dart_sdk.js.map",
    "$target_gen_dir/kernel/common/dart_sdk.js",
    "$target_gen_dir/kernel/common/dart_sdk.js.map",
    "$target_gen_dir/kernel/es6/dart_sdk.js",
    "$target_gen_dir/kernel/es6/dart_sdk.js.map",
    "$target_gen_dir/kernel/legacy/dart_sdk.js",
    "$target_gen_dir/kernel/legacy/dart_sdk.js.map",
  ]

  libraries_path = rebase_path("$flutter_root/lib/snapshot/libraries.json")
  output_path = rebase_path("$target_gen_dir/kernel/flutter_ddc_sdk.dill")

  args = [
    "--output=$output_path",
    "--libraries=$libraries_path",
  ]
}
```
## ninja配置文件

通过`GN`工具生成配置文件之后会在`out`目录中生成相关的`Ninja`配置文件

!!! info "GN产生的文件说明"

    * args.gn  # 使用`GN`工具构建是生成的配置参数，可以验证配置参数是否正确
    * build.ninja # Ninja 配置文件，也是默认的编译脚本
    * build.ninja.d # GN 产生构建文件查找的文件路径

```Shell
➜  android_debug_unopt_x86 git:(master) ✗ tree -L 3
.
├── all.xcworkspace
│   └── contents.xcworkspacedata
├── args.gn  # 使用`GN`工具构建是生成的配置参数，可以验证配置参数是否正确
├── build.ninja # Ninja 配置文件，也是默认的编译脚本
├── build.ninja.d # GN 产生构建文件查找的文件路径
├── clang_x64
│   ├── obj
│   │   └── third_party
│   └── toolchain.ninja
├── clang_x86
│   ├── obj
│   │   └── third_party
│   └── toolchain.ninja
├── dart-sdk
│   └── bin
│       └── snapshots
├── gyp-mac-tool
├── obj
│   ├── flutter
│   │   ├── assets
│   │   ├── benchmarking
│   │   ├── common
│   │   ├── flow
│   │   ├── fml
│   │   ├── lib
│   │   ├── runtime
│   │   ├── shell
│   │   ├── synchronization
│   │   ├── testing
│   │   ├── third_party
│   │   └── vulkan
│   └── third_party
│       ├── android_tools
│       ├── benchmark
│       ├── boringssl
│       ├── cpu-features
│       ├── dart
│       ├── expat
│       ├── freetype2
│       ├── googletest
│       ├── harfbuzz
│       ├── icu
│       ├── libcxx
│       ├── libcxxabi
│       ├── libjpeg-turbo
│       ├── libpng
│       ├── libwebp
│       ├── rapidjson
│       ├── skia
│       ├── tonic
│       └── zlib
├── products.xcodeproj
│   └── project.pbxproj
└── toolchain.ninja

45 directories, 9 files
```

## args.gn

```Shell
skia_enable_pdf = false
enable_lto = false
use_clang_static_analyzer = false
full_dart_sdk = false
dart_runtime_mode = "develop"
skia_use_fontconfig = false
skia_use_dng_sdk = false
skia_enable_flutter_defines = true
use_goma = false
dart_custom_version_for_pub = "flutter"
embedder_for_target = false
is_official_build = true
host_cpu = "x86"
is_clang = true
skia_use_sfntly = false
dart_target_arch = "x86"
flutter_runtime_mode = "debug"
goma_dir = "None"
android_full_debug = true
target_os = "android"
mac_sdk_path = ""
skia_use_x11 = false
enable_coverage = false
target_cpu = "x86"
skia_use_expat = true
dart_lib_export_symbols = false
is_debug = true
flutter_aot = false

```

## build.ninja

```Shell
ninja_required_version = 1.7.2

rule gn
  command = ../../buildtools/mac-x64/gn --root=../.. -q --check --ide=xcode gen .
  description = Regenerating ninja files

build build.ninja: gn
  generator = 1
  depfile = build.ninja.d

subninja toolchain.ninja
subninja clang_x64/toolchain.ninja
subninja clang_x86/toolchain.ninja

build default: phony obj/default.stamp
build dist: phony obj/dist.stamp
build flutter: phony obj/flutter/flutter.stamp
build _http: phony obj/flutter/sky/packages/sky_engine/_http.stamp
build android: phony obj/flutter/shell/platform/android/android.stamp
build android_arch_lifecycle_common: phony obj/flutter/shell/platform/android/android_arch_lifecycle_common.stamp

build all: phony $
    obj/default.stamp $
    obj/dist.stamp $
    ...........
    obj/third_party/zlib/libzlib_x86_simd.a

default default

```

## build.ninja.d

该文件中记录了`GN`文件保存的构建文件的路径，

```Shell
build.ninja:
../../BUILD.gn
../../build/compiled_action.gni
../../build/config/BUILD.gn
./args.gn dart-sdk/bin/snapshots/resources/dartdoc/.packages
..........
../../third_party/zlib/BUILD.gn
```
## 执行编译命令
[NinjaComplie](https://ninja-build.org/manual.html#_using_ninja_for_your_project)
`ninja -C out/android_debug_unopt_x86`开始编译`android_debug_unopt_x86`目录下`GN`生成的构建文件关联的源文件,读取`android_debug_unopt_x86`目录下的`engine/src/out/android_debug_unopt_x86/build.ninja`从该文件开始查找
