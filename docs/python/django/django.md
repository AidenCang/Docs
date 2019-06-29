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
