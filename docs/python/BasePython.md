# Python 基础
Python 文档

# os 包
## 文件读取
## 加载JSON文件
## uuid
## 日志库的使用log
## 字符串format操作
## 参数解析库使用argparse
## threading 线程创建
## serializing/deserializing

## 代码分析、优化或验证工具

需要整理

## 元编程

简而言之，元编程就是关于创建操作源代码(比如修改、生成或包装原来的代码)的函数和类。

!!! info "主要技术"

    *装饰器
    *类装饰器
    *元类
    *签名对象
    *使用 exec() 执行代码
    *对内部函数和类的反射技术

###  @staticmethod @classMethod

但是通过例子发现staticmethod与classmethod的使用方法和输出结果相同，再看看这两种方法的区别。

既然@staticmethod和@classmethod都可以直接类名.方法名()来调用，那他们有什么区别呢
从它们的使用上来看,
@staticmethod不需要表示自身对象的self和自身类的cls参数，就跟使用函数一样。
@classmethod也不需要self参数，但第一个参数需要是表示自身类的cls参数。
如果在@staticmethod中要调用到这个类的一些属性方法，只能直接类名.属性名或类名.方法名。
而@classmethod因为持有cls参数，可以来调用类的属性，类的方法，实例化对象等，避免硬编码。


## Decorators for Functions and Methods
pyton对象，在内存中就是一个字典对象,更像JSON字符串
Python装饰器和元类
type可以接受一个类的描述作为参数，然后返回一个类。

[官方文档](https://www.python.org/dev/peps/pep-0318/)
https://www.cnblogs.com/cicaday/p/python-decorator.html
[Python中的闭包](https://betacat.online/posts/2016-10-23/python-closure/)
[Python中的装饰器](https://betacat.online/posts/2016-10-30/python-decorator-more/)
[元类](http://blog.jobbole.com/21351/)
[元类](https://blog.csdn.net/weixin_35955795/article/details/52985170)
[元类的使用](https://www.cnblogs.com/Security-Darren/p/4094959.html)
[判断、获取、设置属性](https://www.cnblogs.com/zanjiahaoge666/p/7475225.html)
[Python装饰器](https://www.cnblogs.com/zanjiahaoge666/p/7478962.html)
[Python中的魔法函数](https://www.cnblogs.com/zanjiahaoge666/p/7490824.html)
[装饰器](http://code.activestate.com/recipes/277940-decorator-for-bindingconstants-at-compile-time/)

## Python Typing 模块的使用
https://docs.python.org/zh-cn/3/library/typing.html#generics

## python __init__文件和构造方法__init__

https://www.cnblogs.com/Lands-ljk/p/5880483.html
http://www.cnblogs.com/insane-Mr-Li/p/9758776.html

### 泛型(Generics)

https://docs.python.org/zh-cn/3/library/typing.html#generics

## 理解Python的Dynamic typing
http://www.maixj.net/ict/python-dynamic-typing-13972

## Python hashlib模块
http://www.php.cn/python-tutorials-413249.html

## python之random模块分析
https://www.cnblogs.com/cwp-bg/p/7468475.html

## 常见的算法
https://www.cnblogs.com/cwp-bg/p/7476296.html

## 日志模块
https://www.cnblogs.com/cwp-bg/p/8632519.html

## 单元测试
https://www.cnblogs.com/cwp-bg/p/8761816.html

## 集合
https://www.cnblogs.com/cwp-bg/p/9524469.html

## 深拷贝

3.7.2_2/Frameworks/Python.framework/Versions/3.7/lib/python3.7/copy.py
