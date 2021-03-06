# Django signals

Django包含一个“信号调度程序”，它有助于在框架中的其他位置发生操作时通知分离的应用程序。简而言之，信号允许某些发送者通知一组接收器已经发生了某些动作。当许多代码片段可能对相同的事件感兴趣时，它们特别有用。


!!! info "Django signals 有三部分组成"

      * class Signal
      * receiver
      * 信号

!!! info "注册信号的两种方式"

    * 1.使用Singal connect方法进行注册
    * 2.使用注解函数进行注册

可以通过`sender`来标记处理函数处理的是哪一个方式者传递的信息

## 例子:
```Python
from django.core.signals import request_finished
from django.dispatch import receiver
from django.dispatch import Signal

/* 注册一个信号 */
pizz_done = Signal(providing_args=["toppings", 'size'])


# 使用一个注解方式注册一个请求完成信号，每一个请求完成是都会调用该方法(系统内置的信号)
# @receiver(request_finished)
def my_callback(sender, **kwargs):
    #这个是上面我们自定义的信号,调用`send`方法发送信号
    pizz_done.send(sender="ABC", toppings='pizza', size=20)
    print("Request finished!")


@receiver(pizz_done, sender="ABC")
def pizz_done_receiver(sender, **kwargs):
    print("我在%s时间收到来自%s的信号，请求size为%s" %
          (kwargs['toppings'], sender, kwargs["size"]))
    print(id(pizz_done_receiver))

def pizaa_done_receive(sender, **kwargs):
    print("使用connect连接")

#使用`connect`方法添加接收函数到Singal接收列表中
pizz_done.connect(pizaa_done_receive)
```
```shell
/* 在URL中导入上述的带内容,在浏览器中服务一下服务器的方法就可以调用上面的信号机制 */
我在pizza时间收到来自ABC的信号，请求url为20
使用connect连接
Request finished!
```

## 源码解析
使用到的关键技术和方法:

1.threading:主要是使用线程中的锁机制，保证Signal类能够对类中的接收者进行处理操作，保证操作接收者相关的信息操作的原子性

2.weakref:弱引用，保证对象在内存中可以被回收

3.inspect:使用Python的模块，对传入参数的检查(内省高级操作)

4.__init__:`__init__`方法，创建一个新的信号对象，并且定义一个`list`列表来保存连接到信号的接收者、使用`providing_args`列表来保存自定义的参数

5.connect:主要是关联接收者和发送者的关系并且使用弱引用保存接收者方法

6.disconnect

7.has_listeners

8.send:主要用来发送信息到接收者

9.send_robust

一下几个方法是对弱引用中的接收者进行清理操作

10._clear_dead_receivers

11._live_receivers

12._remove_receiver


```Python
import threading
import weakref

from django.utils.inspect import func_accepts_kwargs


def _make_id(target):
    if hasattr(target, '__func__'):
        return (id(target.__self__), id(target.__func__))
    return id(target)


NONE_ID = _make_id(None)

# A marker for caching
NO_RECEIVERS = object()


class Signal:
    """
    Base class for all signals

    Internal attributes:

        receivers
            { receiverkey (id) : weakref(receiver) }
    """
    def __init__(self, providing_args=None, use_caching=False):
        """
        Create a new signal.

        providing_args
            A list of the arguments this signal can pass along in a send() call.
        """
        self.receivers = []
        if providing_args is None:
            providing_args = []
        self.providing_args = set(providing_args)
        self.lock = threading.Lock()
        self.use_caching = use_caching
        # For convenience we create empty caches even if they are not used.
        # A note about caching: if use_caching is defined, then for each
        # distinct sender we cache the receivers that sender has in
        # 'sender_receivers_cache'. The cache is cleaned when .connect() or
        # .disconnect() is called and populated on send().
        self.sender_receivers_cache = weakref.WeakKeyDictionary() if use_caching else {}
        self._dead_receivers = False

    def connect(self, receiver, sender=None, weak=True, dispatch_uid=None):
        """
        Connect receiver to sender for signal.

        Arguments:

            receiver
                A function or an instance method which is to receive signals.
                Receivers must be hashable objects.

                If weak is True, then receiver must be weak referenceable.

                Receivers must be able to accept keyword arguments.

                If a receiver is connected with a dispatch_uid argument, it
                will not be added if another receiver was already connected
                with that dispatch_uid.

            sender
                The sender to which the receiver should respond. Must either be
                a Python object, or None to receive events from any sender.

            weak
                Whether to use weak references to the receiver. By default, the
                module will attempt to use weak references to the receiver
                objects. If this parameter is false, then strong references will
                be used.

            dispatch_uid
                An identifier used to uniquely identify a particular instance of
                a receiver. This will usually be a string, though it may be
                anything hashable.
        """
        from django.conf import settings

        # If DEBUG is on, check that we got a good receiver
        if settings.configured and settings.DEBUG:
            assert callable(receiver), "Signal receivers must be callable."

            # Check for **kwargs
            if not func_accepts_kwargs(receiver):
                raise ValueError("Signal receivers must accept keyword arguments (**kwargs).")

        if dispatch_uid:
            lookup_key = (dispatch_uid, _make_id(sender))
        else:
            lookup_key = (_make_id(receiver), _make_id(sender))

        if weak:
            ref = weakref.ref
            receiver_object = receiver
            # Check for bound methods
            if hasattr(receiver, '__self__') and hasattr(receiver, '__func__'):
                ref = weakref.WeakMethod
                receiver_object = receiver.__self__
            receiver = ref(receiver)
            weakref.finalize(receiver_object, self._remove_receiver)

        with self.lock:
            self._clear_dead_receivers()
            if not any(r_key == lookup_key for r_key, _ in self.receivers):
                self.receivers.append((lookup_key, receiver))
            self.sender_receivers_cache.clear()

    def disconnect(self, receiver=None, sender=None, dispatch_uid=None):
        """
        Disconnect receiver from sender for signal.

        If weak references are used, disconnect need not be called. The receiver
        will be removed from dispatch automatically.

        Arguments:

            receiver
                The registered receiver to disconnect. May be none if
                dispatch_uid is specified.

            sender
                The registered sender to disconnect

            dispatch_uid
                the unique identifier of the receiver to disconnect
        """
        if dispatch_uid:
            lookup_key = (dispatch_uid, _make_id(sender))
        else:
            lookup_key = (_make_id(receiver), _make_id(sender))

        disconnected = False
        with self.lock:
            self._clear_dead_receivers()
            for index in range(len(self.receivers)):
                (r_key, _) = self.receivers[index]
                if r_key == lookup_key:
                    disconnected = True
                    del self.receivers[index]
                    break
            self.sender_receivers_cache.clear()
        return disconnected

    def has_listeners(self, sender=None):
        return bool(self._live_receivers(sender))

    def send(self, sender, **named):
        """
        Send signal from sender to all connected receivers.

        If any receiver raises an error, the error propagates back through send,
        terminating the dispatch loop. So it's possible that all receivers
        won't be called if an error is raised.

        Arguments:

            sender
                The sender of the signal. Either a specific object or None.

            named
                Named arguments which will be passed to receivers.

        Return a list of tuple pairs [(receiver, response), ... ].
        """
        if not self.receivers or self.sender_receivers_cache.get(sender) is NO_RECEIVERS:
            return []

        return [
            (receiver, receiver(signal=self, sender=sender, **named))
            for receiver in self._live_receivers(sender)
        ]

    def send_robust(self, sender, **named):
        """
        Send signal from sender to all connected receivers catching errors.

        Arguments:

            sender
                The sender of the signal. Can be any Python object (normally one
                registered with a connect if you actually want something to
                occur).

            named
                Named arguments which will be passed to receivers. These
                arguments must be a subset of the argument names defined in
                providing_args.

        Return a list of tuple pairs [(receiver, response), ... ].

        If any receiver raises an error (specifically any subclass of
        Exception), return the error instance as the result for that receiver.
        """
        if not self.receivers or self.sender_receivers_cache.get(sender) is NO_RECEIVERS:
            return []

        # Call each receiver with whatever arguments it can accept.
        # Return a list of tuple pairs [(receiver, response), ... ].
        responses = []
        for receiver in self._live_receivers(sender):
            try:
                response = receiver(signal=self, sender=sender, **named)
            except Exception as err:
                responses.append((receiver, err))
            else:
                responses.append((receiver, response))
        return responses

    def _clear_dead_receivers(self):
        # Note: caller is assumed to hold self.lock.
        if self._dead_receivers:
            self._dead_receivers = False
            self.receivers = [
                r for r in self.receivers
                if not(isinstance(r[1], weakref.ReferenceType) and r[1]() is None)
            ]

    def _live_receivers(self, sender):
        """
        Filter sequence of receivers to get resolved, live receivers.

        This checks for weak references and resolves them, then returning only
        live receivers.
        """
        receivers = None
        if self.use_caching and not self._dead_receivers:
            receivers = self.sender_receivers_cache.get(sender)
            # We could end up here with NO_RECEIVERS even if we do check this case in
            # .send() prior to calling _live_receivers() due to concurrent .send() call.
            if receivers is NO_RECEIVERS:
                return []
        if receivers is None:
            with self.lock:
                self._clear_dead_receivers()
                senderkey = _make_id(sender)
                receivers = []
                for (receiverkey, r_senderkey), receiver in self.receivers:
                    if r_senderkey == NONE_ID or r_senderkey == senderkey:
                        receivers.append(receiver)
                if self.use_caching:
                    if not receivers:
                        self.sender_receivers_cache[sender] = NO_RECEIVERS
                    else:
                        # Note, we must cache the weakref versions.
                        self.sender_receivers_cache[sender] = receivers
        non_weak_receivers = []
        for receiver in receivers:
            if isinstance(receiver, weakref.ReferenceType):
                # Dereference the weak reference.
                receiver = receiver()
                if receiver is not None:
                    non_weak_receivers.append(receiver)
            else:
                non_weak_receivers.append(receiver)
        return non_weak_receivers

    def _remove_receiver(self, receiver=None):
        # Mark that the self.receivers list has dead weakrefs. If so, we will
        # clean those up in connect, disconnect and _live_receivers while
        # holding self.lock. Note that doing the cleanup here isn't a good
        # idea, _remove_receiver() will be called as side effect of garbage
        # collection, and so the call can happen while we are already holding
        # self.lock.
        self._dead_receivers = True
```
## @receiver

使用注解的方法把需要注册的方法添加到接收列表中
```Python
def receiver(signal, **kwargs):
    """
    A decorator for connecting receivers to signals. Used by passing in the
    signal (or list of signals) and keyword arguments to connect::

        @receiver(post_save, sender=MyModel)
        def signal_receiver(sender, **kwargs):
            ...

        @receiver([post_save, post_delete], sender=MyModel)
        def signals_receiver(sender, **kwargs):
            ...
    """
    def _decorator(func):
        if isinstance(signal, (list, tuple)):
            for s in signal:
                s.connect(func, **kwargs)
        else:
            signal.connect(func, **kwargs)
        return func
    return _decorator
```
## 参考:
[Django信号文档](https://docs.djangoproject.com/en/2.2/topics/signals/#listening-to-signals)

[Django 内置信号文档](https://docs.djangoproject.com/en/2.2/ref/signals/)



# Django 源码解析

## functools模块

<!-- # Python module wrapper for _functools C module
# to allow utilities written in Python to be added
# to the functools module.
# Written by Nick Coghlan <ncoghlan at gmail.com>,
# Raymond Hettinger <python at rcn.com>,
# and Łukasz Langa <lukasz at langa.pl>.
#   Copyright (C) 2006-2013 Python Software Foundation.
# See C source code for _functools credits/copyright -->

### update_wrapper() and wraps() decorator
### total_ordering class decorator
### cmp_to_key() function converter
### partial() argument application
### LRU Cache function decorator
### singledispatch() - single-dispatch generic function decorator

下列包的使用:
    import collections.abc
    import inspect
    import warnings
    from math import ceil
/usr/local/Cellar/python/3.7.2_2/Frameworks/Python.framework/Versions/3.7/lib/python3.7/functools.py

## Django模板

Django作为一个Web框架，需要动态输出HTML文件，需要动态的渲染HTML文件和插件动态的内容到HTML标签中
Django支持内置的模板引擎和第三方模板引擎`jinja2`

Django定义了一个标准API，用于加载和呈现模板，无论后端如何。加载包括查找给定标识符的模板并对其进行预处理，通常将其编译为内存中表示。渲染意味着使用上下文数据插入模板并返回结果字符串。

### 配置

使用该TEMPLATES设置配置模板引擎。这是一个配置列表，每个引擎一个。默认值为空。在 settings.py由所产生的startproject命令定义一个更有用的值：

```shell
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            # ... some options here ...
        },
    },
]
```
BACKEND是实现Django模板后端API的模板引擎类的虚线Python路径。内置后端是django.template.backends.django.DjangoTemplates和 django.template.backends.jinja2.Jinja2。

由于大多数引擎从文件加载模板，因此每个引擎的顶级配置包含两个常用设置：

DIRS 定义引擎应按搜索顺序查找模板源文件的目录列表。
APP_DIRS告诉引擎是否应该在已安装的应用程序中查找模板。每个后端都定义了应该存储其模板的应用程序内的子目录的常规名称。
虽然不常见，但可以使用不同的选项配置同一后端的多个实例。在这种情况下，您应该NAME为每个引擎定义唯一 的。

OPTIONS 包含特定于后端的设置。

### 关键类
1.Engine:env/lib/python3.7/site-packages/django/template/engine.py
2.Loader
3.Template
4.EngineHandler:env/lib/python3.7/site-packages/django/template/utils.py
5.BaseEngine:env/lib/python3.7/site-packages/django/template/backends/base.py
### 表单

[表单工具](https://github.com/django/django-formtools)
[Comment工具](https://github.com/django/django-contrib-comments)
### Django模板语言

[Django模板语言](https://docs.djangoproject.com/en/2.2/ref/templates/language/)
[Django模板语言](https://docs.djangoproject.com/en/2.2/ref/templates/api/#django.template.base.Origin)
[Django内建标签和过滤](https://docs.djangoproject.com/en/2.2/ref/templates/builtins/#ref-templates-builtins-tags)
[自定义标签和过滤器](https://docs.djangoproject.com/en/2.2/howto/custom-template-tags/#howto-writing-custom-template-tags)

### 基于类的视图

[Django基于类的视图](https://docs.djangoproject.com/en/2.2/ref/class-based-views/mixins/)

### 条件处理

HTTP客户端可以发送许多标头，以告知服务器有关他们已经看过的资源的副本。这通常在检索网页（使用HTTP GET请求）时使用，以避免发送客户端已检索的内容的所有数据。然而，相同的标头可用于所有HTTP方法（POST，PUT，DELETE等等）。

ConditionalGetMiddleware
 django.views.decorators.http.condition装饰器

!!! info "小心装饰器的顺序"



    当condition()返回条件响应时，它下面的任何装饰器都将被跳过，并且不会应用于响应。因此，任何需要应用于常规视图响应和条件响应的装饰器必须在上面condition()。特别是
    vary_on_cookie()
    vary_on_headers()和
    cache_control()应该是第一位的，因为RFC 7232要求它们设置的标头出现在304响应中。

### 国际化和本地化
在http头部使用`Accept-Language`来标记输入的语言类型


!!! info "警告""

    翻译和格式分别由USE_I18N和 USE_L10N设置控制。但是，这两个特征都涉及国际化和本地化。设置的名称是Django历史的不幸结果。

以下是一些有助于我们处理共同语言的其他术语：

    区域设置名称
    区域设置名称，表单的语言规范ll或表单的组合语言和国家/地区规范ll_CC。例如：it，de_AT，es，pt_BR。语言部分始终为小写，而国家/地区部分为大写。分隔符是下划线。
    语言代码
    表示语言的名称。浏览器Accept-Language使用此格式发送它们在HTTP标头中接受的语言的名称。例如：it，de-at，es，pt-br。语言代码通常以小写形式表示，但HTTP Accept-Language 标头不区分大小写。分隔符是破折号。
    消息文件
    消息文件是纯文本文件，表示单个语言，包含所有可用的翻译字符串以及如何以给定语言表示它们。邮件文件具有.po文件扩展名。
    翻译字符串
    可以翻译的文字。
    格式文件
    格式文件是一个Python模块，用于定义给定语言环境的数据格式。
[文本翻译](https://docs.djangoproject.com/en/2.2/topics/i18n/translation/)
[日期时间格式化](https://docs.djangoproject.com/en/2.2/topics/i18n/formatting/)
[时区](https://docs.djangoproject.com/en/2.2/topics/i18n/timezones/)
[国际化](https://github.com/django/django-localflavor)
