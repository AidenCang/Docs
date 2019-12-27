# Flutter开发

稳定性、一致性、耐温度和湿度、信噪比

## 开发环境搭建

## 开发工具使用

## Flutter自带命令行工具


## 开发使用到的插件


## 不同平台的使用Android&IOS&WEB


## FlutterEngine分析

## FlutterUI层的控件使用


## UI生成工具

## 性能查看分析工具

## 第三方平台Crash统计工具

## Android&&IOS 插件平台兼容性

1.平台兼容

2.机型兼容

3.UI兼容

## Androidx兼容性

## 网络使用


## 本地文件系统


## 测试框架使用

## 颜色和字体大小&主题
默认点击大小48*48
Theme&&MaterialApp&&ThemeData

## 动画


## 页面跳转

## Meta使用

/Users/cuco/flutter/.pub-cache/hosted/pub.dartlang.org/meta-1.1.8/lib/meta.dart


## 异步编程和消息循环
* * [The Event Loop and Dart](https://www.dartlang.org/articles/event-loop/):
* Learn how Dart handles the event queue and microtask queue, so you can write
* better asynchronous code with fewer surprises.
*/
## Android&IOS不同主题风格的控件
WidgetsApp

MaterialApp

CupertinoApp

## 导航控制器

Navigator

MaterialPageRoute


## 屏幕适配

MediaQuery

SafeArea




Scaffold

GridPaper
AnimatedTheme
Hero


## 导航控制器使用

## 国际化
Navigator
MaterialPageRoute
WidgetsApp
[home], [routes], [onGenerateRoute], or [builder]

## WidgetsApp
DefaultTextStyle
  AnimatedDefaultTextStyle
  DefaultTextStyleTransition

/// An [InheritedWidget] that defines visual properties like colors
/// and text styles, which the [child]'s subtree depends on.


/// The `locale` and `delegates` parameters default to the [Localizations.locale]
/// and [Localizations.delegates] values from the nearest [Localizations] ancestor.
///
/// To override the [Localizations.locale] or [Localizations.delegates] for an
/// entire app, specify [WidgetsApp.locale] or [WidgetsApp.localizationsDelegates]
/// (or specify the same parameters for [MaterialApp]).

## ImplicitlyAnimatedWidget

使用动画改变自己的属性

/// An abstract class for building widgets that animate changes to their
/// properties.
///
/// Widgets of this type will not animate when they are first added to the
/// widget tree. Rather, when they are rebuilt with different values, they will
/// respond to those _changes_ by animating the changes over a specified
/// [duration].

///  * [TweenAnimationBuilder], which animates any property expressed by
///    a [Tween] to a specified target value.
///  * [AnimatedAlign], which is an implicitly animated version of [Align].
///  * [AnimatedContainer], which is an implicitly animated version of
///    [Container].
///  * [AnimatedDefaultTextStyle], which is an implicitly animated version of
///    [DefaultTextStyle].
///  * [AnimatedOpacity], which is an implicitly animated version of [Opacity].
///  * [AnimatedPadding], which is an implicitly animated version of [Padding].
///  * [AnimatedPhysicalModel], which is an implicitly animated version of
///    [PhysicalModel].
///  * [AnimatedPositioned], which is an implicitly animated version of
///    [Positioned].
///  * [AnimatedPositionedDirectional], which is an implicitly animated version
///    of [PositionedDirectional].
///  * [AnimatedTheme], which is an implicitly animated version of [Theme].
///  * [AnimatedCrossFade], which cross-fades between two given children and
///    animates itself between their sizes.
///  * [AnimatedSize], which automatically transitions its size over a given
///    duration.
///  * [AnimatedSwitcher], which fades from one widget to another.
