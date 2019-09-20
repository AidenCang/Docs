# Dart 开发 Android&IOS&Web
## 环境搭建问题？
1.系统要求
2.设置Flutter镜像
3.获取FlutterSDK
4.IOS开发环境设置
5.Android开发环境设置
6.如何查看Mac操作系统版本
7.Flutter依赖库：bash、curl git 2.x mkdir rm unzip which
8.设置Flutter镜像：bash_profile

    export PUB_HOSTED_URL=https://pub.flutter-io.cn
    export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
    git clone -b dev https://github.com/flutter/flutter.git
    export PATH="$PWD/flutter/bin:$PATH"
    cd ./flutter
    flutter doctor

上海资料获取:

    FLUTTER_STORAGE_BASE_URL: https://mirrors.sjtug.sjtu.edu.cn/
    PUB_HOSTED_URL: https://dart-pub.mirrors.sjtug.sjtu.edu.cn/


[Flutter in China](https://flutter.dev/community/china)
[flutter.cn](https://flutter.cn/)

9.环境变量配置
![pic](../../assets/images/android/flutter/flutterpath.png)
10.打开IOS模拟器

    open -a Simulator

11.使用命令行创建和运行项目
12.如何安装Flutter App到苹果真机上

    1.要通过 flutter run 运行到IOS真机上，需要安装一下额外的开发工具和一个Apple账号，还需要的Xcode中设置
    2.使用Xcode运行Flutter App更简单，这几运行就可以了
    安装IOS安装工具:
    ![pic](../../assets/images/android/flutter/brewiosinstall.png)
    任何一个命令失败都可以运行`brew doctor`来排查错误


13.Homebrew 安装使用
14.Flutter开发工具使用
15.androidStudio版本控制
16.Flutter环境变量、工具问题、版本问题

  Flutter环境变量、stable、beta、dev、master
  Flutter doctor
  AndroidStudio
  Xcode  新建一个项目查看是是否可以运行
  VPN和镜像

17.Flutter需要掌握的内容
  1.学习Flutter需要掌握的基础知识：Dart、Android&IOS基础[Dart](https://www.dartlang.org),[Dart中文](https://dart.goodev.org)
  2.如何使用Flutter包和插件
  3.如何继续Flutter布局
  4.如何使用Flutter路由和导航
  5.如何检测用户手势和以及点击事件处理
  6.如何导入和使用Flutter资源文件
  7.如何打开第三方应用

18.材料设计

  [材料设计](https;//material.io)
  [字体库](https://fonts.google.com)

19.布局相关组件

  RenderObjectWidget
    SingleChildRenderObjectWidget
      Opactiy
      ClipOval
      ClipRect
      PhysicalModel
      Align
      Padding
      SizeBox
      FractionallySizeBox

    MultiChildRenderObjectWidget
      Flex
      Stack
      Wrap
      Flow
  ParentDataWidget
     Positioned
     Flexible->Expande

20.Flutter 生命周期(应用程序生命周期、Widget生命周期)

Flutter生命周期按照使其划分为三个不同的生命周期:
1.创建期
createState、initState
2.更新期
didchangeDependences、build、didUpdateWidget
3.销毁期
deativate、dispose

21.AndroidX兼容
22.如何添加图片占位符
23.如何加载不同分辨率的图片
24.如何加载手机上的图片
25.实现动画有哪些方式
26.说明Hero有哪些应用场景
27.Flutter开发的技巧有哪些？？
28.如何调试flutter的android代码
29.如何调试Flutter的IOS代码

## Flutter混合开发
1.Flutter混合开发有哪些步骤
2.创建一个Fluttermodul有哪些步骤
3.Android已有项目中集成Flutter步骤
4.现有IOS中集成Flutter的步骤
5.请对比纯Flutter开发和混合Flutter开发调试有哪些步骤
6.Flutter代码的运行模式
7.如何打包一个已经集成Flutter的项目如何设置？
8.Flutter和Native通信的方式？有哪些步骤？
9.描述Channels是如何工作的?
10.Flutter如何调用Native代码？
11.Native如何调用Flutter代码？
12.如何将Flutter的页面作为一个页面集成到现有页面中?
13.热加载和热重启的区别？？
14.Android证书版本号的区别？？？
15.
