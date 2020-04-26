# device
fluttertools 使用Devices来对不同平台进行处理平台之间的差异


## RunCommand

```dart
@override
Future<FlutterCommandResult> runCommand() async {
  Cache.releaseLockEarly();
  final bool hotMode = shouldUseHotMode();
........
  ///FlutterDevice不同平台的设备
  final List<FlutterDevice> flutterDevices = <FlutterDevice>[];
  ///获取开发的工程目录
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
## DeviceManager&DeviceDiscovery
FlutterTools 来管理不同的运行平台，每一个平台的通过Device来实现设备的查找,PollingDeviceDiscovery类进行设备的发现协议的管理，DeviceManager管理所有平台的设备，提供给不同平台的Device实现

```dart
AndroidDevices (android_device.dart)
FlutterTesterDevices (flutter_tester.dart)
WebDevices (web_device.dart)
FuchsiaDevices (fuchsia_device.dart)
IOSDevices (devices.dart)
IOSSimulators (simulators.dart)
LinuxDevices (linux_device.dart)
MacOSDevices (macos_device.dart)
WindowsDevices (windows_device.dart)
MockPollingDeviceDiscovery (mocks.dart)
```
下面接着实现不同平台Device实现相关的管理
1.查询不同的设备运行环境

2.FlutterDevice进行不同平台的运行管理，进行Flutter编译

```dart
DeviceManager get deviceManager => context.get<DeviceManager>();
/// Find and return all target [Device]s based upon currently connected
  /// devices and criteria entered by the user on the command line.
  /// If no device can be found that meets specified criteria,
  /// then print an error message and return null.
  Future<List<Device>> findAllTargetDevices() async {
    if (!doctor.canLaunchAnything) {
      printError(userMessages.flutterNoDevelopmentDevice);
      return null;
    }

    List<Device> devices =
        await deviceManager.findTargetDevices(FlutterProject.current());

    if (devices.isEmpty && deviceManager.hasSpecifiedDeviceId) {
      printStatus(userMessages
          .flutterNoMatchingDevice(deviceManager.specifiedDeviceId));
      return null;
    } else if (devices.isEmpty && deviceManager.hasSpecifiedAllDevices) {
      printStatus(userMessages.flutterNoDevicesFound);
      return null;
    } else if (devices.isEmpty) {
      printStatus(userMessages.flutterNoSupportedDevices);
      return null;
    } else if (devices.length > 1 && !deviceManager.hasSpecifiedAllDevices) {
      if (deviceManager.hasSpecifiedDeviceId) {
        printStatus(userMessages.flutterFoundSpecifiedDevices(
            devices.length, deviceManager.specifiedDeviceId));
      } else {
        printStatus(userMessages.flutterSpecifyDeviceWithAllOption);
        devices = await deviceManager.getAllConnectedDevices().toList();
      }
      printStatus('');
      await Device.printDevices(devices);
      return null;
    }
    return devices;
  }
```

## FlutterDevice
1.CodeGeneratingResidentCompiler:管理Dart代码的编译过程

2.CodeGenerator的实现类`BuildRunner`正在的编译执行过程

```dart
/// Create a [FlutterDevice] with optional code generation enabled.
static Future<FlutterDevice> create(
  Device device, {
  @required FlutterProject flutterProject,
  @required bool trackWidgetCreation,
  @required String target,
  @required BuildMode buildMode,
  List<String> fileSystemRoots,
  String fileSystemScheme,
  String viewFilter,
  TargetModel targetModel = TargetModel.flutter,
  List<String> experimentalFlags,
  ResidentCompiler generator,
}) async {
  ResidentCompiler generator;
  if (flutterProject.hasBuilders) {
    generator = await CodeGeneratingResidentCompiler.create(
      flutterProject: flutterProject,
    );
  } else {
    generator = ResidentCompiler(
      artifacts.getArtifactPath(Artifact.flutterPatchedSdkPath, mode: buildMode),
      trackWidgetCreation: trackWidgetCreation,
      fileSystemRoots: fileSystemRoots,
      fileSystemScheme: fileSystemScheme,
      targetModel: targetModel,
      experimentalFlags: experimentalFlags,
    );
  }
  return FlutterDevice(
    device,
    trackWidgetCreation: trackWidgetCreation,
    fileSystemRoots: fileSystemRoots,
    fileSystemScheme:fileSystemScheme,
    viewFilter: viewFilter,
    experimentalFlags: experimentalFlags,
    targetModel: targetModel,
    generator: generator,
    buildMode: buildMode,
  );
}
```

## CodeGeneratingResidentCompiler


```dart
static Future<ResidentCompiler> create({
    @required FlutterProject flutterProject,
    bool trackWidgetCreation = false,
    CompilerMessageConsumer compilerMessageConsumer = printError,
    bool unsafePackageSerialization = false,
    String outputPath,
    String initializeFromDill,
    bool runCold = false,
  }) async {
    codeGenerator.updatePackages(flutterProject);
    final ResidentCompiler residentCompiler = ResidentCompiler(
      artifacts.getArtifactPath(Artifact.flutterPatchedSdkPath),
      trackWidgetCreation: trackWidgetCreation,
      packagesPath: PackageMap.globalGeneratedPackagesPath,
      fileSystemRoots: <String>[
        fs.path.join(flutterProject.generated.path, 'lib${platform.pathSeparator}'),
        fs.path.join(flutterProject.directory.path, 'lib${platform.pathSeparator}'),
      ],
      fileSystemScheme: kMultiRootScheme,
      targetModel: TargetModel.flutter,
      unsafePackageSerialization: unsafePackageSerialization,
      initializeFromDill: initializeFromDill,
    );
    if (runCold) {
      return residentCompiler;
    }
    ///开始编译
    final CodegenDaemon codegenDaemon = await codeGenerator.daemon(flutterProject);
    codegenDaemon.startBuild();
    final CodegenStatus status = await codegenDaemon.buildResults.firstWhere((CodegenStatus status) {
      return status == CodegenStatus.Succeeded || status == CodegenStatus.Failed;
    });
    if (status == CodegenStatus.Failed) {
      printError('Code generation failed, build may have compile errors.');
    }
    return CodeGeneratingResidentCompiler._(residentCompiler, codegenDaemon, flutterProject);
  }

```

## BuildRunner:daemon

```dart
@override
Future<CodegenDaemon> daemon(
  FlutterProject flutterProject, {
  String mainPath,
  bool linkPlatformKernelIn = false,
  bool targetProductVm = false,
  bool trackWidgetCreation = false,
  List<String> extraFrontEndOptions = const <String>[],
}) async {
  await generateBuildScript(flutterProject);
  final String engineDartBinaryPath =
      artifacts.getArtifactPath(Artifact.engineDartBinary);
  final File buildSnapshot = flutterProject.dartTool
      .childDirectory('build')
      .childDirectory('entrypoint')
      .childFile('build.dart.snapshot');
  final String scriptPackagesPath = flutterProject.dartTool
      .childDirectory('flutter_tool')
      .childFile('.packages')
      .path;
  final Status status =
      logger.startProgress('starting build daemon...', timeout: null);
  BuildDaemonClient buildDaemonClient;
  try {
    final List<String> command = <String>[
      engineDartBinaryPath,
      '--packages=$scriptPackagesPath',
      buildSnapshot.path,
      'daemon',
      '--skip-build-script-check',
      '--delete-conflicting-outputs',
    ];
    buildDaemonClient = await BuildDaemonClient.connect(
        flutterProject.directory.path, command, logHandler: (ServerLog log) {
      if (log.message != null) {
        printTrace(log.message);
      }
    });
  } finally {
    status.stop();
  }
  // Empty string indicates we should build everything.
  final OutputLocation outputLocation = OutputLocation(
    (OutputLocationBuilder b) => b
      ..output = ''
      ..useSymlinks = false
      ..hoist = false,
  );
  buildDaemonClient.registerBuildTarget(
      DefaultBuildTarget((DefaultBuildTargetBuilder builder) {
    builder.target = 'lib';
    builder.outputLocation = outputLocation.toBuilder();
  }));
  buildDaemonClient.registerBuildTarget(
      DefaultBuildTarget((DefaultBuildTargetBuilder builder) {
    builder.target = 'test';
    builder.outputLocation = outputLocation.toBuilder();
  }));
  return _BuildRunnerCodegenDaemon(buildDaemonClient);
}

```
## BuildRunner:generateBuildScript
1.下载Flutter相关的package

2.读取Flutter项目下的包依赖图谱关系

3.构建编译脚本

4.读取项目下的build.yaml

5.开启多线程编译项目文件

```dart
@override
Future<void> generateBuildScript(FlutterProject flutterProject) async {
  final Directory entrypointDirectory = fs.directory(
      fs.path.join(flutterProject.dartTool.path, 'build', 'entrypoint'));
  final Directory generatedDirectory = fs
      .directory(fs.path.join(flutterProject.dartTool.path, 'flutter_tool'));
  final File buildScript = entrypointDirectory.childFile('build.dart');
  final File buildSnapshot =
      entrypointDirectory.childFile('build.dart.snapshot');
  final File scriptIdFile = entrypointDirectory.childFile('id');
  final File syntheticPubspec = generatedDirectory.childFile('pubspec.yaml');

  // Check if contents of builders changed. If so, invalidate build script
  // and regenerate.
  final YamlMap builders = flutterProject.builders;
  final List<int> appliedBuilderDigest = _produceScriptId(builders);
  if (scriptIdFile.existsSync() && buildSnapshot.existsSync()) {
    final List<int> previousAppliedBuilderDigest =
        scriptIdFile.readAsBytesSync();
    bool digestsAreEqual = false;
    if (appliedBuilderDigest.length == previousAppliedBuilderDigest.length) {
      digestsAreEqual = true;
      for (int i = 0; i < appliedBuilderDigest.length; i++) {
        if (appliedBuilderDigest[i] != previousAppliedBuilderDigest[i]) {
          digestsAreEqual = false;
          break;
        }
      }
    }
    if (digestsAreEqual) {
      return;
    }
  }
  // Clean-up all existing artifacts.
  if (flutterProject.dartTool.existsSync()) {
    flutterProject.dartTool.deleteSync(recursive: true);
  }
  final Status status =
      logger.startProgress('generating build script...', timeout: null);
  try {
    generatedDirectory.createSync(recursive: true);
    entrypointDirectory.createSync(recursive: true);
    flutterProject.dartTool
        .childDirectory('build')
        .childDirectory('generated')
        .createSync(recursive: true);
    final StringBuffer stringBuffer = StringBuffer();

    stringBuffer.writeln('name: flutter_tool');
    stringBuffer.writeln('dependencies:');
    final YamlMap builders = flutterProject.builders;
    if (builders != null) {
      for (String name in builders.keys) {
        final Object node = builders[name];
        // For relative paths, make sure it is accounted for
        // parent directories.
        if (node is YamlMap && node['path'] != null) {
          final String path = node['path'];
          if (fs.path.isRelative(path)) {
            final String convertedPath =
                fs.path.join('..', '..', node['path']);
            stringBuffer.writeln('  $name:');
            stringBuffer.writeln('    path: $convertedPath');
          } else {
            stringBuffer.writeln('  $name: $node');
          }
        } else {
          stringBuffer.writeln('  $name: $node');
        }
      }
    }
    stringBuffer.writeln('  build_runner: ^$kMinimumBuildRunnerVersion');
    stringBuffer.writeln('  build_daemon: $kSupportedBuildDaemonVersion');
    await syntheticPubspec.writeAsString(stringBuffer.toString());

    ///下载Flutter相关的package
    await pubGet(
      context: PubContext.pubGet,
      directory: generatedDirectory.path,
      upgrade: false,
      checkLastModified: false,
    );
    if (!scriptIdFile.existsSync()) {
      scriptIdFile.createSync(recursive: true);
    }
    scriptIdFile.writeAsBytesSync(appliedBuilderDigest);

    ///读取Flutter项目下的包依赖图谱关系
    final PackageGraph packageGraph =
        PackageGraph.forPath(syntheticPubspec.parent.path);

    ///构建编译脚本
    final BuildScriptGenerator buildScriptGenerator =
        const BuildScriptGeneratorFactory()
            .create(flutterProject, packageGraph);

    ///读取项目下的build.yaml
    await buildScriptGenerator.generateBuildScript();

    ///开启多线程编译项目文件
    final ProcessResult result = await processManager.run(<String>[
      artifacts.getArtifactPath(Artifact.engineDartBinary),
      '--snapshot=${buildSnapshot.path}',
      '--snapshot-kind=app-jit',
      '--packages=${fs.path.join(generatedDirectory.path, '.packages')}',
      buildScript.path,
    ]);
    if (result.exitCode != 0) {
      throwToolExit(
          'Error generating build_script snapshot: ${result.stderr}');
    }
  } finally {
    status.stop();
  }
}

```

## TargetPlatform

enum TargetPlatform {
  android_arm,
  android_arm64,
  android_x64,
  android_x86,
  ios,
  darwin_x64,
  linux_x64,
  windows_x64,
  fuchsia,
  tester,
  web_javascript,
}

## HostPlatform
enum HostPlatform {
  darwin_x64,
  linux_x64,
  windows_x64,
}

## AndroidArch

enum AndroidArch {
  armeabi_v7a,
  arm64_v8a,
  x86,
  x86_64,
}
## DarwinArch
enum DarwinArch {
  armv7,
  arm64,
  x86_64,
}
## BuildInfo
const BuildInfo(
  this.mode,
  this.flavor, {
  this.trackWidgetCreation = false,
  this.extraFrontEndOptions,
  this.extraGenSnapshotOptions,
  this.fileSystemRoots,
  this.fileSystemScheme,
  this.buildNumber,
  this.buildName,
});

## BuildMode
/// The type of build.
enum BuildMode {
  debug,
  profile,
  release,
}
## PlatformType
/// The platform sub-folder that a device type supports.
class PlatformType {
  const PlatformType._(this.value);

  static const PlatformType web = PlatformType._('web');
  static const PlatformType android = PlatformType._('android');
  static const PlatformType ios = PlatformType._('ios');
  static const PlatformType linux = PlatformType._('linux');
  static const PlatformType macos = PlatformType._('macos');
  static const PlatformType windows = PlatformType._('windows');
  static const PlatformType fuchsia = PlatformType._('fuchsia');

  final String value;

  @override
  String toString() => value;
}
