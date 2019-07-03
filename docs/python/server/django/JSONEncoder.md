# Python JsonEncoder

## 概述

序列化Django对象
Django的序列化框架提供了一种将Django模型“转换”为其他格式的机制。通常这些其他格式将基于文本并用于通过线路发送Django数据，但序列化程序可以处理任何格式（基于文本或不基于文本

## Django 默认序列化

Interfaces for serializing Django objects.

文件路径:env/lib/python3.7/site-packages/django/core/serializers/__init__.py
### 使用方法

    from django.core import serializers
    json = serializers.serialize("json", some_queryset)
    objects = list(serializers.deserialize("json", json))

### 添加自己的序列化器

To add your own serializers, use the SERIALIZATION_MODULES setting::

    SERIALIZATION_MODULES = {
        "csv": "path.to.csv.serializer",
        "txt": "path.to.txt.serializer",
    }

### 内建的序列化器
```Python
BUILTIN_SERIALIZERS = {
    "xml": "django.core.serializers.xml_serializer",
    "python": "django.core.serializers.python",
    "json": "django.core.serializers.json",
    "yaml": "django.core.serializers.pyyaml",
}
```

### 第三方开源库
[Json库](https://docs.python.org/3/library/json.html)

[pickle](https://docs.python.org/zh-cn/3/library/pickle.html#module-pickle)

[marshal](https://docs.python.org/zh-cn/3/library/marshal.html#module-marshal)
## 系统库路径

[库文件路径](/usr/local/Cellar/python/3.7.2_2/Frameworks/Python.framework/Versions/3.7/lib/python3.7/json/__init__.py)
[序列化Django对象](https://docs.djangoproject.com/en/2.2/topics/serialization/)
