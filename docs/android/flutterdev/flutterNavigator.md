# Flutter 导航


## 概述
在安卓中一个route对应一个Activity，在IOS中一个Route对应一个ViewController,`在Flutter中一个route对应一个Widget`

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


在App程序启动时调用路由功能和传递参数
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
## Navigator 核心逻辑

### `初始化过程`

    1.`_WidgetsAppState`build方法中对Navigator进行实例化，判断当前的默认路由和` window.defaultRouteName`是否一致，优先使用`WidgetsBinding.instance.window.defaultRouteName`
    2.调用`_onGenerateRoute`初始化传入的路由信息
    3.处理`_onUnknownRoute`未知路由信息
    4.出路`NavigatorObserver`导航观察者对象
    5.使用`OverlayEntry`实体管理导航顺序，`_initialOverlayEntries = <OverlayEntry>[];`
    6.使用`Listener`来对鼠标事件进行监听管理
    7.使用`AbsorbPointer`拦截事件，是否可以传入子树中
    8.使用`FocusScope`管理相关的焦点事件
    9.`Overlay`内部使用`Stack`控件对导航中的Widget进行UI汇总摆放的位置进行处理
    10.`Route`中保存
        10.1：NavigatorState
        10.2：RouteSettings
        10.3：const <OverlayEntry>[];


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
## Navigator源码解析
Navigator构造函数
在`MaterialApp`的构造函数中传入相关的路由构造参数，在`build`
`Navigator`中组要的类:

      NavigatorObserver：一个借口、导航切换是能够监听导航切换的动作，在切换的时候处理自己的业务逻辑
      RouteSettings:页面间进行导航是对数据的一个封装
      OverlayState:State对象，构建有状态的Widget，使用`Stack`对`List<OverlayEntry>`中的Widget进行排序和绘制
      Route：管理Widget的逻辑顺序和相关的业务逻辑，和每个OverlayEntry
      FocusScopeNode:
      OverlayEntry：对每一个Wiget进行封装和管理，进行Widget逻辑排序和数据保存，`List<OverlayEntry>`
      TickerProviderStateMixin

路由参数传输的类型:(能够传递自定义类，那么就意味着可以传输任意类型的数据)
String
int
Object
Map


```Dart
class Navigator extends StatefulWidget {
  /// Creates a widget that maintains a stack-based history of child widgets.
  /// The [onGenerateRoute] argument must not be null.
  const Navigator({
    Key key,
    this.initialRoute,
    @required this.onGenerateRoute,
    this.onUnknownRoute,
    this.observers = const <NavigatorObserver>[],
  }) : assert(onGenerateRoute != null),
       super(key: key);

  final String initialRoute;
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;
  final List<NavigatorObserver> observers;
  static const String defaultRouteName = '/';

  static NavigatorState of(
    BuildContext context, {
    bool rootNavigator = false,
    bool nullOk = false,
  }) {
    final NavigatorState navigator = rootNavigator
        ? context.rootAncestorStateOfType(const TypeMatcher<NavigatorState>())
        : context.ancestorStateOfType(const TypeMatcher<NavigatorState>());
    assert(() {
      if (navigator == null && !nullOk) {
        throw FlutterError(
          'Navigator operation requested with a context that does not include a Navigator.\n'
          'The context used to push or pop routes from the Navigator must be that of a '
          'widget that is a descendant of a Navigator widget.'
        );
      }
      return true;
    }());
    return navigator;
  }

  @override
  NavigatorState createState() => NavigatorState();
}

```
NavigatorState核心逻辑:

    1.定义`_history = <Route<dynamic>>[];`对路由器进行管理
    2.定义`_initialOverlayEntries = <OverlayEntry>[];`保存每一个Widget页面对象，管理`Widget`在`Stack`中的位置
    3.初始化`NavigatorObserver`对象
    4.处理初始化路由`initialRouteName`
    5.构建`_routeNamed`对象
    6.处理在`Navigator`上使用的点击、手势、焦点进行处理
      6.1 `Listener`处理鼠标事件
      6.2 `AbsorbPointer`对事件进行拦截
      6.3 `FocusScope`焦点处理
      6.4 `Overlay`封装`Stack`对`OverlayEntry`中对应的Widget进行渲染

```Dart
@override
class NavigatorState extends State<Navigator> with TickerProviderStateMixin {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  final List<Route<dynamic>> _history = <Route<dynamic>>[];
  final Set<Route<dynamic>> _poppedRoutes = <Route<dynamic>>{};
  final FocusScopeNode focusScopeNode = FocusScopeNode(debugLabel: 'Navigator Scope');
  final List<OverlayEntry> _initialOverlayEntries = <OverlayEntry>[];

  @override
  void initState() {
    super.initState();
    ///初始化观察者对象
    for (NavigatorObserver observer in widget.observers) {
      assert(observer.navigator == null);
      observer._navigator = this;
    }
    ///处理初始化路由
    String initialRouteName = widget.initialRoute ?? Navigator.defaultRouteName;
    if (initialRouteName.startsWith('/') && initialRouteName.length > 1) {
      initialRouteName = initialRouteName.substring(1); // strip leading '/'
      assert(Navigator.defaultRouteName == '/');
      final List<String> plannedInitialRouteNames = <String>[
        Navigator.defaultRouteName,
      ];
      final List<Route<dynamic>> plannedInitialRoutes = <Route<dynamic>>[
        _routeNamed<dynamic>(Navigator.defaultRouteName, allowNull: true, arguments: null),
      ];
      final List<String> routeParts = initialRouteName.split('/');
      if (initialRouteName.isNotEmpty) {
        String routeName = '';
        for (String part in routeParts) {
          routeName += '/$part';
          plannedInitialRouteNames.add(routeName);
          plannedInitialRoutes.add(_routeNamed<dynamic>(routeName, allowNull: true, arguments: null));
        }
      }
      ......
    for (Route<dynamic> route in _history)
      _initialOverlayEntries.addAll(route.overlayEntries);
  }
  OverlayState get overlay => _overlayKey.currentState;

  OverlayEntry get _currentOverlayEntry {
    for (Route<dynamic> route in _history.reversed) {
      if (route.overlayEntries.isNotEmpty)
        return route.overlayEntries.last;
    }
    return null;
  }
  ///构建路由对象
  Route<T> _routeNamed<T>(String name, { @required Object arguments, bool allowNull = false }) {
    assert(!_debugLocked);
    assert(name != null);
    final RouteSettings settings = RouteSettings(
      name: name,
      isInitialRoute: _history.isEmpty,
      arguments: arguments,
    );
    Route<T> route = widget.onGenerateRoute(settings);
    if (route == null && !allowNull) {
      assert(() {
        if (widget.onUnknownRoute == null) {
          throw FlutterError(
            'If a Navigator has no onUnknownRoute, then its onGenerateRoute must never return null.\n'
            'When trying to build the route "$name", onGenerateRoute returned null, but there was no '
            'onUnknownRoute callback specified.\n'
            'The Navigator was:\n'
            '  $this'
          );
        }
        return true;
      }());
      route = widget.onUnknownRoute(settings);
      assert(() {
        if (route == null) {
          throw FlutterError(
            'A Navigator\'s onUnknownRoute returned null.\n'
            'When trying to build the route "$name", both onGenerateRoute and onUnknownRoute returned '
            'null. The onUnknownRoute callback should never return null.\n'
            'The Navigator was:\n'
            '  $this'
          );
        }
        return true;
      }());
    }
    return route;
  }

  @override
  Widget build(BuildContext context) {
    assert(!_debugLocked);
    assert(_history.isNotEmpty);
    ///处理鼠标事件
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUpOrCancel,
      onPointerCancel: _handlePointerUpOrCancel,
      ///消费掉子树中的事件，不让子节点处理事件
      child: AbsorbPointer(
        absorbing: false, // it's mutated directly by _cancelActivePointers above
        child: FocusScope(
          node: focusScopeNode,
          autofocus: true,
          child: Overlay(
            key: _overlayKey,
            initialEntries: _initialOverlayEntries,
          ),
        ),
      ),
    );
  }
}

```


### `push&Pop`

1.通过`Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);`在Widget树中查找`NavigatorState`

```Dart
@optionalTypeArgs
static Future<T> pushNamed<T extends Object>(
  BuildContext context,
  String routeName, {
  Object arguments,
 }) {
   ///核心代码
  return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
}
```

2.调用`Route`中的`install`出的路由信息和`RouteSettings`参数到Route中，`Route`通过全局的`final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();`查找到在`NavigatorState build `中构建的`Overlay`从而把数据传入`OverlayState`中的`List<OverlayEntry> `

```Dart
@optionalTypeArgs
 Future<T> push<T extends Object>(Route<T> route) {
   final Route<dynamic> oldRoute = _history.isNotEmpty ? _history.last : null;
   route._navigator = this;
   /* 调用Route方法 */
   route.install(_currentOverlayEntry);
   _history.add(route);
   route.didPush();
   route.didChangeNext(null);
   if (oldRoute != null) {
     oldRoute.didChangeNext(route);
     route.didChangePrevious(oldRoute);
   }
   for (NavigatorObserver observer in widget.observers)
     observer.didPush(route, oldRoute);
   assert(() { _debugLocked = false; return true; }());
   _afterNavigation(route);
   return route.popped;
 }
```

3.调用`OverlayState insertAll`方法，添加路由信息到`List<OverlayEntry>`列表中，调用`setState`方法就触发`Widget build`方法重建，重新绘制整棵`Widget`树，最终调用`_Theatre`RenderObjectWidget
```Dart
void insertAll(Iterable<OverlayEntry> entries, { OverlayEntry below, OverlayEntry above }) {
  if (entries.isEmpty)
    return;
  for (OverlayEntry entry in entries) {
    assert(entry._overlay == null);
    entry._overlay = this;
  }
  setState(() {
    _entries.insertAll(_insertionIndex(below, above), entries);
  });
}
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
