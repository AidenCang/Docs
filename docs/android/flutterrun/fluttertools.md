# Flutter 生成Apk&ipa包

Flutter开发中经常使用到Flutter相关的命令分类:
安装Flutter相关的文件

1.配置Flutter相关的配置信息&环境构建

2.flutter创建项目

3.项目源代码分析

4.运行设备的初始化

5.测试相关


在开发中，我们经常使用到Flutter相关的命令来这些一些操作，FlutterSdk在安装包中flutter/bind/flutter命令是一个shell脚本，在安装的时候我们在环境变量中已经配置了查找路劲，在终端命令行中可以这几运行该命令[安装flutter环境](https://flutter.dev/docs/get-started/install/macos)`export PATH="$PATH:`pwd`/flutter/bin"`在终端这些Flutter  arg是可以直接调用flutter,安装FlutterSDK时，包括了开发工具和Flutter项目：

1.sdk相关配置

2.创建Flutter工程

3.开发框架、第三方库文件的依赖管理

4.源码分析工具

5.编译、运行

6.安装、测试

Flutter命令的作为一个`flutter/bin/flutter`进行执行。Flutter是使用shell进行编写，


```shell
#!/usr/bin/env bash
....
PROG_NAME="$(path_uri "$(follow_links "$BASH_SOURCE")")"
BIN_DIR="$(cd "${PROG_NAME%/*}" ; pwd -P)"
export FLUTTER_ROOT="$(cd "${BIN_DIR}/.." ; pwd -P)"

FLUTTER_TOOLS_DIR="$FLUTTER_ROOT/packages/flutter_tools"
SNAPSHOT_PATH="$FLUTTER_ROOT/bin/cache/flutter_tools.snapshot"
STAMP_PATH="$FLUTTER_ROOT/bin/cache/flutter_tools.stamp"
SCRIPT_PATH="$FLUTTER_TOOLS_DIR/bin/flutter_tools.dart"
DART_SDK_PATH="$FLUTTER_ROOT/bin/cache/dart-sdk"

DART="$DART_SDK_PATH/bin/dart"
PUB="$DART_SDK_PATH/bin/pub"
.......
"$DART" --packages="$FLUTTER_TOOLS_DIR/.packages" $FLUTTER_TOOL_ARGS "$SNAPSHOT_PATH" "$@"

```

该方法功能：

* $DART：是指$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart；
* $SNAPSHOT_PATH：是指$FLUTTER_ROOT/bin/cache/flutter_tools.snapshot，这是由packages/flutter_tools项目编译所生成的产物文件。

dart执行flutter_tools.snapshot，其实也就是执行flutter_tools.dart的main()方法，也就是说将上述命令改为如下语句，则运行flutter命令可以执行本地flutter_tools的项目代码，可用于本地调试分析。

    /bin/cache/dart-sdk/bin/dart $FLUTTER_TOOL_ARGS "$FLUTTER_ROOT/packages/flutter_tools/bin/flutter_tools.dart" "$@"

进一步分析flutter_tools.dart文件

## flutter_tools.dart
下载官方的SDK和配置好环境路径之后，就可以运行SDK了，运行SDK的入口文件时flutter，作为入口文件，在文件的中构建相关的配置文件路径，使用dart命令来运行dart代码，可是这些dart相关的文件，使用shell脚本启动dart相关的文件之后就开始进入dart的世界，接下来分析dart的入口文件

在入口文件中，主要配置相关的参数，实现相关的命令行工具，构建脚本和环境的类:

1.args

2.Command相关的实现类

3.BuildRunner

4.BuildRunnerWebCompilationProxy

5.DwdsWebRunnerFactory

```dart
/// Main entry point for commands.
///
/// This function is intended to be used from the `flutter` command line tool.
Future<void> main(List<String> args) async {
  final bool verbose = args.contains('-v') || args.contains('--verbose');

  final bool doctor = (args.isNotEmpty && args.first == 'doctor') ||
      (args.length == 2 && verbose && args.last == 'doctor');
  final bool help = args.contains('-h') || args.contains('--help') ||
      (args.isNotEmpty && args.first == 'help') || (args.length == 1 && verbose);
  final bool muteCommandLogging = help || doctor;
  final bool verboseHelp = help && verbose;

  await runner.run(args, <FlutterCommand>[
    AnalyzeCommand(verboseHelp: verboseHelp),
    AssembleCommand(),
    AttachCommand(verboseHelp: verboseHelp),
    BuildCommand(verboseHelp: verboseHelp),
    ChannelCommand(verboseHelp: verboseHelp),
    CleanCommand(),
    ConfigCommand(verboseHelp: verboseHelp),
    CreateCommand(),
    DaemonCommand(hidden: !verboseHelp),
    DevicesCommand(),
    DoctorCommand(verbose: verbose),
    DriveCommand(),
    EmulatorsCommand(),
    FormatCommand(),
    GenerateCommand(),
    IdeConfigCommand(hidden: !verboseHelp),
    InjectPluginsCommand(hidden: !verboseHelp),
    InstallCommand(),
    LogsCommand(),
    MakeHostAppEditableCommand(),
    PackagesCommand(),
    PrecacheCommand(),
    RunCommand(verboseHelp: verboseHelp),
    ScreenshotCommand(),
    ShellCompletionCommand(),
    TestCommand(verboseHelp: verboseHelp),
    TrainingCommand(),
    UnpackCommand(),
    UpdatePackagesCommand(hidden: !verboseHelp),
    UpgradeCommand(),
    VersionCommand(),
  ], verbose: verbose,
     muteCommandLogging: muteCommandLogging,
     verboseHelp: verboseHelp,
     overrides: <Type, Generator>{
       // The build runner instance is not supported in google3 because
       // the build runner packages are not synced internally.
       CodeGenerator: () => const BuildRunner(),
       WebCompilationProxy: () => BuildRunnerWebCompilationProxy(),
       // The web runner is not supported internally because it depends
       // on dwds.
       WebRunnerFactory: () => DwdsWebRunnerFactory(),
     });
}
```
## CommandRunner&Command
`CommandRunner`：负责执行相关的命令行工具(动态过程)，实现类`FlutterCommandRunner`加载当前目录下的`.packages`第三方文件，加载环境变量和相关的运行文件

1.第三方包文件`.packages`

2.flutterEngine相关的信息

3.平台相关的信息，添加相关的文件到环境变量中

`Command`:构建命令，处理不同实现的子命令的构建过程

### runner.run

1.初始化FlutterCommandRunner，加载第三方依赖库

2.加载所有的命令行实现类，进行初始化

3.初始化运行环境,这段代码是一个回调函数的调用方法，在后续的调用

4.运行代码到dartVM的Zoned中

5.runZoned<Future<int>>

```dart

/// Runs the Flutter tool with support for the specified list of [commands].
Future<int> run(
  List<String> args,
  List<FlutterCommand> commands, {
  bool muteCommandLogging = false,
  bool verbose = false,
  bool verboseHelp = false,
  bool reportCrashes,
  String flutterVersion,
  Map<Type, Generator> overrides,
}) {
  reportCrashes ??= !isRunningOnBot;

  if (muteCommandLogging) {
    // Remove the verbose option; for help and doctor, users don't need to see
    // verbose logs.
    args = List<String>.from(args);
    args.removeWhere(
        (String option) => option == '-v' || option == '--verbose');
  }

  ///设置系统环境
  final FlutterCommandRunner runner =
      FlutterCommandRunner(verboseHelp: verboseHelp);

  ///添加实现的命令行工具，进行初始化
  commands.forEach(runner.addCommand);

  ///初始化运行环境
  return runInContext<int>(() async {
    // Initialize the system locale.
    final String systemLocale = await intl_standalone.findSystemLocale();
    intl.Intl.defaultLocale = intl.Intl.verifiedLocale(
      systemLocale,
      intl.NumberFormat.localeExists,
      onFailure: (String _) => 'en_US',
    );

    String getVersion() =>
        flutterVersion ??
        FlutterVersion.instance.getVersionString(redactUnknownBranches: true);
    Object firstError;
    StackTrace firstStackTrace;

    ///运行代码到dartVM的Zoned中
    return await runZoned<Future<int>>(() async {
      try {
        ///调用命令行实现子类
        await runner.run(args);
        return await _exit(0);
      } catch (error, stackTrace) {
        firstError = error;
        firstStackTrace = stackTrace;
        return await _handleToolError(
            error, stackTrace, verbose, args, reportCrashes, getVersion);
      }
    }, onError: (Object error, StackTrace stackTrace) async {
      // If sending a crash report throws an error into the zone, we don't want
      // to re-try sending the crash report with *that* error. Rather, we want
      // to send the original error that triggered the crash report.
      final Object e = firstError ?? error;
      final StackTrace s = firstStackTrace ?? stackTrace;
      await _handleToolError(e, s, verbose, args, reportCrashes, getVersion);
    });
  }, overrides: overrides);
}
```

### runInContext
Flutter是一个跨平台的开发工具，在编译系统中需要处理不同平台的运行环境

1.加载构建的系统和相关的目录

2.加载第三方依赖

3.加载Android&IOS&Web&Window&Mac相关的内容

    3.1.开发环境
    3.2.sdk
    3.3.开发工具
    3.4.开发依赖管理工具链
    3.5.设备管理&模拟器加载管理
    3.6.操作系统工具
    3.7.Snapshot生成工具
    3.8.运行、调试工具

```dart
Future<T> runInContext<T>(
    FutureOr<T> runner(), {
      Map<Type, Generator> overrides,
    }) async {
  return await context.run<T>(
    name: 'global fallbacks',
    body: runner,
    overrides: overrides,
    fallbacks: <Type, Generator>{
      ///验证Android的License
      AndroidLicenseValidator: () => AndroidLicenseValidator(),

      ///加载AndroidSDK
      AndroidSdk: AndroidSdk.locateAndroidSdk,

      ///读取开发工具的配置参数
      AndroidStudio: AndroidStudio.latestValid,

      ///验证Android开发工具链
      AndroidValidator: () => AndroidValidator(),

      ///加载Android的Adb文件
      AndroidWorkflow: () => AndroidWorkflow(),

      ///打包不同平台的包
      ApplicationPackageFactory: () => ApplicationPackageFactory(),

      ///获取引擎模板
      Artifacts: () => CachedArtifacts(),

      ///打包assertBundle
      AssetBundleFactory: () => AssetBundleFactory.defaultInstance,
      BotDetector: () => const BotDetector(),

      ///配置构建系统参数
      BuildSystem: () => const BuildSystem(),

      ///配置缓存目录
      Cache: () => Cache(),

      ///devtools开发工具配置参数
      ChromeLauncher: () => const ChromeLauncher(),

      ///IOS构建工具
      CocoaPods: () => CocoaPods(),

      ///CocoaPods配置参数验证
      CocoaPodsValidator: () => const CocoaPodsValidator(),

      ///'.flutter_settings'
      Config: () => Config(),
      DevFSConfig: () => DevFSConfig(),

      ///查找开发主机上的连接设备
      DeviceManager: () => DeviceManager(),

      ///查找可用的doctor文件
      Doctor: () => const Doctor(),

      ///Doctor验证工具
      DoctorValidatorsProvider: () => DoctorValidatorsProvider.defaultInstance,

      ///Android&IOS模拟器管理工具
      EmulatorManager: () => EmulatorManager(),

      ///检查SDK的特征
      FeatureFlags: () => const FeatureFlags(),
      Flags: () => const EmptyFlags(),

      ///验证Flutter版本
      FlutterVersion: () => FlutterVersion(const SystemClock()),

      ///Fuchsia开发工具
      FuchsiaArtifacts: () => FuchsiaArtifacts.find(),
      FuchsiaDeviceTools: () => FuchsiaDeviceTools(),
      FuchsiaSdk: () => FuchsiaSdk(),
      FuchsiaWorkflow: () => FuchsiaWorkflow(),

      ///Snapshot生成工具
      GenSnapshot: () => const GenSnapshot(),

      ///热加载配置参数
      HotRunnerConfig: () => HotRunnerConfig(),

      ///获取设备信息
      IMobileDevice: () => IMobileDevice(),

      ///IOS模拟器工具
      IOSSimulatorUtils: () => IOSSimulatorUtils(),
      IOSWorkflow: () => const IOSWorkflow(),

      ///IOSKernel编译工具
      KernelCompilerFactory: () => const KernelCompilerFactory(),
      LinuxWorkflow: () => const LinuxWorkflow(),
      Logger: () => platform.isWindows ? WindowsStdoutLogger() : StdoutLogger(),
      MacOSWorkflow: () => const MacOSWorkflow(),
      MDnsObservatoryDiscovery: () => MDnsObservatoryDiscovery(),

      ///操作系统工具
      OperatingSystemUtils: () => OperatingSystemUtils(),
      SimControl: () => SimControl(),
      Stdio: () => const Stdio(),

      ///设计配置
      SystemClock: () => const SystemClock(),
      TimeoutConfiguration: () => const TimeoutConfiguration(),

      ///Flutter开发工具
      Usage: () => Usage(),
      UserMessages: () => UserMessages(),
      VisualStudio: () => VisualStudio(),
      VisualStudioValidator: () => const VisualStudioValidator(),

      ///web开发工具
      WebWorkflow: () => const WebWorkflow(),
      WindowsWorkflow: () => const WindowsWorkflow(),

      ///Xcode开发工具
      Xcode: () => Xcode(),
      XcodeValidator: () => const XcodeValidator(),
      XcodeProjectInterpreter: () => XcodeProjectInterpreter(),
    },
  );
}
```
## AppContext
`lib/executable.dart`中的run方法中构建的`overrides`
`lib/runner.dart`的runInContext方法中传入的回调函数作为`body`
`lib/src/context_runner.dart`的`context.run`中的`fallbacks`传入环境参数工具链、开发工具的加载的内容
`AppContext`:负责作为Zone和外部逻辑的的沟通渠道

```dart
Future<V> run<V>({
  @required FutureOr<V> body(),
  String name,
  Map<Type, Generator> overrides,
  Map<Type, Generator> fallbacks,
  ZoneSpecification zoneSpecification,
}) async {
  ///App的运行环境
  final AppContext child = AppContext._(
    this,
    name,
    Map<Type, Generator>.unmodifiable(overrides ?? const <Type, Generator>{}),
    Map<Type, Generator>.unmodifiable(fallbacks ?? const <Type, Generator>{}),
  );

  ///提交数据到DartVM真正运行
  return await runZoned<Future<V>>(
    () async => await body(),
    zoneValues: <_Key, AppContext>{_Key.key: child},
    zoneSpecification: zoneSpecification,
  );
}

```
在运行所需要的环境加载之后，就提交相关的逻辑到Zone中的运行执行body
``` dart
///提交数据到DartVM真正运行
    return await runZoned<Future<V>>(
      () async => await body(),
      zoneValues: <_Key, AppContext>{_Key.key: child},
      zoneSpecification: zoneSpecification,
    );
```
### AppContext：get获取虚拟机加载的资源

```dart
/// Gets the value associated with the specified [type], or `null` if no
/// such value has been associated.
T get<T>() {
  dynamic value = _generateIfNecessary(T, _overrides);
  if (value == null && _parent != null) {
    value = _parent.get<T>();
  }
  return _unboxNull(value ?? _generateIfNecessary(T, _fallbacks)) as T;
}
```

### lib/runner.dart:body
1.设置系统环境

2.添加实现的命令行工具，进行初始化

3.初始化运行环境

4.运行代码到dartVM的Zoned中

5.调用命令行实现子类


body开始执行`FlutterCommandRunner`run方法，
```dart
/// Runs the Flutter tool with support for the specified list of [commands].
Future<int> run(
  List<String> args,
  List<FlutterCommand> commands, {
  bool muteCommandLogging = false,
  bool verbose = false,
  bool verboseHelp = false,
  bool reportCrashes,
  String flutterVersion,
  Map<Type, Generator> overrides,
}) {
  reportCrashes ??= !isRunningOnBot;

  if (muteCommandLogging) {
    // Remove the verbose option; for help and doctor, users don't need to see
    // verbose logs.
    args = List<String>.from(args);
    args.removeWhere(
        (String option) => option == '-v' || option == '--verbose');
  }

  ///设置系统环境
  final FlutterCommandRunner runner =
      FlutterCommandRunner(verboseHelp: verboseHelp);

  ///添加实现的命令行工具，进行初始化
  commands.forEach(runner.addCommand);

  ///初始化运行环境
  return runInContext<int>(() async {
    // Initialize the system locale.
    final String systemLocale = await intl_standalone.findSystemLocale();
    intl.Intl.defaultLocale = intl.Intl.verifiedLocale(
      systemLocale,
      intl.NumberFormat.localeExists,
      onFailure: (String _) => 'en_US',
    );

    String getVersion() =>
        flutterVersion ??
        FlutterVersion.instance.getVersionString(redactUnknownBranches: true);
    Object firstError;
    StackTrace firstStackTrace;

    ///运行代码到dartVM的Zoned中
    return await runZoned<Future<int>>(() async {
      try {
        ///调用命令行实现子类
        await runner.run(args);
        return await _exit(0);
      } catch (error, stackTrace) {
        firstError = error;
        firstStackTrace = stackTrace;
        return await _handleToolError(
            error, stackTrace, verbose, args, reportCrashes, getVersion);
      }
    }, onError: (Object error, StackTrace stackTrace) async {
      // If sending a crash report throws an error into the zone, we don't want
      // to re-try sending the crash report with *that* error. Rather, we want
      // to send the original error that triggered the crash report.
      final Object e = firstError ?? error;
      final StackTrace s = firstStackTrace ?? stackTrace;
      await _handleToolError(e, s, verbose, args, reportCrashes, getVersion);
    });
  }, overrides: overrides);
}

```

## FlutterCommandRunner:run&CommandRunner:runCommand
1.解析命令行传入的，并且进行解析构建运行命令

2.调用Command的子类FlutterCommand中的run方法
```dart
Future<T> runCommand(ArgResults topLevelResults) async {
    var argResults = topLevelResults;
    var commands = _commands;
    Command command;
    var commandString = executableName;

    while (commands.isNotEmpty) {
      ......

      // Step into the command.
      argResults = argResults.command;
      command = commands[argResults.name];
      command._globalResults = topLevelResults;
      command._argResults = argResults;
      commands = command._subcommands;
      commandString += " ${argResults.name}";
    }
    ........
    return (await command.run()) as T;
  }

```

## FlutterCommand:run()
1.获取AppContext

2.运行代码到Zone中执行，初始化相关的上下文环境

3.调用子类的
```dart
@override
Future<void> run() {
  final DateTime startTime = systemClock.now();

  ///加载Flutter中的上下文加载的数据
  return context.run<void>(
    name: 'command',
    overrides: <Type, Generator>{FlutterCommand: () => this},
    body: () async {
      if (flutterUsage.isFirstRun) {
        flutterUsage.printWelcome();
      }
      final String commandPath = await usagePath;
      FlutterCommandResult commandResult;
      try {
        commandResult = await verifyThenRunCommand(commandPath);
      } on ToolExit {
        commandResult = const FlutterCommandResult(ExitStatus.fail);
        rethrow;
      } finally {
        final DateTime endTime = systemClock.now();
        printTrace(userMessages.flutterElapsedTime(
            name, getElapsedAsMilliseconds(endTime.difference(startTime))));
        _sendPostUsage(commandPath, commandResult, startTime, endTime);
      }
    },
  );
}
```
### AppContext
获取加载到Zone中的资源
```dart
/// The current [AppContext], as determined by the [Zone] hierarchy.
///
/// This will be the first context found as we scan up the zone hierarchy, or
/// the "root" context if a context cannot be found in the hierarchy. The root
/// context will not have any values associated with it.
///
/// This is guaranteed to never return `null`.
AppContext get context =>
    Zone.current[_Key.key] as AppContext ?? AppContext._root;
```

### FlutterCommand:verifyThenRunCommand
1.验证`pubspec.yaml`

2.验证`flutter.yaml`

3.加载不同平台的Artifacts

4.pubGet加载第三方包

5.初始化工程目录`FlutterProject`

6.加载工具链

7.设置不同平台的包文婧处理路劲和文件

8.运行runCommand执行实现的命令子类

```dart
@mustCallSuper
Future<FlutterCommandResult> verifyThenRunCommand(String commandPath) async {
  await validateCommand();

  // Populate the cache. We call this before pub get below so that the sky_engine
  // package is available in the flutter cache for pub to find.
  if (shouldUpdateCache) {
    await cache.updateAll(await requiredArtifacts);
  }

  if (shouldRunPub) {
    await pubGet(context: PubContext.getVerifyContext(name));
    final FlutterProject project = FlutterProject.current();
    await project.ensureReadyForPlatformSpecificTooling(checkProjects: true);
  }

  setupApplicationPackages();

  if (commandPath != null) {
    final Map<CustomDimensions, String> additionalUsageValues =
        <CustomDimensions, String>{
      ...?await usageValues,
      CustomDimensions.commandHasTerminal:
          io.stdout.hasTerminal ? 'true' : 'false',
    };
    Usage.command(commandPath, parameters: additionalUsageValues);
  }

  return await runCommand();
}
```
## RunCommand:runCommand
真正运行打包的过程，不同的平台都是在这个方法中开始进行打包，上面的执行构成都是在构成环境信息和相关的路径信息
1.初始化相关的运行设备

2.两种模式运行代码HotRunner、ColdRunner

3.调用上面的两种运行模式其中一种的`runner.run`方法开始调用本地编译环境开始编译不同平台的包

```dart
@override
Future<FlutterCommandResult> runCommand() async {
.......
遍历所有的工具
  for (Device device in devices) {
    if (await device.isLocalEmulator) {
......
  }

  if (hotMode) {
    for (Device device in devices) {
      if (!device.supportsHotReload)
        throwToolExit('Hot reload is not supported by ${device.name}. Run with --no-hot.');
    }
  }

  List<String> expFlags;
  if (argParser.options.containsKey(FlutterOptions.kEnableExperiment) &&
      argResults[FlutterOptions.kEnableExperiment].isNotEmpty) {
    expFlags = argResults[FlutterOptions.kEnableExperiment];
  }
  final List<FlutterDevice> flutterDevices = <FlutterDevice>[];
  final FlutterProject flutterProject = FlutterProject.current();
  for (Device device in devices) {
    final FlutterDevice flutterDevice = await FlutterDevice.create(
      device,
      flutterProject: flutterProject,
      trackWidgetCreation: argResults['track-widget-creation'],
      fileSystemRoots: argResults['filesystem-root'],
      fileSystemScheme: argResults['filesystem-scheme'],
      viewFilter: argResults['isolate-filter'],
      experimentalFlags: expFlags,
      target: argResults['target'],
      buildMode: getBuildMode(),
    );
    flutterDevices.add(flutterDevice);
  }
  // Only support "web mode" with a single web device due to resident runner
  // refactoring required otherwise.
  final bool webMode = featureFlags.isWebEnabled &&
                       devices.length == 1  &&
                       await devices.single.targetPlatform == TargetPlatform.web_javascript;

  ResidentRunner runner;
  final String applicationBinaryPath = argResults['use-application-binary'];
  if (hotMode && !webMode) {
    runner = HotRunner(
      flutterDevices,
      target: targetFile,
      debuggingOptions: _createDebuggingOptions(),
      benchmarkMode: argResults['benchmark'],
      applicationBinary: applicationBinaryPath == null
          ? null
          : fs.file(applicationBinaryPath),
      projectRootPath: argResults['project-root'],
      packagesFilePath: globalResults['packages'],
      dillOutputPath: argResults['output-dill'],
      stayResident: stayResident,
      ipv6: ipv6,
    );
  } else if (webMode) {
    runner = webRunnerFactory.createWebRunner(
      devices.single,
      target: targetFile,
      flutterProject: flutterProject,
      ipv6: ipv6,
      debuggingOptions: _createDebuggingOptions(),
    );
  } else {
    runner = ColdRunner(
      flutterDevices,
      target: targetFile,
      debuggingOptions: _createDebuggingOptions(),
      traceStartup: traceStartup,
      awaitFirstFrameWhenTracing: awaitFirstFrameWhenTracing,
      applicationBinary: applicationBinaryPath == null
          ? null
          : fs.file(applicationBinaryPath),
      ipv6: ipv6,
      stayResident: stayResident,
    );
  }

  DateTime appStartedTime;
  // Sync completer so the completing agent attaching to the resident doesn't
  // need to know about analytics.
  //
  // Do not add more operations to the future.
  final Completer<void> appStartedTimeRecorder = Completer<void>.sync();
  // This callback can't throw.
  unawaited(appStartedTimeRecorder.future.then<void>(
    (_) {
      appStartedTime = systemClock.now();
      if (stayResident) {
        TerminalHandler(runner)
          ..setupTerminal()
          ..registerSignalHandlers();
      }
    }
  ));

  final int result = await runner.run(
    appStartedCompleter: appStartedTimeRecorder,
    route: route,
  );
  if (result != 0) {
    throwToolExit(null, exitCode: result);
  }
  return FlutterCommandResult(
    ExitStatus.success,
    timingLabelParts: <String>[
      hotMode ? 'hot' : 'cold',
      getModeName(getBuildMode()),
      devices.length == 1
          ? getNameForTargetPlatform(await devices[0].targetPlatform)
          : 'multiple',
      devices.length == 1 && await devices[0].isLocalEmulator ? 'emulator' : null,
    ],
    endTimeOverride: appStartedTime,
  );
}
```

## HotRunner
遍历所有的设备进行执行编译

```dart
@override
Future<int> run({
  Completer<DebugConnectionInfo> connectionInfoCompleter,
  Completer<void> appStartedCompleter,
  String route,
}) async {
  if (!fs.isFileSync(mainPath)) {
    String message = 'Tried to run $mainPath, but that file does not exist.';
    if (target == null)
      message += '\nConsider using the -t option to specify the Dart file to start.';
    printError(message);
    return 1;
  }

  firstBuildTime = DateTime.now();

  for (FlutterDevice device in flutterDevices) {
    final int result = await device.runHot(
      hotRunner: this,
      route: route,
    );
    if (result != 0) {
      return result;
    }
  }

  return attach(
    connectionInfoCompleter: connectionInfoCompleter,
    appStartedCompleter: appStartedCompleter,
  );
}
```

## Device
不同的平台进行编译的的过程是通过`Device`来进行处理的，后面我们将对不同的平台进行编译，发布，运行处理
