# Flutter 生命周期的调用
WidgetsBindingObserver
AppLifecycleState

```Dart

// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

class LifecycleWatcher extends StatefulWidget {
  const LifecycleWatcher({Key key}) : super(key: key);

  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    return super.didPopRoute();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    return super.didPushRoute(route);
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
    super.didChangeAccessibilityFeatures();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastLifecycleState == null)
      return const Text('This widget has not observed any lifecycle changes.');
    return Text(
        'The most recent lifecycle state this widget observed was: $_lastLifecycleState.');
  }
}

void main() {
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: LifecycleWatcher(),
      ),
    ),
  );
}

```
## State 生命周期(具体使用场景)
initState  初始化是注册
  ChangeNotifier
  Stream
build
didUpdateWidget  Widget更新之后调用

didChangeDependencies  BuildContext.inheritFromWidgetOfExactType  访问管理的数据
dispose   Widge已经销毁之后，进行清理工作
