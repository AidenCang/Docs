# Future & Stream

Flutter 泛型使用

中断时返回动态类型dynamic

Completer

StreamController

SynchronousStreamController


/**
 * A simple stopwatch interface to measure elapsed time.
 */
class Stopwatch {






Flutter stream 有两种类型:
  single-subscription
  broadcast



## 概述

    如何以及何时使用async和await关键字。
    如何使用async和await影响执行顺序。
    如何使用函数中的try-catch表达式处理异步调用中的错误async。

## 使用场景

    通过网络获取数据。
    写入数据库。
    从文件中读取数据。

## 关键术语

    同步操作：同步操作阻止执行其他操作直到完成。
    同步功能：同步功能仅执行同步操作。
    异步操作：一旦启动，异步操作允许其他操作在完成之前执行。
    异步功能：异步功能至少执行一次异步操作，也可以执行同步操作。

## 返回值
    类型的Future以type Future<T>的值完成T。例如，具有类型的future将Future<String>生成字符串值。如果Future不能产生可用价值，那么未来的类型就是 Future<void>。


## 源码分析

1.分析Futur源码调用过程，`Future.delayed(Duration(milliseconds: 500))`

2.调动系统`Timer`作为一个函数

3.新建一个Futur实例类`_Future`

4.调动监听链

5.调用系统Timer执行相关的操作，在`Zone`中完成异步操作

6.执行相关的代码完成之后调用`_FutureListener`对象逐层调用链式方法

```Dart
Future.delayed(Duration(milliseconds: 500))
    .then((value) {
      print("won't reach here");
    }) // Future completes with an error.
    .whenComplete(
        () => print('reaches here')) // Future completes with the same error.
    .then((_) =>
        print("won't reach here")) // Future completes with the same error.
    .catchError((error) {})
    .whenComplete(() {});

```
创建一个系统级别的倒计时进行计时功能，在`Zone`区域中继续异步处理`[Dart Zone使用]`
```Dart
factory Timer(Duration duration, void callback()) {
  if (Zone.current == Zone.root) {
    // No need to bind the callback. We know that the root's timer will
    // be invoked in the root zone.
    return Zone.current.createTimer(duration, callback);
  }
  return Zone.current
      .createTimer(duration, Zone.current.bindCallbackGuarded(callback));
}
```
新建一个Futur实例类`_Future`
```Dart
factory Future.delayed(Duration duration, [FutureOr<T> computation()]) {
  _Future<T> result = new _Future<T>();
  new Timer(duration, () {
    if (computation == null) {
      result._complete(null);
    } else {
      try {
        result._complete(computation());
      } catch (e, s) {
        _completeWithErrorCallback(result, e, s);
      }
    }
  });
  return result;
}
```

```Dart
void _complete(FutureOr<T> value) {
   assert(!_isComplete);
   if (value is Future<T>) {
     if (value is _Future<T>) {
       _chainCoreFuture(value, this);
     } else {
       _chainForeignFuture(value, this);
     }
   } else {
     _FutureListener listeners = _removeListeners();
     _setValue(value);
     _propagateToListeners(this, listeners);
   }
 }
```
在链式调用中，都会返回一个`FutureOr`对象作为下一次调用的对象，并添加当前调用到上一次调用的监听对象的成员变量中`_thenNoZoneRegistration`,在计算结果完成之后，逐层返回调用监听对象进行处理`_FutureListener`
```Dart
Future<R> then<R>(FutureOr<R> f(T value), {Function onError}) {
    Zone currentZone = Zone.current;
    /* 判断当前的`Zone`是否在`rootZone`中 */
    if (!identical(currentZone, _rootZone)) {
      f = currentZone.registerUnaryCallback<FutureOr<R>, T>(f);
      if (onError != null) {
        // In checked mode, this checks that onError is assignable to one of:
        //   dynamic Function(Object)
        //   dynamic Function(Object, StackTrace)
        onError = _registerErrorHandler(onError, currentZone);
      }
    }
    return _thenNoZoneRegistration<R>(f, onError);
  }

  // This method is used by async/await.
Future<E> _thenNoZoneRegistration<E>(
    FutureOr<E> f(T value), Function onError) {
  _Future<E> result = new _Future<E>();
  _addListener(new _FutureListener<T, E>.then(result, f, onError));
  return result;
}
```




## Stream

常用的关键字:

    first
    last
    single
    firstWhere()
    lastWhere()
    singleWhere().
    skip()
    skipWhile()
    take()
    takeWhile()
    where().
    transform




```Dart
  factory Timer(Duration duration, void callback()) {
    if (Zone.current == Zone.root) {
      // No need to bind the callback. We know that the root's timer will
      // be invoked in the root zone.
      return Zone.current.createTimer(duration, callback);
    }
    return Zone.current
        .createTimer(duration, Zone.current.bindCallbackGuarded(callback));
  }
```


## Dart Zone使用
设置当前区域错误回调

```Dart
/* 全局Isolate错误处理 */
AsyncError replacement = Zone.current.errorCallback(error, stackTrace);
/* 获取跟root */
Zone.root

判断当前的Zone是否为根root
if (!identical(Zone.current, _rootZone)) {
      AsyncError replacement = Zone.current.errorCallback(error, stackTrace);
      if (replacement != null) {
        error = _nonNullError(replacement.error);
        stackTrace = replacement.stackTrace;
      }
    }
```
## 参考连接

[生成器使用](https://www.kikt.top/posts/flutter/dart/generators/)
[async-await](https://dart.dev/codelabs/async-await)
[futures-error-handling](https://dart.dev/guides/libraries/futures-error-handling)
[stream](https://dart.dev/tutorials/language/streams)


[RxDart github repo](https://github.com/ReactiveX/rxdart)
[Asynchronous Programming: Streams](https://www.dartlang.org/tutorials/language/streams)
[Single-Subscription vs. Broadcast Streams](https://www.dartlang.org/articles/libraries/broadcast-streams)
[Creating Streams in Dart](https://www.dartlang.org/articles/libraries/creating-streams)
[Testing Streams: Stream Matchers](https://pub.dartlang.org/packages/test#stream-matchers)
