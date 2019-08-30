# Future & Stream

Flutter 泛型使用
中断时返回动态类型dynamic
Completer
StreamController
SynchronousStreamController

#Timer在Zone区域新建一个虚拟环境

```Dart
/**
   * Creates a new timer.
   *
   * The [callback] function is invoked after the given [duration].
   *
   */
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
AsyncError replacement = Zone.current.errorCallback(error, stackTrace);
```
