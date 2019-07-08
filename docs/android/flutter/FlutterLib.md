#Flutter开发常使用的库


## Flutter App开发相关知识点
1.Flutter异步编程async,await,Future/Stream
[async,await](https://juejin.im/post/5ad33bcaf265da238d512840)
[Stream完全解析](https://zhuanlan.zhihu.com/p/63876241)

2.Flutter 错误异常处理
[错误异常处理](https://zhuanlan.zhihu.com/p/54142949)

3.Flutter全局状态管理
[Flutter全局状态管理](https://juejin.im/post/5b79767ff265da435450a873)
## 序列化

    dependencies:
      json_annotation: ^0.2.3

    dev_dependencies:
      build_runner: ^0.8.0
      json_serializable: ^0.5.0

### 执行生成文件

      可以手动或自动触发代码生成。

      要手动运行，请使用该命令flutter packages pub run build_runner build。
      我们还可以使用该命令flutter packages pub run build_runner watch设置观察程序，以便在文件更改时自动运行代码生成。
      在生成新文件之前，您可能需要传递参数--delete-conflicting-outputs以flutter packages pub run build_runner build删除旧生成的文件。

[序列化反序列化](https://flutter-academy.com/work-with-json-in-flutter-part-2-json-serializable/)
