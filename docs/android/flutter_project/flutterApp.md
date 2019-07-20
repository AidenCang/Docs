# 学习Flutter基本知识
Dart集成知识
AndroidStudio、IOS
一定的Android、IOS基础
类：
封装、基础、多态
抽象
构造方法
函数、方法:
1.入口方法
2.匿名函数
3.静态方法
4.放回值
5.参数：可选参数、默认参数
泛型：
1.泛型类
2.在构造方法上使用泛型
3.泛型方法
异步：
1.async await
2.Future
3.Stream

学习资料:
https://www.dartlang.org
https://dart.goodev.org


# 如何使用Flutter包和插件
pub.dartlang.org

# Flutter 常用Widget
ThemeData

Decoration (decoration.dart)

  BoxDecoration (box_decoration.dart)
  FlutterLogoDecoration (flutter_logo.dart)
  ShapeDecoration (shape_decoration.dart)
  _CupertinoEdgeShadowDecoration (route.dart)
  UnderlineTabIndicator (tab_indicator.dart)

MaterialApp
Scaffold
Appbar
bottomnavigatorBar
RefreshIndicator
images
TextField
PageView

# 布局相关
Container
RenderObjectWidget
1.SingleChildRenderObjectWidget
  1.Opacity
  2.ClipOval
  3.ClipRect
  4.PhysicalModel
  5.Align:center
  6.Padding
  7.SizeBox
  8.FractionallySizedBox

2.MultiChildRenderObjectWidget
  1.Stack
  2.Flex
    1.Column
    2.Row
  3.Wrap
  4.Flow
  5.FractionallySizedBox

ParentDataWidget
1.Positional
2.Flexible->Expanded

# Image 支持的图片类型
1.JPEG、PNG、GIF、Animated、WebP、Animator、BMP、WBMP
2.如何加载图片、如何处理不同分辨率的图片

#入门
#入门实战
#进价提升
#进阶实战
#进阶拓展
Flutter开发技能
理解整个Flutter项目开发流程
规范的代码编写与工程化封装技巧
大中型项目开发的技巧
开发环境和开发环境搭建
网络编程
数据库存储
JSON解析和复杂模型转换
Future模块
FutureBuilder
Flutter和Native混合开发
开发包和插件
折叠屏适配与兼容问题
打包发布flutter应用
Flutter升级和适配指南

动画：
1.AnimatedWidget
2.AnimatedBuilder
3.Animation
4.AnimationController
5.Tween
6.CurvedAnimation
7.Hero动画

NativeModule
Flutter Android混合开发
Flutter IOS混合开发
Flutter H5混合开发

通信：
BasicMessageChannel
MethodChannel
EventChannel

全面屏、折叠屏：
1.android适配
2.IOS适配

打包：
android打包
IOS打包

Flutter版本：
Beta、dev、master、stable

flutter doctor命令



# app中使用到的技术梳理
Scaffold
PageView
http
Navigator
NotificationListener
PageRouterBuilder
MaterialPageRoute
自定义控件
Native modules
Ai智能语音
Channel通道
混合开发
插件
官方组件

ListView
PageView
ExpansionTile可折叠的列表


图片：
1.加载flutter静态图片
2.Native图片
3.网络图片
4.缓存图片
5.Icon
6.PlaceHolder

# 需求分析、技术分解
首页
1.Banner
2.可配置入口
3.网格卡片
4.资源位运营
5.滚动渐变的特效


搜索模块
实时搜索
自定义搜索框
兼容语音
富文本展示

Ai语音模块
1.混合开发
2.Native SDK
3.Flutter Plugin
4.Channel通道

旅拍模块
1.瀑布流布局
2.tab滑动切换
3.支持下拉刷新
4.支持上拉加载更多

我的模块
H5混合开发
Flutter-H5通信
自定义WebView


#工具
1.AndroidStudio
2.Dart Devtools
3.纯Flutter项目调试
4.混合项目调试

插件：
Flutter插件(和Android、IOS通信的插件)
Dart插件(纯Dart插件)

# 环境问题、版本问题、工具问题
Flutter环境变量
Stable、dev、Beta、master
flutter doctor检查环境是否ok



# Flutter学习需要掌握哪些语言
学习Flutter该掌握哪些基础
如何快速搭建和运行一个Flutter项目
如何使用Flutter包和插件
statelesswidget与基础组件
statewidget与基础组件
如何进行flutter布局开发
如何使用flutter路由和导航
如何检查用户手势以及处理点击事件
如何使用和导入flutter资源文件
如何打开第三方应用拍照App
# 常用工具
[Json解析](https://www.json.cn/)

[接口数据](http://www.devio.org/io/flutter_app/json/home_page.json)

www.json.cn
Json to Dart


使用网络图片
如何加载网络图片
如何加载静态图片
如何加载本地图片
如何设置Placeholder
如何设置缓存
如何加载ICON


Animation
在flutter中有哪些动画
如何使用动画库的基础类给widget添加动画
如何为动画添加监听
该什么时候使用AnimatedWidget与AnimatedBuilder
如何使用Hero动画

启动白屏问题和启动屏开发
Flutter全屏适配指南
Flutter折叠屏适配指南


# 常用插件
[网络缓存插件](cached_network_image)
[图片处理插件](transparent_image)
[加载本地图片](path_provider)

[Material图标](https://material.io/tools/icons/?style=baseline)
[Flutter安装](https://flutterchina.club/get-started/install/)
[AndroidStudio](https://developer.android.com/studio/intro)
[Flutter镜像地址](https://flutter.dev/community/china)
[材料设计](https://material.io/)
[Flutter教程](http://www.devio.org/tags/#Flutter)
[Flutter实战项目](https://blog.51cto.com/14429816/2416749?source=dra)
