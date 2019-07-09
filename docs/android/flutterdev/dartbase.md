# 常使用的库

[material-library](https://api.flutter.dev/flutter/material/material-library.html)

[design](https://material.io/design/)

[widgetLib](https://api.flutter.dev/flutter/widgets/widgets-library.html)

[Google字体库](https://fonts.google.com/)


# 对平台的操作

    * Information about the environment in which the current program is running.
    *
    * Platform provides information such as the operating system,
    * the hostname of the computer, the value of environment variables,
    * the path to the running program,
    * and so on.

[platform.dart](/Users/cuco/flutter/bin/cache/pkg/sky_engine/lib/io/platform.dart)

[foundation](/Users/cuco/flutter/packages/flutter/lib/src/foundation/platform.dart)

# 需要解决的问题:

    How to create constructors
    Different ways to specify parameters
    When and how to create getters and setters
    How Dart handles privacy
    How to create factories
    How functional programming works in Dart
    Other core Dart concepts

# 为什么Flutter使用Dart
[Why Flutter Uses Dart](https://hackernoon.com/why-flutter-uses-dart-dd635a054ebf)


# 开发资源

## 方法级联

## Dart如何实现多线程

Note: All Dart code runs in the context of an isolate that owns all of the memory that the Dart code uses. While Dart code is executing, no other code in the same isolate can run.


If you want multiple parts of Dart code to run concurrently, you can run them in separate isolates. (Web apps use workers instead of isolates.) Multiple isolates run at the same time, usually each on its own CPU core. Isolates don’t share memory, and the only way they can interact is by sending messages to each other. For more information, see the documentation for isolates or web workers.
Asynchrony support, a section in the language tour.
API reference documentation for

[futures](https://api.dart.dev/stable/2.4.0/dart-async/Future-class.html),

[isolates](https://api.dart.dev/stable/2.4.0/dart-isolate/dart-isolate-library.html), and

[web workers](https://api.dart.dev/stable/2.4.0/dart-html/Worker-class.html).

Flutter如何设置显示方向？
The MyAppBar widget creates a Container with a height of 56 device-independent pixels with an internal padding of 8 pixels
Theme.of(context).primaryColor; 处理APP样式相关的数据

# 调试工具

# 优化、优化工具的使用
# 函数式编程

# first coding
1.定义类
2.定义私有变量
3.定义get、set方法
4.toString的使用
5.构造方法的使用
6.定义只读、只写的变量
7.Dart doesn't support overloading constructors and handles this situation differentl
8.可选的名字参数

    class Bicycle{
      int cadence;
      int _speed = 10;
      int get speed => this._speed;
      int gear;

      Bicycle(int cadence,int gear){
        this.cadence = cadence;
        this.gear = gear;
      }

      void applyBrake(int decrement){
        this._speed -= decrement;
      }

      void speedUp(int increment){
        _speed += increment;
      }
      @override
      String toString() => 'Bicycle:$_speed mph';

    }


    void main(){
      var bike = Bicycle(2,1);
      print(bike);
    }


## 可选参数
1.参数使用名字


    import 'dart:math';

    class Rectangle {
      int width;
      int height;
      Point origin;
      Rectangle({this.origin = const Point(0, 0), this.width = 0, this.height = 0});

      @override
      String toString() =>
          'Origin: (${origin.x}, ${origin.y}), width: $width, height: $height';
    }

    main() {
      print(Rectangle(origin: const Point(10, 20), width: 100, height: 200));
      print(Rectangle(origin: const Point(10, 10)));
      print(Rectangle(width: 200));
      print(Rectangle());
    }
