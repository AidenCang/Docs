Android代码在初始化完成flutter的文件之后，提供SurfaceView到底层进行Flutter engine 中的Skia 2d图像
同为跨平台技术，Flutter有何优势呢？

Flutter在Rlease模式下直接将Dart编译成本地机器码，避免了代码解释运行的性能消耗。
Dart本身针对高频率循环刷新（如屏幕每秒60帧）在内存层面进行了优化，使得Dart运行时在屏幕绘制实现如鱼得水。
Flutter实现了自己的图形绘制避免了Native桥接。
Flutter在应用层使用Dart进行开发，而支撑它的是用C++开发的引擎。


![pic](../assets/images/android/flutter/flutterPlatfrom.jpeg)
