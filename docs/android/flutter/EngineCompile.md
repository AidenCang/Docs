# Flutter Engine 编译构建


## 介绍
在前面[编译环境安装](../flutterenv)，[GNTools工具原理](../GNTools),[Ninja编译工具原理](../NinjaSystem)的理解,已经了解了Flutter Engine相关的一下概念，接下来，继续分析执行编译命令调用的命令，文件，和相关的逻辑，有与篇幅问题，只介绍相关的这些逻辑和构建的文件说明(纸上得来终觉浅,....)，整个思维架构打通了之后，剩下的就是时间问题，这个可以克服。。。。。。。


## 准备工作

在开始分析`GN`是怎么产生`Ninja`配置文件的流程，需要对一下的内容有一个加单的了解
!!! info "优点"

    * 1.可读性好
    * 2.速度更快
    * 3.修改gn 之后 构建ninja文件时候会自动更新
    * 4.依赖分明


!!! info "两种文件类型"

    * BUILID.gn : 采用层级结构 文件根目录下通常有一个BUILD.gn文件，该文件是所有的代码模块组装的集合
    * .gni :一般用来添加一些参数的配置，在gn文件中import这些文件或者里面定义的变量参数值


[GNTools](../GNTools) 是一款构建系统，用于编译大规模代码生成ninja文件

[Ninja](https://ninja-build.org/)源代码分析、优化、编译系统

[Flutter Engine Complie](https://github.com/flutter/flutter/wiki/Compiling-the-engine) Engine编译官方教程

## 预处理编译文件

使用不同的参数指定我们准备要构建的flutter引擎支持的平台(Windows,Linux,Mac,Android,IOS,Web,Embedder)，在同一个平台上支持不同的模式(debug,release,profile),接下来我们怎么玩这个系统在不同平台上的支持库，和同一平台上的不同模式

!!! info "预处理编译文件不同平台的编译脚本"

    * ./flutter/tools/gn --android --unoptimized for device-side executables.
    * ./flutter/tools/gn --android --android-cpu x86 --unoptimized for x86 emulators.
    * ./flutter/tools/gn --android --android-cpu x64 --unoptimized for x64 emulators.
    * ./flutter/tools/gn --unoptimized for host-side executables, needed to compile the code.
    * ./flutter/tools/gn --ios --unoptimized
    * ./flutter/tools/gn --ios --simulator --unoptimized
    * ./flutter/tools/gn --unoptimized
    * python .\flutter\tools\gn --unoptimized
    * web编译[felt工具](https://github.com/flutter/engine/blob/master/lib/web_ui/dev/README.md)


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

通过调用下面的命令查找当前目录下的`.ng`文件开始分析整个源码项目的依赖树

```shell
command = [
    '%s/buildtools/%s/gn' % (SRC_ROOT, subdir),
    'gen',
    '--check',
  ]
```

## .gn文件的查找过程
在引擎的目录下`engine/src`查找入口的`.gn`文件,使用`src/tools/gn`工具查找根目录树下的源文件树和开始配置数据

```shell
# The location of the build configuration file.
buildconfig = "//build/config/BUILDCONFIG.gn"

# The secondary source root is a parallel directory tree where
# GN build files are placed when they can not be placed directly
# in the source tree, e.g. for third party source trees.
secondary_source = "//build/secondary/"

# The set of targets known to pass 'gn check'. When all targets pass, remove
# this.
check_targets = [
  "//dart/*",
  "//flow/*",
  "//flutter/*",
  "//glue/*",
  "//mojo/*",
  "//skia/*",
  "//sky/*",
]
```
[1] 处使用打印命令输出这些构建命令生成的参数类型,通过查看生成的命令行参数，就能够理解在[Flutter Engine 编译模式](../ComplieMode)提到的不同模式，是怎么组织代码和相关的编译文件相关的内容，基本的思路和框架理解了之后，接下来就是`GN`工具调用`BUILD.gn`相关的文件，提供给Ninja去编译的文件
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

## 如何配置`OS`,`CPU`,`编译工具链`
在`engine/src/build/config/BUILDCONFIG.gn`文件中主要配置内容:

* 1. 指定Flutter源码目录
* 2. 指定平台架构
* 3. 指定一些构建标识
* 4. 指定系统(Window,Mac,Linux,Android,ios)
* 5. 指定工具链的使用
* 6. 第三方开源库的使用

### 指定flutter的根目录

```Shell
# Set the root of the engine project.
flutter_root = "//flutter"
```


### 指定平台

使用的变量

    - host_os, host_cpu, host_toolchain
    - target_os, target_cpu, default_toolchain
    - current_os, current_cpu, current_toolchain.

### build Flag

```shell
declare_args() {
  # How many symbols to include in the build. This affects the performance of
  # the build since the symbols are large and dealing with them is slow.
  #   2 means regular build with symbols.
  #   1 means minimal symbols, usually enough for backtraces only.
  #   0 means no symbols.
  #   -1 means auto-set (off in release, regular in debug).
  symbol_level = -1

  # Component build.
  is_component_build = false

  # Official build.
  is_official_build = false

  # Debug build.
  is_debug = true

  # Whether we're a traditional desktop unix.
  is_desktop_linux = current_os == "linux" && current_os != "chromeos"

  # Set to true when compiling with the Clang compiler. Typically this is used
  # to configure warnings.
  is_clang = current_os == "mac" || current_os == "ios" ||
             current_os == "linux" || current_os == "chromeos"

  # Compile for Address Sanitizer to find memory bugs.
  is_asan = false

  # Compile for Leak Sanitizer to find leaks.
  is_lsan = false

  # Compile for Memory Sanitizer to find uninitialized reads.
  is_msan = false

  # Compile for Thread Sanitizer to find threading bugs.
  is_tsan = false

  # Compile for Undefined Behavior Sanitizer.
  is_ubsan = false

  if (current_os == "chromeos") {
    # Allows the target toolchain to be injected as arguments. This is needed
    # to support the CrOS build system which supports per-build-configuration
    # toolchains.
    cros_use_custom_toolchain = false
  }

  # DON'T ADD MORE FLAGS HERE. Read the comment above.
}
```

### 指定平台
Windows,Linux,Mac,Android,IOS,Web,embedder

```shell
f (current_os == "mac") {
  is_android = false
  is_chromeos = false
  is_fuchsia = false
  is_fuchsia_host = false
  is_ios = false
  is_linux = false
  is_mac = true
  is_posix = true
  is_win = false
} else if (current_os == "android") {
  is_android = true
  is_chromeos = false
  is_fuchsia = false
  is_fuchsia_host = false
  is_ios = false
  is_linux = false
  is_mac = false
  is_posix = true
  is_win = false
}
............

```

### 工具链设置

```shell
import("//build/toolchain/custom/custom.gni")

# Define this to allow Fuchsia's fork of harfbuzz to build.
# shlib_toolchain is a Fuchsia-specific symbol and not used by Flutter.
shlib_toolchain = false

if (custom_toolchain != "") {
  assert(custom_sysroot != "")
  assert(custom_target_triple != "")
  host_toolchain = "//build/toolchain/linux:clang_$host_cpu"
  set_default_toolchain("//build/toolchain/custom")
} else if (is_win) {
  # On windows we use the same toolchain for host and target by default.
  host_toolchain = "//build/toolchain/win:$current_cpu"
  set_default_toolchain("$host_toolchain")
} else if (is_android) {
  if (host_os == "linux") {
    # Use clang for the x86/64 Linux host builds.
    if (host_cpu == "x86" || host_cpu == "x64") {
      host_toolchain = "//build/toolchain/linux:clang_$host_cpu"
    } else {
      host_toolchain = "//build/toolchain/linux:$host_cpu"
    }
  } else if (host_os == "mac") {
    host_toolchain = "//build/toolchain/mac:clang_$host_cpu"
  } else if (host_os == "win") {
    host_toolchain = "//build/toolchain/win:$current_cpu"
  } else {
    assert(false, "Unknown host for android cross compile")
  }
  if (is_clang) {
    set_default_toolchain("//build/toolchain/android:clang_$current_cpu")
  } else {
    set_default_toolchain("//build/toolchain/android:$current_cpu")
  }
} else if (is_linux) {
  if (is_clang) {
    host_toolchain = "//build/toolchain/linux:clang_$host_cpu"
    set_default_toolchain("//build/toolchain/linux:clang_$current_cpu")
  } else {
    host_toolchain = "//build/toolchain/linux:$host_cpu"
    set_default_toolchain("//build/toolchain/linux:$current_cpu")
  }
  if (is_chromeos && cros_use_custom_toolchain) {
    set_default_toolchain("//build/toolchain/cros:target")
  }
} else if (is_mac) {
  host_toolchain = "//build/toolchain/mac:clang_x64"
  set_default_toolchain(host_toolchain)
} else if (is_ios) {
  import("//build/config/ios/ios_sdk.gni")  # For use_ios_simulator
  host_toolchain = "//build/toolchain/mac:clang_$host_cpu"
  if (use_ios_simulator) {
    set_default_toolchain("//build/toolchain/mac:ios_clang_x64")
  } else {
    set_default_toolchain("//build/toolchain/mac:ios_clang_arm")
  }
} else if (is_fuchsia) {
  if (host_os == "mac") {
    host_toolchain = "//build/toolchain/mac:clang_$host_cpu"
  } else {
    host_toolchain = "//build/toolchain/linux:clang_$host_cpu"
  }
  set_default_toolchain("//build/toolchain/fuchsia")
} else {
  assert(false, "Toolchain not set because of unknown platform.")
}

# Sets default dependencies for executable and shared_library targets.
#
# Variables
#   no_default_deps: If true, no standard dependencies will be added.
if (is_android || (is_linux && current_cpu != "x86")) {
  foreach(_target_type,
          [
            "executable",
            "loadable_module",
            "shared_library",
          ]) {
    template(_target_type) {
      target(_target_type, target_name) {
        forward_variables_from(invoker, "*", [ "no_default_deps" ])
        if (!defined(deps)) {
          deps = []
        }
        if (!defined(invoker.no_default_deps) || !invoker.no_default_deps) {
          deps += [ "//third_party/libcxx" ]
        }
      }
    }
  }
}

```

### COMPONENT 配置
指定需要依赖的共享库和源文件目录，所有的依赖配置文件顶层文件目录
`//build/config/sanitizers:deps`

`//build/config/sanitizers:deps`

```shell

if (is_component_build) {
  component_mode = "shared_library"
} else {
  component_mode = "source_set"
}


if (defined(invoker.deps)) {
  deps = invoker.deps + [ "//build/config/sanitizers:deps" ]
} else {
  deps = [
    "//build/config/sanitizers:deps",
  ]
}

....engine/src/build/config/sanitizers/BUILD.gn 指定第三方库的依赖....

# Contains the dependencies needed for sanitizers to link into executables and
# shared_libraries. Unconditionally depend upon this target as it is empty if
# |is_asan|, |is_lsan|, |is_tsan|, |is_msan| and |use_custom_libcxx| are false.
group("deps") {
  deps = [
    "//third_party/instrumented_libraries:deps",
  ]
  if (is_asan || is_lsan || is_tsan || is_msan) {
    public_configs = [ ":sanitizer_options_link_helper" ]
    deps += [ ":options_sources" ]
  }
  if (use_custom_libcxx) {
    deps += [ "//buildtools/third_party/libc++:libcxx_proxy" ]
  }
}
```
### 使用gn命令和参数之后生成编译清单文件

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

编译完成之后，我们来了解一下目录的内容,详细的编译文件的内容，我们在下一篇中在进行详细说明

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
记录编译的相关连文件的时间戳来跟踪源代码的变化信息

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

该文件中记录了`GN`文件保存的构建文件的路径,在GN完成之后生成的文件依赖路径中的文件可以在文件中找到，这个文件记录了编译是的所有文件会从这些文件的路径中注意查找

```Shell
build.ninja: ../../BUILD.gn
../../build/compiled_action.gni
../../build/config/BUILD.gn
.........
../../third_party/tonic/scopes/BUILD.gn
../../third_party/tonic/typed_data/BUILD.gn
../../third_party/zlib/BUILD.gn
```


## 总结

我们分析了使用`GN`工具对相关的源文件和配置参数进行设置，不同平台版本，统一平台的不同模式的编译依赖文件有所不同，最终最在out目录中生成给`ninja`编译器需要的配置文件，通过源文件的学习，我们更能够理解FlutterEngine目录下的源代码的目录结构和使用到的内容依赖，配置参数和生成的清单文件，接下了就需要学习如何使用编译命令和参数，以及生成的文件包含哪些内容，我们将通过下一篇的学习来读Flutter编译产物和作用有一个更加深入的了解。

## 执行编译命令
[NinjaComplie](https://ninja-build.org/manual.html#_using_ninja_for_your_project)
`ninja -C out/android_debug_unopt_x86`开始编译`android_debug_unopt_x86`目录下`GN`生成的构建文件关联的源文件,读取`android_debug_unopt_x86`目录下的`engine/src/out/android_debug_unopt_x86/build.ninja`从该文件开始查找
