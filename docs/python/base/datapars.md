# 数据库类型
mongodb
Elasticsearch

[gaode_spider](https://github.com/kenneth663/gaode_spider)
[豆瓣源安装Scrapy](pip install -i https://pypi.douban.com/simple/ scrapy)

[异步调度和处理的](https://docs.scrapy.org/en/latest/topics/architecture.html#topics-architecture)
[使用自动限制扩展](https://docs.scrapy.org/en/latest/topics/autothrottle.html#topics-autothrottle)
[选择器提取数据](https://docs.scrapy.org/en/latest/topics/selectors.html#topics-selectors)
[Shell控制台](https://docs.scrapy.org/en/latest/topics/shell.html#topics-shell)
[存储后端]
[站点地地图](https://www.sitemaps.org/index.html)
[自动下载](https://docs.scrapy.org/en/latest/topics/media-pipeline.html#topics-media-pipeline)
[Telnet控制台](https://docs.scrapy.org/en/latest/topics/telnetconsole.html#topics-telnetconsole)
[信号机制](https://docs.scrapy.org/en/latest/topics/signals.html#topics-signals)
[扩展支持](https://docs.scrapy.org/en/latest/index.html#extending-scrapy)

#常使用的库

[lxml](http://lxml.de/), an efficient XML and HTML parser
[parsel](https://pypi.python.org/pypi/parsel), an HTML/XML data extraction library written on top of lxml,
[w3lib](https://pypi.python.org/pypi/w3lib), a multi-purpose helper for dealing with URLs and web page encodings
[twisted](https://twistedmatrix.com/), an asynchronous networking framework
[cryptography](https://cryptography.io/) and [pyOpenSSL](https://pypi.org/project/pyOpenSSL/), to deal with various network-level security needs

cookie和会话处理
HTTP功能，如压缩，身份验证，缓存
用户代理欺骗
的robots.txt
爬行深度限制
和更多
输出格式


内省和调试Scrapy

# Python 内存管理
[Python Memory Management](https://www.evanjones.ca/python-memory.html)
[Python Memory Management Part 2](https://www.evanjones.ca/python-memory-part2.html)
[Python Memory Management Part 3: The Saga is Over](https://www.evanjones.ca/python-memory-part3.html)

## 开发工具

[web元素选择器](https://selectorgadget.com/)
[Css](https://www.w3.org/TR/selectors)
[Xpath](https://www.w3.org/TR/xpath/all/)
[JQJson命令行解析器](https://stedolan.github.io/jq/)
[跟踪内存泄漏](https://docs.scrapy.org/en/latest/topics/leaks.html#topics-leaks-trackrefs)
[wgrep](https://github.com/stav/wgrep)
[scrapy-splash](https://github.com/scrapy-plugins/scrapy-splash)
[Json-RPC](http://www.jsonrpc.org/)
[代理工具使用](https://blog.csdn.net/qq_27378621/article/details/81012561)
[youtube视频下载工具](https://www.bbsmax.com/A/l1dyYnoxde/)
## 代码片段

```Python
from setuptools import setup, find_packages

setup(name='scrapy-mymodule',
  entry_points={
    'scrapy.commands': [
      'my_command=my_scrapy_module.commands:MyCommand',
    ],
  },
 )
```

```Python
def __init__(self, *args, **kwargs):
       self._values = {}
       if args or kwargs:  # avoid creating dict for most common case
           for k, v in six.iteritems(dict(*args, **kwargs)):
               self[k] = v
```

https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.channels.list?part=snippet,contentDetails&publishedAfter=2016-11-01T00:00:00Z&publishedBefore=2017-12-31T00:00:00Z&id='+ channel_id + '&key=AIzaSyA8vpkk5FE2ImCoZYK9SfApRyUZipQd0j0'
