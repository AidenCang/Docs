# 下载Flutter engine

## 概述


FlutterEngine是托管在Github上的开源库，可以自由下载:

Flutter Engine是Google开发的源代码工程，托管在[Github](https://github.com/flutter/flutter)上源代码工程，flutter 引擎使用depot_tools进行管理,具体的环境配置方法，请参考官方文档中的配置文件，本文中不进行重复的说明，主要梳理下载的流程，避免在下载源代码时出现错误有解决思路。


`depot_tools`是Google专门为开发大项目开发的`.git`代码仓库管理的`python`脚本，统一管理整个源码仓库的所有依赖

开始下载编译源码我们需要掌握的一些内容框架,先搞清楚整个编译需要的原材料，针对性的一个一个突破

1.配置Git仓库，clone FlutterEngine的源代码到自己的github账号下

2.下载[depot_tools](http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)源代码依赖工具，通过配置文件找到自己`Github`代码仓库的地址，查找依赖文件`DEPS`

3.gclient生成整个源代码的依赖文件 [gclient](http://code.google.com/p/chromium/wiki/UsingGit)

      1.flutterEngine 根目录下的`DEPS`文件
      2.`engine/src/flutter/DEPS`目录下的依赖文件
      3.`engine/src/third_party/dart/DEPS`目录下的依赖文件,[添加Dart依赖到源码仓库](https://github.com/dart-lang/sdk/wiki/Adding-and-Updating-Dependencies)

## 核心内容

1.如何配置gclient

2.gclient的执行过程

3.`DEPS`相关的依赖文件调用过程

4.如果提交本地修改


## 查看官方文档进行环境配置


1.C++编译工具

2.git代码管理工具

3.代码下载工具

详细的过程参考官方的配置文档

1.相关的环境配置工具可以在官方链接文档中找到[环境设置](https://github.com/flutter/flutter/wiki/Setting-up-the-Engine-development-environment)

2.项目仓库管理工具 [depot_tools下载配置环境](http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)

### gclient sync 的执行过程

1.终端命令配置`gclient.py`文件的环境变量`gclient sync`

2.读取engine目录下创建的`.gclient`文件

2.下载`git@github.com:<your_name_here>/engine.git`代码仓库

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

gclient sync 首先下载`git@github.com:<your_name_here>/engine.git`代码仓库，然后查找，使用`src/flutter中的DEPS`文件进行依赖下载，包括第三方库，下载关联的`git`代码仓库之后，安装`DESP中的`hook文件的配置执行相应的`python`脚本文件,在`src/Flutter/DEPS`文件执行到倒数第二个脚本是执行`src/tools`目录下的所有`Python`文件，接着查找`src/third_party/dart/DEPS`目录下的文件执行相关的依赖下载,我们分析一下上文中提到的三个`DEPS`文件，就能够跟中到整个项目下载的路程，在下载的过程中会出现一下版本不正常的文件，可以在`DEPS`文件中修改相应的版本号在进行下载


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

## gclient sync 依赖文件

  1. 全局公共的依赖: [Flutter 根目录下的DEPS](https://github.com/AidenCang/engine/blob/master/DEPS)
  2. 不同平台下的Dart 相关的依赖: [Dart依赖](https://github.com/dart-lang/sdk/blob/master/DEPS)
  3. [更新Dart依赖](https://github.com/dart-lang/sdk/wiki/Adding-and-Updating-Dependencies)

## DEPS 包含


在下载的过程中直接下载Git代码仓库，有一些需要逻辑处理的文件通过执行Python脚本来完成，下面几个核心的操作，我们提取出出来，可以直接跟踪一下，依赖的执行过程，更能够理解，整个源码目录下载了那些文件，有一个框架性的认识

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


## 源代码的进度保存`.gclient_entries`

gclient sync在下载源代码的过程中会包下载的文件保存在执行.gclient文件夹下

    ➜  engine la
    total 32
    -rw-r--r--   1 cangck  staff   196B 11 15 22:29 .gclient
    -rw-r--r--   1 cangck  staff   9.5K 11 17 22:05 .gclient_entries
    drwxr-xr-x   5 cangck  staff   160B 11 20 00:10 .vscode
    drwxr-xr-x  21 cangck  staff   672B 11 20 00:59 src

看一下下面的每一项是一个源码仓库地址@版本号或者是git commitid

```sh
'src': 'https://github.com/flutter/buildroot.git@7f64ff4928e7106cd8d81c6397fba4b7c1cdbb96',
'src/buildtools': 'https://fuchsia.googlesource.com/buildtools@bac220c15490dcf7b7d8136f75100bbc77e8d217',
'src/ios_tools': 'https://chromium.googlesource.com/chromium/src/ios.git@69b7c1b160e7107a6a98d948363772dc9caea46f',
'src/third_party/benchmark': 'https://fuchsia.googlesource.com/third_party/benchmark@21f1eb3fe269ea43eba862bf6b699cde46587ade',
'src/third_party/boringssl': 'https://github.com/dart-lang/boringssl_gen.git@bbf52f18f425e29b1185f2f6753bec02ed8c5880',
'src/third_party/boringssl/src': 'https://boringssl.googlesource.com/boringssl.git@702e2b6d3831486535e958f262a05c75a5cb312e',
'src/third_party/colorama/src': 'https://chromium.googlesource.com/external/colorama.git@799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8',
```
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

## 总结

在开始编译引擎之前，当然是要先把相关的环境安装好，了解整个源代码下载的过程和大概的逻辑，学习是一个循序渐进的过程，我们先了解整个源代码下载相关的逻辑和这些过程，把握住核心概念和步骤，在整个源码下载的过程中出现错误，可以正对性的去解决出现的问题
做技术的核心思想不是你掌握了多少知识，而是有多少产出，在研发的过程中由于环境的变化或者是需求的变化，导致bug的解决时间远远大于开发核心代码的时间，在出现问题是往往不是对定位的问题不能解决，而是找不到定位问题的方法，无从下手，本系列分享主要是以框架和思路为主，会定位整个源码核心功能和关键步骤，不会对细节分析的更多，linux之父的名言，开发代码最好的方法就是`Review Fuck Source Code`
