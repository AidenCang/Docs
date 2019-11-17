# 下载Flutter engine
flutter 引擎使用depot_tools进行管理,具体的环境配置方法，请参考官方文档中的配置文件，本文中部进行重复的说明，主要梳理下载的流程，避免在下载源代码时出现错误有解决思路。




## 概述

FlutterEngine是托管在Github上的开源库，可以自由下载，下载步骤:

### 查看官方文档进行环境配置

1.相关的环境配置工具可以在官方链接文档中找到[环境设置](https://github.com/flutter/flutter/wiki/Setting-up-the-Engine-development-environment)

2.项目仓库管理工具 [depot_tools下载配置环境](http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)

### gclient sync 的执行过程

1.下载`git@github.com:<your_name_here>/engine.git`代码仓库

2.查找`src/flutter`下的`deps`文件进行依赖文件下载，并行执行相关的Python文件

3.执行`src/tools`下的所有`py`文件，开始查找`src/third_party/dart/DEPS`文件，并执行相关的源码操作

上面三步执行完成之后，所有的源代码已经下载完成，可进行编译操作



## gclient sync 如何执行

flutter是通过`depot_tools`工具进行管理，在官方教程中，我们配置了相关的环境

    touch .gclient 填写下列的地址

      solutions = [
        {
          "managed": False,
          "name": "src/flutter",
          "url": "git@github.com:<your_name_here>/engine.git",
          "custom_deps": {},
          "deps_file": "DEPS",
          "safesync_url": "",
        },
      ]

gclient sync 首先下载`git@github.com:<your_name_here>/engine.git`代码仓库，然后查找，使用`src/flutter中的DEPS`文件进行依赖下载，包括第三方库，下载关联的`git`代码仓库之后，安装`DESP中的`hook文件的配置执行相应的`python`脚本文件,在`src/Flutter/DEPS`文件执行到倒数第二个脚本是执行`src/tools`目录下的所有`Python`文件，接着查找`src/third_party/dart/DEPS`目录下的文件执行相关的依赖下载

下列代码是更新Dart相关的文件调用的，同时会执行`src/third_party/dart/DEPS`

    {
      # Ensure that we don't accidentally reference any .pyc files whose
      # corresponding .py files have already been deleted.
      'name': 'remove_stale_pyc_files',
      'pattern': 'src/tools/.*\\.py',
      'action': [
          'python',
          'src/tools/remove_stale_pyc_files.py',
          'src/tools',
      ],
    },
## gclient sync首先查找

  1. 全局公共的依赖: [Flutter 根目录下的DEPS](https://github.com/AidenCang/engine/blob/master/DEPS)
  2. 不同平台下的Dart 相关的依赖: [Dart依赖](https://github.com/dart-lang/sdk/blob/master/DEPS)
  3. [更新Dart依赖](https://github.com/dart-lang/sdk/wiki/Adding-and-Updating-Dependencies)

## DEPS 包含

vars：指定需要下载的git仓库

deps:依赖的代码库

hooks:下载完成后执行相关脚本(`重点跟踪的过程`)

  1.src/build/landmines.py

  2.src/build/vs_toolchain.py

  3.src/tools/dart/update.py

  4.../../../third_party/dart/tools/sdks/dart-sdk/bin/pub

  5.src/tools/android/android_sdk_downloader/lib/main.dart

  6.src/flutter/tools/android_support/download_android_support.py

  7.src/tools/buildtools/update.py

  8.flutter/tools/generate_package_files.py

  9.src/tools/.*\\.py

  10.download_from_google_storage

## 下载源代码错误处理


```sh
Running hooks:  50% ( 5/10) download_android_tools
________ running 'src/third_party/dart/tools/sdks/dart-sdk/bin/dart --enable-asserts src/tools/android/android_sdk_downloader/lib/main.dart -y --out=src/third_party/android_tools --platform=28 --platform-revision=6 --build-tools-version=28.0.3 --platform-tools-version=28.0.1 --tools-version=26.1.1 --ndk-version=19.1.5304403' in '/Users/cangck/engine'
src/tools/android/android_sdk_downloader/lib/main.dart:1: Warning: Interpreting this as package URI, 'package:android_sdk_downloader/main.dart'.
Downloading Android SDK and NDK artifacts...
SDK Platform 28: 100% SDK Build-Tools 28.0.3: 100% SDK Tools: 100%
Downloads complete.
Unhandled exception:
Bad state: Could not find package matching arguments: Instance of 'OptionsRevision', OSType.mac, null
#0      downloadArchive (package:android_sdk_downloader/src/http.dart:94:5)
<asynchronous suspension>
#1      main (package:android_sdk_downloader/main.dart:159:15)
#2      _RootZone.runUnary (dart:async/zone.dart:1379:54)
#3      _FutureListener.handleValue (dart:async/future_impl.dart:129:18)
#4      Future._propagateToListeners.handleValueCallback (dart:async/future_impl.dart:642:45)
#5      Future._propagateToListeners (dart:async/future_impl.dart:671:32)
#6      Future._complete (dart:async/future_impl.dart:476:7)
#7      _SyncCompleter.complete (dart:async/future_impl.dart:51:12)
#8      _AsyncAwaitCompleter.complete.<anonymous closure> (dart:async/runtime/libasync_patch.dart:33:20)
#9      _microtaskLoop (dart:async/schedule_microtask.dart:41:21)
#10     _startMicrotaskLoop (dart:async/schedule_microtask.dart:50:5)
#11     _runPendingImmediateCallback (dart:isolate/runtime/libisolate_patch.dart:115:13)
#12     _RawReceivePortImpl._handleMessage (dart:isolate/runtime/libisolate_patch.dart:172:5)
Error: Command 'src/third_party/dart/tools/sdks/dart-sdk/bin/dart --enable-asserts src/tools/android/android_sdk_downloader/lib/main.dart -y --out=src/third_party/android_tools --platform=28 --platform-revision=6 --build-tools-version=28.0.3 --platform-tools-version=28.0.1 --tools-version=26.1.1 --ndk-version=19.1.5304403' returned non-zero exit status 255 in /Users/cangck/engine
Hook 'src/third_party/dart/tools/sdks/dart-sdk/bin/dart --enable-asserts src/tools/android/android_sdk_downloader/lib/main.dart -y --out=src/third_party/android_tools --platform=28 --platform-revision=6 --build-tools-version=28.0.3 --platform-tools-version=28.0.1 --tools-version=26.1.1 --ndk-version=19.1.5304403' took 108.58 secs
```

上面的错误时在值得`src/flutter/DEPS`中的文件时，Android的开发版本在配置文件中没有找到

#### 解决方案修改`src/flutter/DEPS`中的版本版本，如何执行`gclient sync`一切下载正常
查看源码目录下的相关文件，可以找到保存的地方`src/tools/android/android_sdk_downloader/lib/main.dart`
```sh
{
  'name': 'download_android_tools',
  'pattern': '.',
  'condition': 'host_os == "mac" or host_os == "linux"',
  'action': [
      'src/third_party/dart/tools/sdks/dart-sdk/bin/dart', # this hook _must_ be run _after_ the dart hook.
      '--enable-asserts',
      'src/tools/android/android_sdk_downloader/lib/main.dart',
      '-y', # Accept licenses
      '--out=src/third_party/android_tools',
      '--platform=28',
      '--platform-revision=6',
      '--build-tools-version=28.0.3',
      '--platform-tools-version=29.0.5',
      '--tools-version=25.2.5',
      '--ndk-version=21.0.5935234'
  ],
},
```
