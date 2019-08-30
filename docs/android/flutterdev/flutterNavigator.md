# Flutter 导航


## 概述


在安卓中一个rout对应一个Activity，在IOS中一个Route对应一个ViewController,`在Flutter中一个route对应一个Widget`

在两个界面接导航使用`Navigator`

    Navigator.push().
    Navigator.pop().

## Android&IOS启动调用路由传递参数

```Dart

/// See also:
///
///  * [Navigator], a widget that handles routing.
///  * [SystemChannels.navigation], which handles subsequent navigation
///    requests from the embedder.
String get defaultRouteName => _defaultRouteName();
String _defaultRouteName() native 'Window_defaultRouteName';
```


```Dart

在营业程序启动时调用路由功能和传递参数
没有指定路由，缺省理由是`/`

### Android

```Java
public class AnotherActivity extends FlutterActivity {
    @Override
    public FlutterView createFlutterView(Context context) {

        WindowManager.LayoutParams matchParent = new WindowManager.LayoutParams(-1, -1);
        FlutterNativeView nativeView = this.createFlutterNativeView();
        FlutterView flutterView = new FlutterView(this, (AttributeSet) null, nativeView);
        flutterView.setInitialRoute("/route1");
        flutterView.setLayoutParams(matchParent);
        this.setContentView(flutterView);
        return flutterView;
    }
}
```

```Dart
void main() => runApp(InitPage());

class InitPage extends StatelessWidget {
  var temp = window.defaultRouteName;
  @override
  Widget build(BuildContext context) {
    print('Flutter routes $temp');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        "/": (context) {
          print('show times');
          DefaultPage();
        },
        "/route1": (context) {
            print('show route1');
            MyApp();
         },
        "/route2": (context) => DefaultPage(),
      },
    );
  }
}
```
### iOS
///
/// On iOS, calling
/// [`FlutterViewController.setInitialRoute`](/objcdoc/Classes/FlutterViewController.html#/c:objc%28cs%29FlutterViewController%28im%29setInitialRoute:)
/// will set this value. The value must be set sufficiently early, i.e. before
/// the [runApp] call is executed in Dart, for this to have any effect on the
/// framework. The `application:didFinishLaunchingWithOptions:` method is a
/// suitable time to set this value.
///

## Navogator初始化过程

`WidgetsApp`对Widget做了一个顶层封装
1.Navigator
2.Localizations
3.DefaultTextStyle
4.MediaQuery

在WidgetsAppBuilder中实例化`Navigator`初始化Flutter层的逻辑
```Dart
@override
  Widget build(BuildContext context) {
    Widget navigator;
    if (_navigator != null) {
      navigator = Navigator(
        key: _navigator,
        // If window.defaultRouteName isn't '/', we should assume it was set
        // intentionally via `setInitialRoute`, and should override whatever
        // is in [widget.initialRoute].
        initialRoute: WidgetsBinding.instance.window.defaultRouteName != Navigator.defaultRouteName
            ? WidgetsBinding.instance.window.defaultRouteName
            : widget.initialRoute ?? WidgetsBinding.instance.window.defaultRouteName,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
        observers: widget.navigatorObservers,
      );
    }
```
`MaterialApp`的build函数中对`WidgetsApp`进行封装
```Dart

@override
Widget build(BuildContext context) {
  Widget result = WidgetsApp(
    key: GlobalObjectKey(this),
    navigatorKey: widget.navigatorKey,
    navigatorObservers: _navigatorObservers,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          MaterialPageRoute<T>(settings: settings, builder: builder),
    home: widget.home,
    routes: widget.routes,
    initialRoute: widget.initialRoute,
    onGenerateRoute: widget.onGenerateRoute,
    onUnknownRoute: widget.onUnknownRoute,
    builder: (BuildContext context, Widget child) {
      // Use a light theme, dark theme, or fallback theme.
      ThemeData theme;
      final ui.Brightness platformBrightness = MediaQuery.platformBrightnessOf(context);
      if (platformBrightness == ui.Brightness.dark && widget.darkTheme != null) {
        theme = widget.darkTheme;
      } else if (widget.theme != null) {
        theme = widget.theme;
      } else {
        theme = ThemeData.fallback();
      }

      return AnimatedTheme(
        data: theme,
        isMaterialAppTheme: true,
        child: widget.builder != null
            ? Builder(
                builder: (BuildContext context) {
                  return widget.builder(context, child);
                },
              )
            : child,
      );
    },
  );

```

## 在不同的平台之间使用不同的动画

## 监听Scheduler生命周期变化
```Dart
if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
        overlay._remove(this);
      });
    }
```
