# Flutter ISOlate 使用

[Flutter 学习资源](https://github.com/crazycodeboy/awesome-flutter-cn)
## 什么是ISOlate

1.一个独立的DART执行上下文。所有的DART代码都运行在`ISOlate`中，代码可以访问类和值。都是在一个ISOlate中运行。
2.不同的isolates可以通过ReceivePort/SendPort进行通信。
3.`isolate`对象是对ISOlate对象的引用，通常和当前的不是同一个。它代表并可以用来控制另一个ISOlate。
4.生成新ISOlate时，将运行代码隔离在其自己的事件循环中，并且每个事件可以运行较小的任务在嵌套的微任务队列中。
5.`isolate`对象允许其他隔离对象控制事件循环它所代表的隔离物，为了检查 `ISOlate`，例如，通过暂停ISOlate或获ISOlate时的事件有一个未察觉的错误。
6.[ControlPort]识别并允许控制ISOlate，以及[PauseCapability]和[TermineCapability]保护访问一些控制操作。例如，在没有[pause]，无效。
7.isolate操作提供的“isolate”对象将具有控制端口和控制ISOlate所需的功能。可以在没有这些能力的情况下创建新的隔离对象如有必要，使用[isolate.isolate]构造函数。
8.isolate对象不能通过“sendport”发送，但`ControlPort`和`PauseCapability`可以被发送，并且可以用来创建一个新的功能。

### 如何创建 ISOlate

### 如何访问和传递参数

### 如何监控

### 如何优化

### 当前的ISOlate和创建出来的Isolate有什么区别

### 如何控制和使用其他ISOlate

### 什么是微任务

### Flutter错误处理


## Android多进程，内存管理
1.UI进程和后台进程分离，后端进程，持续的提供服务
2.能够减轻UI进程在的内存压力，避免内存溢出和泄漏(一般系统提供的内存为32M,64M,128M)

[巧用Android多进程，微信，微博等主流App都在用](https://cjw-blog.net/2017/02/26/AIDL/)

[Android内存优化杂谈](https://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ==&mid=400656149&idx=1&sn=122b4f4965fafebf78ec0b4fce2ef62a&mpshare=1&scene=1&srcid=0501f6p8yRsM5qj6OBKEVY1T&key=16e063fbfd27c52cdf5c92791e0542126da55aeb373dcd13df6aa6c417ec61127af2618384b2201ffa7c918e4bbe6780b4d20d3e2ec989af4e2ec3adfda18308cac9706ac4f970ae73fb86211c44b7c2&ascene=0&uin=ODExMTkxNjU%3D&devicetype=iMac+MacBookPro11%2C2+OSX+OSX+10.12.3+build&version=12020510&nettype=WIFI&fontScale=100&pass_ticket=AxhG0QxjCX8weF512sU8ttFb%2B7z%2B8JxvShlgh7diOtM%3D)
[Android内存管理](http://developer.android.com/intl/zh-cn/training/articles/memory.html)
[akcanary](https://github.com/square/leakcanary)
[AndroidExcludedRefs](https://github.com/square/leakcanary/blob/master/leakcanary-android/src/main/java/com/squareup/leakcanary/AndroidExcludedRefs.java)
[fresco](https://github.com/facebook/fresco)
[优化安卓应用内存的神秘方法以及背后的原理](http://bugly.qq.com/blog/?p=621)
[Android性能优化之内存篇](http://hukai.me/android-performance-memory/)


## 多进程进程管理工具
[进程查看工具](https://blog.csdn.net/dfskhgalshgkajghljgh/article/details/51373694)
[开发者选项中查看](https://jingyan.baidu.com/article/f54ae2fc7c3a1c1e92b849de.html)
[demoAIDL](https://github.com/V1sk/AIDL)

## 进程保活

## 长连接



```Dart

typedef OnProgressListener = void Function(double completed, double total);
typedef OnResultListener = void Function(String result);

// An encapsulation of a large amount of synchronous processing.
//
// The choice of JSON parsing here is meant as an example that might surface
// in real-world applications.
class Calculator {
  Calculator({ @required this.onProgressListener, @required this.onResultListener, String data })
    : assert(onProgressListener != null),
      assert(onResultListener != null),
      // In order to keep the example files smaller, we "cheat" a little and
      // replicate our small json string into a 10,000-element array.
      _data = _replicateJson(data, 10000);

  final OnProgressListener onProgressListener;
  final OnResultListener onResultListener;
  final String _data;
  // This example assumes that the number of objects to parse is known in
  // advance. In a real-world situation, this might not be true; in that case,
  // the app might choose to display an indeterminate progress indicator.
  static const int _NUM_ITEMS = 110000;
  static const int _NOTIFY_INTERVAL = 1000;

  // Run the computation associated with this Calculator.
  void run() {
    int i = 0;
    final JsonDecoder decoder = JsonDecoder(
      (dynamic key, dynamic value) {
        if (key is int && i++ % _NOTIFY_INTERVAL == 0)
          onProgressListener(i.toDouble(), _NUM_ITEMS.toDouble());
        return value;
      }
    );
    try {
      final List<dynamic> result = decoder.convert(_data);
      final int n = result.length;
      onResultListener('Decoded $n results');
    } catch (e, stack) {
      print('Invalid JSON file: $e');
      print(stack);
    }
  }

  static String _replicateJson(String data, int count) {
    final StringBuffer buffer = StringBuffer()..write('[');
    for (int i = 0; i < count; i++) {
      buffer.write(data);
      if (i < count - 1)
        buffer.write(',');
    }
    buffer.write(']');
    return buffer.toString();
  }
}

// The current state of the calculation.
enum CalculationState {
  idle,
  loading,
  calculating
}

// Structured message to initialize the spawned isolate.
class CalculationMessage {
  CalculationMessage(this.data, this.sendPort);
  String data;
  SendPort sendPort;
}

// A manager for the connection to a spawned isolate.
//
// Isolates communicate with each other via ReceivePorts and SendPorts.
// This class manages these ports and maintains state related to the
// progress of the background computation.
class CalculationManager {
  CalculationManager({ @required this.onProgressListener, @required this.onResultListener })
    : assert(onProgressListener != null),
      assert(onResultListener != null),
      _receivePort = ReceivePort() {
    _receivePort.listen(_handleMessage);
  }

  CalculationState _state = CalculationState.idle;
  CalculationState get state => _state;
  bool get isRunning => _state != CalculationState.idle;

  double _completed = 0.0;
  double _total = 1.0;

  final OnProgressListener onProgressListener;
  final OnResultListener onResultListener;

  // Start the background computation.
  //
  // Does nothing if the computation is already running.
  void start() {
    if (!isRunning) {
      _state = CalculationState.loading;
      _runCalculation();
    }
  }

  // Stop the background computation.
  //
  // Kills the isolate immediately, if spawned. Does nothing if the
  // computation is not running.
  void stop() {
    if (isRunning) {
      _state = CalculationState.idle;
      if (_isolate != null) {
        _isolate.kill(priority: Isolate.immediate);
        _isolate = null;
        _completed = 0.0;
        _total = 1.0;
      }
    }
  }

  final ReceivePort _receivePort;
  Isolate _isolate;

  void _runCalculation() {
    // Load the JSON string. This is done in the main isolate because spawned
    // isolates do not have access to the root bundle. However, the loading
    // process is asynchronous, so the UI will not block while the file is
    // loaded.
    rootBundle.loadString('services/data.json').then<void>((String data) {
      if (isRunning) {
        final CalculationMessage message = CalculationMessage(data, _receivePort.sendPort);
        // Spawn an isolate to JSON-parse the file contents. The JSON parsing
        // is synchronous, so if done in the main isolate, the UI would block.
        Isolate.spawn<CalculationMessage>(_calculate, message).then<void>((Isolate isolate) {
          if (!isRunning) {
            isolate.kill(priority: Isolate.immediate);
          } else {
            _state = CalculationState.calculating;
            _isolate = isolate;
          }
        });
      }
    });
  }

  void _handleMessage(dynamic message) {
    if (message is List<double>) {
      _completed = message[0];
      _total = message[1];
      onProgressListener(_completed, _total);
    } else if (message is String) {
      _completed = 0.0;
      _total = 1.0;
      _isolate = null;
      _state = CalculationState.idle;
      onResultListener(message);
    }
  }

  // Main entry point for the spawned isolate.
  //
  // This entry point must be static, and its (single) argument must match
  // the message passed in Isolate.spawn above. Typically, some part of the
  // message will contain a SendPort so that the spawned isolate can
  // communicate back to the main isolate.
  //
  // Static and global variables are initialized anew in the spawned isolate,
  // in a separate memory space.
  static void _calculate(CalculationMessage message) {
    final SendPort sender = message.sendPort;
    final Calculator calculator = Calculator(
      onProgressListener: (double completed, double total) {
        sender.send(<double>[ completed, total ]);
      },
      onResultListener: sender.send,
      data: message.data,
    );
    calculator.run();
  }
}

// Main app widget.
//
// The app shows a simple UI that allows control of the background computation,
// as well as an animation to illustrate that the UI does not block while this
// computation is performed.
//
// This is a StatefulWidget in order to hold the CalculationManager and
// the AnimationController for the running animation.
class IsolateExampleWidget extends StatefulWidget {
  @override
  IsolateExampleState createState() => IsolateExampleState();
}

// Main application state.
class IsolateExampleState extends State<StatefulWidget> with SingleTickerProviderStateMixin {

  String _status = 'Idle';
  String _label = 'Start';
  String _result = ' ';
  double _progress = 0.0;
  AnimationController _animation;
  CalculationManager _calculationManager;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    )..repeat();
    _calculationManager = CalculationManager(
      onProgressListener: _handleProgressUpdate,
      onResultListener: _handleResult,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RotationTransition(
            turns: _animation,
            child: Container(
              width: 120.0,
              height: 120.0,
              color: const Color(0xFF882222),
            ),
          ),
          Opacity(
            opacity: _calculationManager.isRunning ? 1.0 : 0.0,
            child: CircularProgressIndicator(
              value: _progress
            ),
          ),
          Text(_status),
          Center(
            child: RaisedButton(
              child: Text(_label),
              onPressed: _handleButtonPressed,
            ),
          ),
          Text(_result),
        ],
      ),
    );
  }

  void _handleProgressUpdate(double completed, double total) {
    _updateState(' ', completed / total);
  }

  void _handleResult(String result) {
    _updateState(result, 0.0);
  }

  void _handleButtonPressed() {
    if (_calculationManager.isRunning)
      _calculationManager.stop();
    else
      _calculationManager.start();
    _updateState(' ', 0.0);
  }

  String _getStatus(CalculationState state) {
    switch (state) {
      case CalculationState.loading:
        return 'Loading...';
      case CalculationState.calculating:
        return 'In Progress';
      case CalculationState.idle:
      default:
        return 'Idle';
    }
  }

  void _updateState(String result, double progress) {
    setState(() {
      _result = result;
      _progress = progress;
      _label = _calculationManager.isRunning ? 'Stop' : 'Start';
      _status = _getStatus(_calculationManager.state);
    });
  }
}

void main() {
  runApp(MaterialApp(home: IsolateExampleWidget()));
}
```

```JSON
{
  "_id": "57112806d874e9e6df7099d4",
  "index": 0,
  "guid": "77dc6167-2351-4a64-a603-aceaff115432",
  "isActive": false,
  "balance": "$1,316.41",
  "picture": "http://placehold.it/32x32",
  "age": 21,
  "eyeColor": "brown",
  "name": "Marta Hartman",
  "gender": "female",
  "company": "EXAMPLE",
  "email": "martahartman@example.com",
  "phone": "+1 (555) 555-2328",
  "address": "463 Temple Court, Brandywine, Kansas, 1113",
  "about": "Incididunt commodo sunt commodo nulla adipisicing duis aute enim aute minim reprehenderit aute consectetur. Eu laborum esse aute laborum aute. Tempor in cillum exercitation aliqua velit quis incididunt esse ea nisi. Cillum pariatur reprehenderit est nisi nisi exercitation.\r\n",
  "registered": "2014-01-18T12:32:22 +08:00",
  "latitude": 4.101477,
  "longitude": 39.153115,
  "tags": [
    "pariatur",
    "sit",
    "sint",
    "ex",
    "minim",
    "veniam",
    "ullamco"
  ],
  "friends": [
    {
      "id": 0,
      "name": "Tricia Guerra"
    },
    {
      "id": 1,
      "name": "Paula Dillard"
    },
    {
      "id": 2,
      "name": "Ursula Stout"
    }
  ],
  "greeting": "Hello, Marta Hartman! You have 4 unread messages.",
  "favoriteFruit": "strawberry"
}

```
