# Python 基础
[Python 文档](https://python3-cookbook.readthedocs.io/zh_CN/latest/index.html)

global nolocal 分别代表的意思

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

<!-- itertools -->
# itertools
# with
# enumerate
# 你构建了一个自定义容器对象，里面包含有列表、元组或其他可迭代对象。 你想直接在你的这个新容器对象上执行迭代操作。
# 实际上，这种解压赋值可以用在任何可迭代对象上面，而不仅仅是列表或者元组。 包括字符串，文件对象，迭代器和生成器。
# yield 表达式的生成器函数
# 我们在写查询元素的代码时，通常会使用包含 yield 表达式的生成器函数，也就是我们上面示例代码中的那样。 这样可以将搜索过程代码和使用搜索结果代码解耦。如果你还不清楚什么是生成器，请参看 4.3 节。
<!-- lambda -->
<!-- callable -->
<!-- contextlib -->
<!-- contextmanager -->
模块与包是任何大型程序的核心，就连Python安装程序本身也是一个包。本章重点涉及有关模块和包的常用编程技术，例如如何组织包、把大型模块分割成多个文件、创建命名空间包。同时，也给出了让你自定义导入语句的秘籍。

__init__.py 会在模块导入时预先导入
延迟加载的主要缺点是继承和类型检查可能会中断
延迟加载的真实例子, 见标准库 multiprocessing/__init__.py 的源码.

### 使用python文件生成zip包
bash % ls
spam.py bar.py grok.py __main__.py
bash % zip -r myapp.zip *.py
bash % python3 myapp.zip
... output from __main__.py ...

## 函数
使用 def 语句定义函数是所有程序的基础。 本章的目标是讲解一些更加高级和不常见的函数定义与使用模式。 涉及到的内容包括默认参数、任意数量参数、强制关键字参数、注解和闭包。 另外，一些高级的控制流和利用回调函数传递数据的技术在这里也会讲解到。

使用一个内部函数或者闭包的方案通常会更优雅一些。简单来讲，一个闭包就是一个函数， 只不过在函数内部带上了一个额外的变量环境。闭包关键特点就是它会记住自己被定义时的环境。 因此，在我们的解决方案中，opener() 函数记住了 template 参数的值，并在接下来的调用中使用它。

## 类
包括让对象支持常见的Python特性、特殊方法的使用、 类封装技术、继承、内存管理以及有用的设计模式。


### 元类

软件开发领域中最经典的口头禅就是“don’t repeat yourself”。 也就是说，任何时候当你的程序中存在高度重复(或者是通过剪切复制)的代码时，都应该想想是否有更好的解决方案。 在Python当中，通常都可以通过元编程来解决这类问题。 简而言之，元编程就是关于创建操作源代码(比如修改、生成或包装原来的代码)的函数和类。 主要技术是使用装饰器、类装饰器和元类。不过还有一些其他技术， 包括签名对象、使用 exec() 执行代码以及对内部函数和类的反射技术等。 本章的主要目的是向大家介绍这些元编程技术，并且给出实例来演示它们是怎样定制化你的源代码行为的

## 线程
Python中的线程会在一个单独的系统级线程中执行（比如说一个 POSIX 线程或者一个 Windows 线程），这些线程将由操作系统来全权管理。
后台线程无法等待，不过，这些线程会在主线程终止时自动销毁

死锁的检测与恢复是一个几乎没有优雅的解决方案的扩展话题。一个比较常用的死锁检测与恢复的方案是引入看门狗计数器。当线程正常 运行的时候会每隔一段时间重置计数器，在没有发生死锁的情况下，一切都正常进行。一旦发生死锁，由于无法重置计数器导致定时器 超时，这时程序会通过重启自身恢复到正常状态。

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
