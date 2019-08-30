# FlutterUI开发重用代码片段

## 处理Isolate中的代码片段错误异常

```Dart
Future<void> getPic() async {
//  HttpServer.bind(address, port)
  Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) async {
    print('Isolate.current.addErrorListener caught an error');
    await _reportError(
      (pair as List<String>).first,
      (pair as List<String>).last,
    );
  }).sendPort);
}

//处理错误日志
void _reportError(String first, String last) {}

void main() {
//  指定运行在自己的区域中,处理全局的信息
  runZoned(() async {
    runApp(FlutterReduxApp());
    PaintingBinding.instance.imageCache.maximumSize = 100;
//    getPic().then()
  }, onError: (Object obj, StackTrace stack) {
//    发送错误是在这里处理
    print(obj);
    print(stack);
  });
}

```

## 动态修改状态栏的样式

```Dart
// 修改系统状态栏颜色
SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
systemNavigationBarColor: Color(AppColors.themeColor), // navigation bar color
statusBarColor: Color(AppColors.themeColor), // status bar color
));
```

## 常用注解

```Dart
/// Constants for use in metadata annotations.
///
/// See also `@deprecated` and `@override` in the `dart:core` library.
///
/// Annotations provide semantic information that tools can use to provide a
/// better user experience. For example, an IDE might not autocomplete the name
/// of a function that's been marked `@deprecated`, or it might display the
/// function's name differently.
///
/// For information on installing and importing this library, see the
/// [meta package on pub.dartlang.org] (http://pub.dartlang.org/packages/meta).
/// For examples of using annotations, see
/// [Metadata](https://www.dartlang.org/docs/dart-up-and-running/ch02.html#metadata)
/// in the language tour.
library meta;
const _AlwaysThrows alwaysThrows = const _AlwaysThrows();
const _Checked checked = const _Checked();
const _Experimental experimental = const _Experimental();
const _Factory factory = const _Factory();
const Immutable immutable = const Immutable();
const _IsTest isTest = const _IsTest();
const _IsTestGroup isTestGroup = const _IsTestGroup();
const _Literal literal = const _Literal();
const _MustCallSuper mustCallSuper = const _MustCallSuper();
const _OptionalTypeArgs optionalTypeArgs = const _OptionalTypeArgs();
const _Protected protected = const _Protected();
const Required required = const Required();
const _Virtual virtual = const _Virtual();
const _VisibleForOverriding visibleForOverriding =
    const _VisibleForOverriding();
const _VisibleForTesting visibleForTesting = const _VisibleForTesting();


```
## 常用控件

```Dart
SafeArea
RoundedRectangleBorder
配合AutomaticKeepAliveClientMixin可以keep住

```


## 使用Intent打开Android原生应用
```Dart
/// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }

    return Future.value(false);
  }

```
