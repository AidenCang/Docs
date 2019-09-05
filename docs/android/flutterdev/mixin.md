# flutter mixin&Bloc& Reactive Programming&Stream
mixin不能有构造函数
全局错误信息提示

简而言之，业务逻辑需要：

被移到一个或几个BLoC，
尽可能从表示层中删除。换句话说，UI组件应该只关心UI事物而不关心业务，
依赖Streams 独家使用输入（Sink）和输出（流），
保持平台独立，
保持环境独立。

[bloc架构](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc/)
[bloc架构练习](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/)
[Demo地址](https://github.com/boeledi/Streams-Block-Reactive-Programming-in-Flutter)
[DemoBloc](https://github.com/boeledi/blocs)
为每一个新的页面注入新的功能模块
Generic类型
## 流可以传达什么？
一切都是如此。从值，事件，对象，集合，映射，错误或甚至另一个流，可以通过流传达任何类型的数据。

## 关键概念

StreamTransformer
StreamConsumer
StreamSubscription

## RxDart

[RxDart](https://pub.dev/packages/rxdart)

[StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)


## redux
1.全局保存App的状态，使用Bloc架构模式
2.只有一种方法可以改变状态树的状态`dispatch`
3.调用过程`dispatch`====>`Middleware`====>`Reducer`


## Flutter面试题

https://juejin.im/post/5c67d621518825620a7f133e
