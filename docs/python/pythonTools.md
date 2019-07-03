# Python 开发相关工具

## 全栈Python工程师网站
[全栈工程师网站](https://www.fullstackpython.com/)
[Django官网](https://www.djangoproject.com/)
[django-transaction-hooks](https://github.com/carljm/django-transaction-hooks)

## 系统进程管理工具
[Supervisor](http://supervisord.org/)
[Celery启动进程](http://docs.celeryproject.org/en/master/userguide/daemonizing.html#daemonizing)
[Django3.0Setting配置](https://django.readthedocs.io/en/latest/topics/settings.html#envvar-DJANGO_SETTINGS_MODULE)
## Python 版本管理工具

[pyenv](https://github.com/pyenv/pyenv)
[Python环境配置](https://www.imooc.com/video/17960)

## 协议
[HTTP/2](https://fly.io/articles/http2-for-devs/)
[HTTP/2youtube视频](https://www.youtube.com/watch?v=JsTptu56GM8)
[HTTP迁移到HTTP2](https://www.keycdn.com/blog/http-to-https)
[Let’s Encrypt免费证书申请机构](https://letsencrypt.org/)


## 任务调度库
常用的定时任务:apscheduler/django-crontab/Linux定时任务、Celery异步任务
[定时任务参考教程](https://segmentfault.com/a/1190000016515891)
[定时任务参考](https://juejin.im/post/5b588b8c6fb9a04f834655a6)

[高级Python调度程序](https://apscheduler.readthedocs.io/en/latest/#)
[RabbitMQ](http://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html#id3)
[RabbitMQ官网](https://www.rabbitmq.com/)
[RabbitMQ简单的介绍](https://www.cnblogs.com/luxiaoxun/p/3918054.html)

Celery是一个简单、灵活且可靠的，处理大量消息的分布式系统
专注于实时处理的异步任务队列
同时也支持任务调度

使用场景:
异步任务:将耗时的操作任务提交给Celery去异步执行，比如发送短信、邮件、消息推送、音视频处理等
定时任务：类似于crontab，比如每日数据统计

[Celery文档](http://docs.celeryproject.org/en/latest/index.html)
[Celery消息分发后端Brokers](http://docs.celeryproject.org/en/latest/getting-started/brokers/)
[django-celery-results](https://django-celery-results.readthedocs.io/en/latest/)
[django-celery-beat](https://django-celery-beat.readthedocs.io/en/latest/)
[定时任务](http://docs.celeryproject.org/en/latest/userguide/periodic-tasks.html#id8)
[定时任务开发案例](https://www.merixstudio.com/blog/django-celery-beat/)
[AMQP协议](https://blog.csdn.net/weixin_37641832/article/details/83270778)


## 并发事件库
[eventlet](https://pypi.org/project/eventlet/)
[gevent](https://pypi.org/project/gevent/)

## 多进程库
[billiard](https://pypi.org/project/billiard/)
## aws Python网站
[学习资料库](https://medium.com/)
[aws Python 网站](https://aws.amazon.com/cn/getting-started/projects/build-modern-app-fargate-lambda-dynamodb-python/)
[aws Python 开发站点](https://aws.amazon.com/cn/developer/)

## 常用的库
[垃圾留言过滤系统](https://pypi.org/project/python-akismet/0.2.3/)
[akismet](https://akismet.com/how/)

## 安全相关
[安全策略](https://en.wikipedia.org/wiki/Security_policy)
[cryptography](https://pypi.org/project/cryptography/)
[文件完整性/基于主机的入侵检测系统](https://www.tripwire.com/products/)
[文件完整性/基于主机的入侵检测系统](https://www.la-samhna.de/samhain/index.html)
[Open Source Tripwire](https://sourceforge.net/projects/tripwire/)
[开源入侵检测系统](https://www.ossec.net/)


## tox

What is tox?

tox is a generic virtualenv management and test command line tool you can use for:

checking your package installs correctly with different Python versions and interpreters

running your tests in each of the environments, configuring your test tool of choice

acting as a frontend to Continuous Integration servers, greatly reducing boilerplate and merging CI and shell-based testing.

[tox](https://tox.readthedocs.io/en/latest/)



## 调试工具
[Debug工具](https://github.com/jazzband/django-debug-toolbar)


## LRU Cache
[LRUCache](/usr/local/Cellar/python/3.7.2_2/Frameworks/Python.framework/Versions/3.7/lib/python3.7/functools.py)

[django-uniauth对用户进行身份验证](https://github.com/lgoodridge/django-uniauth/)

[JWT认证方式:JSON Web令牌（JWT）](https://jwt.io/)

[ServerLess](https://serverless.com/)

[AWS 远程开发调试工具](https://console.aws.amazon.com/lambda/home?region=us-east-1#/applications/myService-dev)

## 监控工具
[Prometheus]()
[django-prometheus](https://github.com/korfuri/django-prometheus)
[如何解释网站性能测试](https://fly.io/articles/how-to-understand-performance-tests/)
