# flutter 编译常见错误


### Bad state: Could not find package matching arguments: Instance of 'OptionsRevision', OSType.mac, null

➜  src git:(4c4c89c) ✗ gclient sync
Syncing projects: 100% (86/86), done.
Running hooks:  40% ( 4/10) prepare_android_downloader
________ running '../../../third_party/dart/tools/sdks/dart-sdk/bin/pub get' in '/Users/cuco/engine/src/tools/android/android_sdk_downloader'
Resolving dependencies...
Got dependencies!
Running hooks:  50% ( 5/10) download_android_tools
________ running 'src/third_party/dart/tools/sdks/dart-sdk/bin/dart --enable-asserts src/tools/android/android_sdk_downloader/lib/main.dart -y --out=src/third_party/android_tools --platform=28 --platform-revision=6 --build-tools-version=28.0.3 --platform-tools-version=28.0.1 --tools-version=26.1.1 --ndk-version=19.1.5304403' in '/Users/cuco/engine'
src/tools/android/android_sdk_downloader/lib/main.dart:1: Warning: Interpreting this as package URI, 'package:android_sdk_downloader/main.dart'.
Downloading Android SDK and NDK artifacts...
Skipping Android SDK Platform 28, checksum matches current asset.
Skipping Android SDK Build-Tools 28.0.3, checksum matches current asset.
Skipping Android SDK Tools, checksum matches current asset.
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
#8      _AsyncAwaitCompleter.complete (dart:async/runtime/libasync_patch.dart:28:18)
#9      _completeOnAsyncReturn (dart:async/runtime/libasync_patch.dart:295:13)
#10     loadChecksums (package:android_sdk_downloader/src/checksums.dart)
#11     _RootZone.runUnary (dart:async/zone.dart:1379:54)
#12     _FutureListener.handleValue (dart:async/future_impl.dart:129:18)
#13     Future._propagateToListeners.handleValueCallback (dart:async/future_impl.dart:642:45)
#14     Future._propagateToListeners (dart:async/future_impl.dart:671:32)
#15     Future._completeWithValue (dart:async/future_impl.dart:486:5)
#16     Future._asyncComplete.<anonymous closure> (dart:async/future_impl.dart:516:7)
#17     _microtaskLoop (dart:async/schedule_microtask.dart:41:21)
#18     _startMicrotaskLoop (dart:async/schedule_microtask.dart:50:5)
#19     _runPendingImmediateCallback (dart:isolate/runtime/libisolate_patch.dart:115:13)
#20     _RawReceivePortImpl._handleMessage (dart:isolate/runtime/libisolate_patch.dart:172:5)
Error: Command 'src/third_party/dart/tools/sdks/dart-sdk/bin/dart --enable-asserts src/tools/android/android_sdk_downloader/lib/main.dart -y --out=src/third_party/android_tools --platform=28 --platform-revision=6 --build-tools-version=28.0.3 --platform-tools-version=28.0.1 --tools-version=26.1.1 --ndk-version=19.1.5304403' returned non-zero exit status 255 in /Users/cuco/engine

### 修改源代码commit就可以了

➜  engine gclient sync
src (ERROR)
----------------------------------------
[0:00:00] Started.
[0:00:00] Finished running: git config remote.origin.url
[0:00:00] Finished running: git rev-list -n 1 HEAD
[0:00:00] Finished running: git rev-parse --abbrev-ref=strict HEAD
[0:00:00] Finished running: git rev-parse 7f64ff4928e7106cd8d81c6397fba4b7c1cdbb96
----------------------------------------
Error: 2>
2> ____ src at 7f64ff4928e7106cd8d81c6397fba4b7c1cdbb96
2> 	You have unstaged changes.
2> 	Please commit, stash, or reset.
