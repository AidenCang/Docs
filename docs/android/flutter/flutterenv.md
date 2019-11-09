# Flutter 引擎环境安装

先了解框架逻辑,在了解细节，建议不要低着头走路,虽然不会摔倒，不一定到达目的地，要先抬头找好方向，在埋头苦干....

Flutter 是Google提供开发Android&IOS,Window,Mac,Linux,Web的跨平台开发UI工具包,主要是解决一套代码能够运行在多种设备上的UI开发Kit，源代码托管`git`代码仓库之上

在准备编译flutter之前，我们需要解决的问题,带着问题去学习才是最好的方法，能够高效的解决有疑问的问题和内容：


* 1.Flutter代码在哪里下载？
* 2.Flutter怎么下载？
* 3.Flutter包含哪些文件？
* 4.Flutter编译需要哪些工具？
* 5.怎么设置这些工具？
* 6.如何使用工具进行编译？
* 7.编译之后的产物是什么样的？
* 8.怎么使用编译好的产物，有哪些区别和要求？
* 9.为什么要这样设计，有什么好处？

## Flutter代码放在哪里？

Flutter 生态包括Flutter源代码、FlutterDart语言、Flutter Api，Flutter测试环境、Flutter编译环境、Flutter issue等一系列和Flutter相关的内容，最基本的信息可以在Flutter的git代码仓库中找到，后续的开发中主要也是也Flutter仓库的内容为准，目的主要是抓住Flutter开发相关的源代码、开发环境设置、编译、调试、优化、issue解决、贡献代码、我们不能面面俱到的讲解flutter的内容，我们主要是理清楚Flutter开发相关的内容以及内容直接的关联，在后续的开发工作中能够快速的判断问题、理解整个Flutter运行原理，在通过工具辅助阅读源代码，进行问题定位和解决，而不是面向`浏览器编程`。


[Flutter源码托管仓库](https://github.com/flutter/flutter/)

[HomeWiki](https://github.com/flutter/flutter/wiki)

[修改提交Flutter代码的规则](https://github.com/flutter/flutter/blob/master/CONTRIBUTING.md)

[Flutter路线图](https://github.com/flutter/flutter/wiki/Roadmap)

[Flutter性能测试内容](https://github.com/flutter/flutter/tree/master/dev/devicelab)

[Flutter Dashboard](https://flutter-dashboard.appspot.com/)

[FlutterApi](https://api.flutter.dev/)

[UI开发框架](https://flutter.dev/)

## Flutter怎么下载？

Flutter 托管在Github上，通过[depot_tools](http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)自动跟进`.gclient`文件中配置的内容进行依赖下载[编译环境设置](https://github.com/flutter/flutter/wiki/Setting-up-the-Engine-development-environment)

1.fork Flutter github代码仓库中的代码到自己的github中

2.配置电脑上的ssh证书到自己的GitHub账号中

3.安装相关的软件工具[设置开发环境](https://github.com/flutter/flutter/wiki/Setting-up-the-Engine-development-environment)

4.配置[depot_tools](http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)环境

5.使用`gclient sync`下载flutter源代码到本地

6.等待漫长的下载过程就可以把源代码下载到本地

## Flutter包含哪些文件？

Flutter 源码项目是一个庞大的源码项目，是按照上面样的组织方式来进行源代码组织的？？？

编译源代码:`源代码`、`编译系统`、`第三方支持库`、`编译产物`

[Flutter在线构建状态](https://cirrus-ci.com/github/flutter/engine)

1.Flutter自己的源代码保存的位置???

2.第三方库相关的代码存放的位置???

3.编译系统是怎么根据不同的命令构建不同平台的Flutter引擎版本???

4.使用到了那些工具?用什么用处？？

5.不同平台的SDK是怎么维护更新的???

6.编译之后的产物是什么样子的???

flutter Engine源码目录下的文件和文件夹非常清楚的组织，不同功能作用的源代码`版本信息`,`构建脚本`, `构建系统工具`,`Flutter源代码工程`,`Android&IOS编译相关的SDK检测代码`

    ➜  engine_2019_11 tree -L 2
    .
    └── src  源文件目录
        ├── AUTHORS
        ├── BUILD.gn 编译脚本
        ├── LICENSE
        ├── README.md
        ├── build  构建脚本目录，包含不同平台的编译文件
        ├── build_overrides
        ├── buildtools 编译源代码时使用到的工具
        ├── flutter  Flutter核心代码
        ├── ios_tools
        ├── out  编译输出文件目录
        ├── third_party 图片、文件、zlib等一系列工具库，主要是一下独立功能的库文件
        └── tools  主要是检测和平台相关的一下编译环境和工具(Android、dart开发工具SDK)

    9 directories, 5 files

## 总结

通过以上三步的准备工作，我们已经将Flutter相关的`资源网站`,`源代码相关的位置和目录`,`编译环境和源码下载工具`做了一些准备和相关知识的了解，作为开篇内容，将不会对细节做太多的说明需要主要我的知识点:

1. Flutter 开发相关的资源
2. 如何配置Flutter源代码查看、下载工具的使用
3. flutter源码的目录和文件大概的文件有那些
