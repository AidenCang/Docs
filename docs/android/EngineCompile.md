# Flutter Engine 编译


## 深入理解flutter的编译原理与优化

闲鱼技术 2018-06-29 16:19:57 浏览7872 评论0
ios

android

架构

Framework

ARM

github

flutter
摘要： 闲鱼技术-正物 问题背景 对于开发者而言，什么是Flutter？它是用什么语言编写的，包含哪几部分，是如何被编译，运行到设备上的呢？Flutter如何做到Debug模式Hot Reload快速生效变更，Release模式原生体验的呢？Flutter工程和我们的Android/iOS工程有何差别，关...

闲鱼技术-正物

问题背景
对于开发者而言，什么是Flutter？它是用什么语言编写的，包含哪几部分，是如何被编译，运行到设备上的呢？Flutter如何做到Debug模式Hot Reload快速生效变更，Release模式原生体验的呢？Flutter工程和我们的Android/iOS工程有何差别，关系如何，又是如何嵌入Android/iOS的呢？Flutter的渲染和事件传递机制如何工作？Flutter支持热更新吗？Flutter官方并未提供iOS下的armv7支持，确实如此吗？在使用Flutter的时候，如果发现了engine的bug，如何去修改和生效？构建缓慢或出错又如何去定位，修改和生效呢？

凡此种种，都需要对Flutter从设计，开发构建，到最终运行有一个全局视角的观察。

本文将以一个简单的hello_flutter为例，介绍下Flutter相关原理及定制与优化。

Flutter简介
FlutterArchitecture

Flutter的架构主要分成三层:Framework，Engine和Embedder。

Framework使用dart实现，包括Material Design风格的Widget,Cupertino(针对iOS)风格的Widgets，文本/图片/按钮等基础Widgets，渲染，动画，手势等。此部分的核心代码是:flutter仓库下的flutter package，以及sky_engine仓库下的io,async,ui(dart:ui库提供了Flutter框架和引擎之间的接口)等package。

Engine使用C++实现，主要包括:Skia,Dart和Text。Skia是开源的二维图形库，提供了适用于多种软硬件平台的通用API。其已作为Google Chrome，Chrome OS，Android, Mozilla Firefox, Firefox OS等其他众多产品的图形引擎，支持平台还包括Windows7+,macOS 10.10.5+,iOS8+,Android4.1+,Ubuntu14.04+等。Dart部分主要包括:Dart Runtime，Garbage Collection(GC)，如果是Debug模式的话，还包括JIT(Just In Time)支持。Release和Profile模式下，是AOT(Ahead Of Time)编译成了原生的arm代码，并不存在JIT部分。Text即文本渲染，其渲染层次如下:衍生自minikin的libtxt库(用于字体选择，分隔行)。HartBuzz用于字形选择和成型。Skia作为渲染/GPU后端，在Android和Fuchsia上使用FreeType渲染，在iOS上使用CoreGraphics来渲染字体。

Embedder是一个嵌入层，即把Flutter嵌入到各个平台上去，这里做的主要工作包括渲染Surface设置,线程设置，以及插件等。从这里可以看出，Flutter的平台相关层很低，平台(如iOS)只是提供一个画布，剩余的所有渲染相关的逻辑都在Flutter内部，这就使得它具有了很好的跨端一致性。

Flutter工程结构
本文使用开发环境为flutter beta v0.3.1，对应的engine commit:09d05a389。

以hello_flutter工程为例，Flutter工程结构如下所示:

Flutter File Structure

其中ios为iOS部分代码，使用CocoaPods管理依赖，android为Android部分代码，使用Gradle管理依赖，lib为dart代码，使用pub管理依赖。类似iOS中Cocoapods对应的Podfile和Podfile.lock，pub下则是pubspec.yaml和pubspec.lock。

Flutter模式
对于Flutter，它支持常见的debug,release,profile等模式，但它又有其不一样。

Debug模式：对应了Dart的JIT模式，又称检查模式或者慢速模式。支持设备，模拟器(iOS/Android)，此模式下打开了断言，包括所有的调试信息，服务扩展和Observatory等调试辅助。此模式为快速开发和运行做了优化，但并未对执行速度，包大小和部署做优化。Debug模式下，编译使用JIT技术，支持广受欢迎的亚秒级有状态的hot reload。

Release模式：对应了Dart的AOT模式，此模式目标即为部署到终端用户。只支持真机，不包括模拟器。关闭了所有断言，尽可能多地去掉了调试信息，关闭了所有调试工具。为快速启动，快速执行，包大小做了优化。禁止了所有调试辅助手段，服务扩展。

Profile模式：类似Release模式，只是多了对于Profile模式的服务扩展的支持，支持跟踪，以及最小化使用跟踪信息需要的依赖，例如，observatory可以连接上进程。Profile并不支持模拟器的原因在于，模拟器上的诊断并不代表真实的性能。

鉴于Profile同Release在编译原理等上无差异，本文只讨论Debug和Release模式。

事实上flutter下的iOS/Android工程本质上依然是一个标准的iOS/Android的工程，flutter只是通过在BuildPhase中添加shell来生成和嵌入App.framework和Flutter.framework(iOS),通过gradle来添加flutter.jar和vm/isolate_snapshot_data/instr(Android)来将Flutter相关代码编译和嵌入原生App而已。因此本文主要讨论因flutter引入的构建，运行等原理。编译target虽然包括arm,x64,x86,arm64，但因原理类似，本文只讨论arm相关(如无特殊说明，android默认为armv7)。

Flutter代码的编译与运行(iOS)
Release模式下的编译
release模式下，flutter下iOS工程中dart代码构建链路如下所示:

iOS compile and embed

其中gen_snapshot是dart编译器，采用了tree shaking(类似依赖树逻辑，可生成最小包，也因而在Flutter中禁止了dart支持的反射特性)等技术,用于生成汇编形式的机器代码，再通过xcrun等编译工具链生成最终的App.framework。换句话说，所有的dart代码，包括业务代码，三方package代码，它们所依赖的flutter框架代码，最终将会变成App.framework。

tree shaking功能位于gen_snapshot中，对应逻辑参见: engine/src/third_party/dart/runtime/vm/compiler/aot/precompiler.cc

dart代码最终对应到App.framework中的符号如下所示:

dart code to symbol in App.framework

事实上，类似Android Release下的产物(见下文)，App.framework也包含了kDartVmSnapshotData，kDartVmSnapshotInstructions，kDartIsolateSnapshotData，kDartIsolateSnapshotInstructions四个部分。为什么iOS使用App.framework这种方式，而不是Android的四个文件的方式呢？原因在于在iOS下，因为系统的限制，Flutter引擎不能够在运行时将某内存页标记为可执行，而Android是可以的。

Flutter.framework对应了Flutter架构中的engine部分，以及Embedder。实际中Flutter.framework位于flutter仓库的/bin/cache/artifacts/engine/ios*下，默认从google仓库拉取。当需要自定义修改的时候，可通过下载engine源码，利用Ninja构建系统来生成。

Flutter相关代码的最终产物是:App.framework(dart代码生成)和Flutter.framework(引擎)。从Xcode工程的视角看，Generated.xcconfig描述了Flutter相关环境的配置信息，然后Runner工程设置中的Build Phases新增的xcode_backend.sh实现了Flutter.framework的拷贝(从Flutter仓库的引擎到Runner工程根目录下的Flutter目录)与嵌入和App.framework的编译与嵌入。最终生成的Runner.app中Flutter相关内容如下所示:

Flutter in Runner Release

其中flutter_assets是相关的资源，代码则是位于Frameworks下的App.framework和Flutter.framework。

Release模式下的运行
Flutter相关的渲染，事件，通信处理逻辑如下所示:

Render and event logic

其中dart中的main函数调用栈如下:

main in dart callstack

Debug模式下的编译
Debug模式下flutter的编译，结构类似Release模式，差异主要表现为两点:

1.Flutter.framework

因为是Debug，此模式下Framework中是有JIT支持的，而在Release模式下并没有JIT部分。

2.App.framework

不同于AOT模式下的App.framework是Dart代码对应的本地机器代码，JIT模式下，App.framework只有几个简单的API，其Dart代码存在于snapshot_blob.bin文件里。这部分的snapshot是脚本快照，里面是简单的标记化的源代码。所有的注释，空白字符都被移除，常量也被规范化，也没有机器码，tree shaking或者是混淆。

App.framework中的符号表如下所示:

App in debug symbols

对Runner.app/flutter_assets/snapshot_blob.bin执行strings命令可以看到如下内容:

snapshot bin strings

Debug模式下main入口的调用堆栈如下:

debug isolate main callstack

Flutter代码的编译与运行(Android)
鉴于Android和iOS除了部分平台相关的特性外，其他逻辑如Release对应AOT，Debug对应JIT等均类似，此处只涉及两者不同。

Release模式下的编译
release模式下，flutter下Android工程中dart代码整个构建链路如下所示:

android release build flow

其中vm/isolate_snapshot_data/instr内容均为arm指令，将会在运行时被engine载入，并标记vm/isolate_snapshot_instr为可执行。vm_中涉及runtime等服务(如gc)，用于初始化DartVM，调用入口见Dart_Initialize(dart_api.h)。isolate__则是对应了我们的App代码，用于创建一个新的isolate,调用入口见Dart_CreateIsolate(dart_api.h)。flutter.jar类似iOS的Flutter.framework，包括了engine部分的代码(Flutter.jar中的libflutter.so)，以及一套将Flutter嵌入Android的类和接口(FlutterMain,FlutterView,FlutterNativeView等)。实际中flutter.jar位于flutter仓库的/bin/cache/artifacts/engine/android*下，默认从google仓库拉取。当需要自定义修改的时候，可通过下载engine源码，利用Ninja构建系统来生成flutter.jar。

以isolate_snapshot_data/instr为例，执行disarm命令结果如下:

isolate snapshot data disarm

isolate snapshot instr disarm)

其Apk结构如下所示:

Flutter android release apk structure

APK新安装之后，会根据一个ts的判断(packageinfo中的versionCode结合lastUpdateTime)来决定是否拷贝APK中的assets，拷贝后内容如下所示:

app flutter

isolate/vm_snapshot_data/instr均最后位于app的本地data目录下，而这部分又属于可写内容，因此可以通过下载并替换的方式，完成App的整个替换和更新。

Release模式下的运行
Render&Event in release mode

Debug模式下的编译
类似iOS的Debug/Release的差别，Android的Debug与Release的差异主要包括以下两部分:

1.flutter.jar

区别同iOS

2.App代码部分

位于flutter_assets下的snapshot_blob.bin，同iOS。

在介绍了iOS/Android下的Flutter编译原理后，下面着重描述下如何定制flutter/engine以完成定制和优化。鉴于Flutter处于敏捷的迭代中，现在的问题后续不一定是问题，因而此部分并不是要去解决多少问题，而是选取不同类别的问题来说明解决思路。

Flutter构建相关的定制与优化
Flutter是一个很复杂的系统，除了上述提到的三层架构中的内容外，还包括Flutter Android Studio(Intellij)插件，pub仓库管理等。但我们的定制和优化往往是在flutter的工具链相关，具体代码位于flutter仓库的flutter_tools包。接下来举例说明下如何对这部分做定制。

Android部分
相关内容包括flutter.jar，libflutter.so(位于flutter.jar下)，gen_snapshot，flutter.gradle，flutter(flutter_tools)。

1.限定Android中target为armeabi

此部分属于构建相关，逻辑位于flutter.gradle下。当App是通过armeabi支持armv7/arm64的时候，需要修改flutter的默认逻辑。如下所示:

android support armeabi only

因为gradle本身的特点，此部分修改后直接构建即可生效。

2.设定Android启动时默认使用第一个launchable-activity

此部分属于flutter_tools相关，修改如下:

android launchable activity

这里的重点不是如何去修改，而是如何去让修改生效。原理上来说，flutter run/build/analyze/test/upgrade等命令实际上执行的都是flutter(flutter_repo_dir/bin/flutter)这一脚本，再通过脚本通过dart执行flutter_tools.snapshot(通过packages/flutter_tools生成)。其逻辑如下:

if [[ ! -f "SNAPSHOT_PATH" ]] || [[ ! -s "STAMP_PATH" ]] || [[ "(cat "STAMP_PATH")" != "revision" ]] || [[ "FLUTTER_TOOLS_DIR/pubspec.yaml" -nt "$FLUTTER_TOOLS_DIR/pubspec.lock" ]]; then
        rm -f "$FLUTTER_ROOT/version"
        touch "$FLUTTER_ROOT/bin/cache/.dartignore"
        "$FLUTTER_ROOT/bin/internal/update_dart_sdk.sh"
        echo Building flutter tool...
    if [[ "$TRAVIS" == "true" ]] || [[ "$BOT" == "true" ]] || [[ "$CONTINUOUS_INTEGRATION" == "true" ]] || [[ "$CHROME_HEADLESS" == "1" ]] || [[ "$APPVEYOR" == "true" ]] || [[ "$CI" == "true" ]]; then
      PUB_ENVIRONMENT="$PUB_ENVIRONMENT:flutter_bot"
    fi
    export PUB_ENVIRONMENT="$PUB_ENVIRONMENT:flutter_install"

    if [[ -d "$FLUTTER_ROOT/.pub-cache" ]]; then
      export PUB_CACHE="${PUB_CACHE:-"$FLUTTER_ROOT/.pub-cache"}"
    fi

    while : ; do
      cd "$FLUTTER_TOOLS_DIR"
      "$PUB" upgrade --verbosity=error --no-packages-dir && break
      echo Error: Unable to 'pub upgrade' flutter tool. Retrying in five seconds...
      sleep 5
    done
    "$DART" --snapshot="$SNAPSHOT_PATH" --packages="$FLUTTER_TOOLS_DIR/.packages" "$SCRIPT_PATH"
    echo "$revision" > "$STAMP_PATH"
    fi
不难看出要重新构建flutter_tools，可以删除flutter_repo_dir/bin/cache/flutter_tools.stamp(这样重新生成一次)，或者屏蔽掉if/fi判断(每一次都会重新生成)。

3.如何在Android工程Debug模式下使用release模式的flutter

当开发者在研发中发现flutter有些卡顿时，猜测可能是逻辑的原因，也可能是因为是Debug下的flutter。此时可以构建release下的apk，也可以将flutter强制修改为release模式如下:

flutter in android always release

iOS部分
相关内容包括:Flutter.framework，gen_snapshot，xcode_backend.sh，flutter(flutter_tools)。

1.优化构建过程中反复替换Flutter.framework导致的重新编译

此部分逻辑属于构建相关，位于xcode_backend.sh中，Flutter为了保证每次获取到正确的Flutter.framework,每次都会基于配置(见Generated.xcconfig配置)查找和替换Flutter.framework，但这也导致了工程中对此Framework有依赖部分代码的重新编译，修改如下:

xcode_backend not always replace Flutter

2.如何在iOS工程Debug模式下使用release模式的flutter

只需要将Generated.xcconfig中的FLUTTER_BUILD_MODE修改为release，FLUTTER_FRAMEWORK_DIR修改为release对应的路径即可。

3.armv7的支持

原始文章请参见:https://github.com/flutter/engine/wiki/iOS-Builds-Supporting-ARMv7

事实上flutter本身是支持iOS下的armv7的，但目前并未提供官方支持，需要自行修改相关逻辑，具体如下:

a.默认的逻辑可以生成Flutter.framework(arm64)

b.修改flutter以使得flutter_tools可以每次重新构建，修改build_aot.dart和mac.dart，将相关针对iOS的arm64修改为armv7,修改gen_snapshot为i386架构。

其中i386架构下的gen_snapshot可通过以下命令生成:

./flutter/tools/gn --runtime-mode=debug --ios --ios-cpu=arm
ninja -C out/ios_debug_arm
这里有一个隐含逻辑:

构建gen_snapshot的CPU相关预定义宏(__x86_64__/__i386等)，目标gen_snapshot的arch，最终的App.framework的架构整体上要保持一致。即x86_64->x86_64->arm64或者i386->i386->armv7。

c.在iPhone4S上，会发生因gen_snapshot生成不被支持的SDIV指令而造成EXC_BAD_INSTRUCTION(EXC_ARM_UNDEFINED)错误，可通过给gen_snapshot添加参数--no-use-integer-division实现(位于build_aot.dart)。其背后的逻辑如下图所示:

iPhone 4s crash logic

d.基于a和b生成的Flutter.framework,将其lipo create生成同时支持armv7和arm64的Flutter.framework。

e.修改Flutter.framework下的Info.plist，移除

  <key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>arm64</string>
  </array>
同理，对于App.framework也要作此操作，以免上架后会受到App Thining的影响。

flutter_tools的调试
例如我们想了解flutter在构建debug模式下的apk的时候，具体执行的逻辑如何，可以按照下面的思路走:

a.了解flutter_tools的命令行参数

Flutter tools print args

b.以dart工程形式打开packages/flutter_tools，基于获得的参数修改flutter_tools.dart，设置命令行dart app即可开始调试。

edit flutter_tools dart and debug it with given args

定制engine与调试
假设我们在flutter beta v0.3.1的基础上进行定制与业务开发，为了保证稳定，一定周期内并不升级SDK，而此时，flutter在master上修改了某个v0.3.1上就有的bug，记为fix_bug_commit。如何才能跟踪和管理这种情形呢？

1.flutter beta v0.3.1指定了其对应的engine commit为:09d05a389，见flutter/bin/internal/engine.version。

2.获取engine代码

3.因为2中拿到的是master代码，而我们需要的是特定commit(09d05a389)对应的代码库，因而从此commit拉出新分支:custom_beta_v0.3.1。

4.基于custom_beta_v0.3.1(commit:09d05a389)，执行gclient sync，即可拿到对应flutter beta v0.3.1的所有engine代码。

5.使用git cherry-pick fix_bug_commit将master的修改同步到custom_beta_v0.3.1，如果修改有很多对最新修改的依赖，可能会导致编译失败。

6.对于iOS相关的修改执行以下代码:

./flutter/tools/gn --runtime-mode=debug --ios --ios-cpu=arm
ninja -C out/ios_debug_arm

./flutter/tools/gn --runtime-mode=release --ios --ios-cpu=arm
ninja -C out/ios_release_arm

./flutter/tools/gn --runtime-mode=profile --ios --ios-cpu=arm
ninja -C out/ios_profile_arm

./flutter/tools/gn --runtime-mode=debug --ios --ios-cpu=arm64
ninja -C out/ios_debug

./flutter/tools/gn --runtime-mode=release --ios --ios-cpu=arm64
ninja -C out/ios_release

./flutter/tools/gn --runtime-mode=profile --ios --ios-cpu=arm64
ninja -C out/ios_profile
即可生成针对iOS的arm/arm64&debug/release/profile的产物。可用构建产物替换flutter/bin/cache/artifacts/engine/ios*下的Flutter.framework和gen_snapshot。

如果需要调试Flutter.framework源代码，构建的时候命令如下:

./flutter/tools/gn --runtime-mode=debug --unoptimized --ios --ios-cpu=arm64
ninja -C out/ios_debug_unopt
用生成产物替换掉flutter中的Flutter.framework和gen_snapshot，即可调试engine源代码。

7.对于Android相关的修改执行以下代码:

./flutter/tools/gn --runtime-mode=debug --android --android-cpu=arm
ninja -C out/android_debug

./flutter/tools/gn --runtime-mode=release --android --android-cpu=arm
ninja -C out/android_release

./flutter/tools/gn --runtime-mode=profile --android --android-cpu=arm
ninja -C out/android_profile
即可生成针对Android的arm&debug/release/profile的产物。可用构建产物替换flutter/bin/cache/artifacts/engine/android*下的gen_snapshot和flutter.jar。











## Flutter 的两种编译模式

2018年08月02日 16:07:19 H.A.N 阅读数：1835更多
所属专栏： Flutter学习实践指南
 版权声明：本文为博主原创文章，未经博主允许不得转载。	https://blog.csdn.net/u010960265/article/details/81361711
使用 Flutter 构建过 App 的人一定有一个困惑，就是 Flutter 编译出的产物到底是什么玩意。有时候分为几个文件，有时候是一个动态库，真的叫人摸不着头脑。

本文详细解释一下 Flutter 的编译模式。

编译模式的分类
编程语言要达到可运行的目的需要经过编译，一般地来说，编译模式分为两类：JIT 和 AOT。

JIT
JIT 全称 Just In Time (即时编译），典型的例子就是 v8，它可以即时编译并运行 JavaScript。所以你只需要输入源代码字符串，v8 就可以帮你编译并运行代码。通常来说，支持 JIT 的语言一般能够支持自省函数（eval），在运行时动态地执行代码。

JIT 模式的优势是显而易见的，可以动态下发和执行代码，而不用管用户的机器是什么架构，为应用的用户提供丰富而动态地内容。

但 JIT 的劣势也是显而易见的，大量字符串的代码很容易让 JIT 编译器花费很多时间和内存进行编译，给用户带来的直接感受就是应用启动慢。

AOT
AOT 全称 Ahead Of Time（事前编译），典型的例子就是 C/C++，LLVM 或 GCC 通过编译并生成 C/C++ 的二进制代码，然后这些二进制通过用户安装并取得执行权限后才可以通过进程加载执行。

AOT 的优势也是显而易见的，事先编译好的二进制代码，加载和执行的速度都会非常快。（所以编程语言速度排行榜上前列都是 AOT 编译类语言）这样的速度可以在密集计算场景下给用户带来非常好的体验，比如大型游戏的引擎渲染和逻辑执行。

但是 AOT 的劣势也是显而易见的，编译需要区分用户机器的架构，生成不同架构的二进制代码。除了架构，二进制代码本身也会让用户下载的安装包比较大。二进制代码一般需要取得执行权限才可以执行，所以无法在权限比较严格的系统中进行动态更新（如 iOS）。

Dart的编译模式
Flutter 使用 Dart 作为编程语言，自然其编译模式也脱离不了 Dart 的干系。首先我们需要了解一下 Dart 所支持的编译模式。

Script：最普通的 JIT 模式，在 PC 命令行调用 Dart VM 执行 Dart 源代码文件即是这种模式；
Script Snapshot：JIT 模式，和上一个不同的是，这里载入的是已经 token 化的 Dart 源代码，提前执行了上一步的
lexer 步骤；
Application Snapshot：JIT 模式，这种模式来源于 Dart VM 直接载入源码后 dump 出数据。Dart VM
通过这种数据启动会更快。不过值得一提的是这种模式是区分架构的，在 x64 上生成的数据不可以给 arm 使用;
AOT：AOT模式，直接将 Dart 源码编译出 .S 文件，然后通过汇编器生成对应架构的代码。
总结一下刚才的列表，可以发现：
这里写图片描述

Flutter的编译模式
Flutter 完全采用了 Dart，按道理来说编译模式一致才是，但是事实并不是这样。由于 Android 和 iOS平台的生态差异，Flutter 也衍生出了非常丰富的编译模式。

Script：同 Dart Script 模式一致，虽然 Flutter 支持，但暂未看到使用，毕竟影响启动速度；
Script Snapshot：同 Dart Script Snapshot 一致，同样支持但未使用，Flutter
有大量的视图渲染逻辑，纯 JIT 模式影响执行速度；
Kernel Snapshot：Dart 的 bytecode模式，与 Application Snapshot 不同，bytecode
模式是不区分架构的。Kernel Snapshot 在 Flutter 项目内也叫 Core Snapshot。bytecode模式可以归类为 AOT 编译；
Core JIT：Dart 的一种二进制模式，将指令代码和 heap 数据打包成文件，然后在 VM 和 isolate
启动时载入，直接标记内存可执行，可以说这是一种 AOT 模式。Core JIT 也被叫做 AOTBlob；
AOT Assembly: 即 Dart 的 AOT 模式。直接生成汇编源代码文件，由各平台自行汇编。
可以看出来，Flutter 将 Dart 的编译模式复杂化了，多了不少概念，要一下叙述清楚是比较困难的，所以我们着重从 Flutter 应用开发的各个阶段来解读。

开发阶段的编译模式
在开发阶段，我们需要 Flutter 的 Hot Reload 和 Hot Restart 功能，方便 UI 快速成型。同时，框架层也需要比较高的性能来进行视图渲染展现。因此开发模式下，Flutter 使用了 Kernel Snapshot 模式编译。

在打包产物中，你将发现几样东西：

isolate_snapshot_data：用于加速 isolate 启动，业务无关代码，固定，仅和 flutter engine
版本有关；
platform.dill：和 Dart VM 相关的 kernel 代码，仅和 Dart 版本以及 engine
编译版本有关。固定，业务无关代码；
vm_snapshot_data: 用于加速 Dart VM 启动的产物，业务无关代码，仅和 flutter engine 版本有关；
kernel_blob.bin：业务代码产物
这里写图片描述
生产阶段的编译模式
在生产阶段，应用需要的是非常快的速度，所以 Android 和 iOS target 毫无意外地都选择了 AOT 打包。不过由于平台特性不同，打包模式也是天壤之别。

这里写图片描述

首先我们很容易认识到 iOS 平台上做法的原因：App Store 审核条例不允许动态下发可执行二进制代码。

所以在 iOS 上，除了 JavaScript，其他语言运行时的实现都选择了 AOT（比如 OpenJDK 在 iOS 实现就是 AOT）。

在 Android 上，Flutter 的做法有点意思：支持了两种不同的路子。

Core JIT 的打包产物有 4 个：isolate_snapshot_data、vm_snapshot_data、isolate_snapshot_instr、vm_snapshot_instr。我们不认识的产物只有 2 个：isolate_snapshot_instr 和 vm_snapshot_instr，其实它俩代表着 VM 和 isolate 启动后所承载的指令等数据。在载入后，直接将该块内存执行即可。

Android 的 AOT Assembly 打包方式很容易让人想到需要支持多架构，无疑增大了代码包，并且该处代码需要从 JNI 调用，远不如 Core JIT 的 Java API 方便。所以 Android 上默认使用 Core JIT 打包，而不是 AOT Assembly。

Flutter Engine 对编译模式的支持
在我的上篇文章：Flutter原理简解 中提到，Engine 承载了 Dart 运行时，毫无疑问 Engine 需要和打包出来的代码对的上号才行。
在 Engine 的编译模式中，Flutter 是这样选择的：
这里写图片描述

所以我们可以看到，Flutter 的编译模式是完全根据 Engine 的支持度来设计的。

结论
Flutter 是一种高性能的、可跨平台的、动态化应用开发方案。

在 iOS 和 Android 平台上，动态化完全可由 Kernel Snapshot 打包实现，并且产物是一致通用的。不过目前通过打包工具进行了阉割，只能生成 debug 产物。

并且如果不需要动态化，同样可以打包出拥有更高执行性能的二进制库文件使用。这个特性目前就已经支持，有了理论的支持，我们就可以着手做改造的事了。
