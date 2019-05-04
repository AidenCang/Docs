# Djnago 日志处理

## 禁用Django日志
setting文件中:

    LOGGING_CONFIG = None

## 自定义日志


使用配置文件配置日志Logging

```Python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# author:      AigeCang
#

from __future__ import unicode_literals, absolute_import

import logging
import logging.config
import logging.handlers
from datetime import datetime
import os


class _InfoFilter(logging.Filter):
    def filter(self, record):
        """only use INFO
        筛选, 只需要 INFO 级别的log
        :param record:
        :return:
        """
        if logging.INFO <= record.levelno < logging.ERROR:
            # 已经是INFO级别了
            # 然后利用父类, 返回 1
            return super().filter(record)
        else:
            return 0


def _get_filename(*, basename='app.log', log_level='info'):
    date_str = datetime.today().strftime('%Y%m%d')
    pidstr = str(os.getpid())
    return ''.join((
        date_str, '-', pidstr, '-', log_level, '-', basename,))


class _LogFactory:
    # 每个日志文件，使用 2GB
    _SINGLE_FILE_MAX_BYTES = 2 * 1024 * 1024 * 1024
    # 轮转数量是 10 个
    _BACKUP_COUNT = 10

    # 指定日志文件夹
    LOGGING_DIR = "web_project/log/"
    # 如果文件夹不存在，创建文件夹
    if not os.path.exists(LOGGING_DIR):
        os.mkdir(LOGGING_DIR)
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

    # 配置发送的邮件信息
    SERVER_EMAIL = 'sender@qq.com'
    DEFAULT_FROM_EMAIL = 'sender@qq.com'
    ADMINS = (('receiver', 'shenzhencuco@gmail.com'),)
    EMAIL_HOST = 'smtp.exmail.qq.com'
    EMAIL_HOST_USER = 'sender@qq.com'
    EMAIL_HOST_PASSWORD = '123456'
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

    # 基于 dictConfig，做再次封装
    _LOG_CONFIG_DICT = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            # 开发环境下的配置
            'dev': {
                'class': 'logging.Formatter',
                'format': ('%(levelname)s %(asctime)s %(created)f %(name)s %(module)s [%(processName)s %(threadName)s] '
                           '[%(filename)s %(lineno)s %(funcName)s] %(message)s')
            },
            # 生产环境下的格式(越详细越好)
            'prod': {
                'class': 'logging.Formatter',
                'format': ('%(levelname)s %(asctime)s %(created)f %(name)s %(module)s %(process)d %(thread)d '
                           '%(filename)s %(lineno)s %(funcName)s %(message)s')
            }
            # ? 使用UTC时间!!!
        },
        'filters': {  # 针对 LogRecord 的筛选器
            'info_filter': {
                '()': _InfoFilter,

            }
        },
        'handlers': {  # 处理器(被loggers使用)
            'console': {  # 按理来说, console只收集ERROR级别的较好
                'class': 'logging.StreamHandler',
                'level': 'ERROR',
                'formatter': 'dev'
            },
            'file': {
                'level': 'INFO',
                'class': 'logging.handlers.RotatingFileHandler',
                'filename': LOGGING_DIR + _get_filename(log_level='info'),
                'maxBytes': _SINGLE_FILE_MAX_BYTES,  # 2GB
                'encoding': 'UTF-8',
                'backupCount': _BACKUP_COUNT,
                'formatter': 'dev',
                'delay': True,
                'filters': ['info_filter', ]  # only INFO, no ERROR
            },
            'file_error': {
                'level': 'ERROR',
                'class': 'logging.handlers.RotatingFileHandler',
                'filename': LOGGING_DIR + _get_filename(log_level='error'),
                'maxBytes': _SINGLE_FILE_MAX_BYTES,  # 2GB
                'encoding': 'UTF-8',
                'backupCount': _BACKUP_COUNT,
                'formatter': 'dev',
                'delay': True,
            },

        },
        'loggers': {  # 真正的logger(by name), 可以有丰富的配置
            'SAMPLE_LOGGER': {
                # 输送到3个handler，它们的作用分别如下
                #   1. console：控制台输出，方便我们直接查看，只记录ERROR以上的日志就好
                #   2. file： 输送到文件，记录INFO以上的日志，方便日后回溯分析
                #   3. file_error：输送到文件（与上面相同），但是只记录ERROR级别以上的日志，方便研发人员排错
                'handlers': ['console', 'file', 'file_error'],
                'level': 'INFO',
            },
            'DEBUG_LOGGER': {
                # 输送到3个handler，它们的作用分别如下
                #   1. console：控制台输出，方便我们直接查看，只记录ERROR以上的日志就好
                #   2. file： 输送到文件，记录INFO以上的日志，方便日后回溯分析
                #   3. file_error：输送到文件（与上面相同），但是只记录ERROR级别以上的日志，方便研发人员排错
                'handlers': ['console', 'file', 'file_error'],
                'level': 'DEBUG',
            },
        },
    }
    logging.config.dictConfig(_LOG_CONFIG_DICT)

    @classmethod
    def get_logger(cls, logger_name):
        return logging.getLogger(logger_name)

```
使用配置的日志处理器记录日志信息
```Python
from hello.log_.log_factory.logger_factory import _LogFactory
logger1 = _LogFactory.get_logger("DEBUG_LOGGER")
    logger1.info("This is a info log.")
    logger1.warn("This is a warning log.")
    logger1.error("This is a error log.")
    logger1.critical("This is a critical log.")
```
## 使用注解发送发送邮件

使用注解方法实现发送错误日志文件
```Python
def decorator_error_monitor(title):
    def wrap(f):
        def wrapped_f(*args, **kwargs):
            try:
                result = f(*args, **kwargs)
                return result
            except:
                exc = traceback.format_exc()
                utils.send_exception_email(email_list, title, exc)
            raise Exception(exc)
        return wrapped_f
    return wrap
```
在代码中实现注解
```Python
@decorator_error_monitor("清算错误")
def do_settlement(users):
    for user in users:
        process_settlement_for_one_user(user)
```

## 使用代码配置日志文件

```Python
import logging
import logging.handlers
import datetime
import os
from web_project.settings import DEBUG

# 指定日志文件夹
LOGGING_DIR = "web_project/log/"
# 如果文件夹不存在，创建文件夹
if not os.path.exists(LOGGING_DIR):
    os.mkdir(LOGGING_DIR)

# 指定不同级别的日志等级
FILE_ERROR = LOGGING_DIR + 'error.log'
FILE_ALL = LOGGING_DIR + 'all.log'
FILE_DEBUG = LOGGING_DIR + 'debug.log'
# 设置统一的日志格式
LOG_FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
DATE_FORMAT = "%m/%d/%Y %H:%M:%S %p"

# logging.basicConfig(level=logging.DEBUG,
#                     filename=FILE_DEBUG,
#                     format=LOG_FORMAT,
#                     datefmt=DATE_FORMAT,
#                     )



logging.warning("Some one delete the log file.", exc_info=True,
                stack_info=True, extra={'user': 'Tom', 'ip': '47.98.53.222'})

logger = logging.getLogger('mylogger')
logger.setLevel(DEBUG)

rf_handler = logging.handlers.TimedRotatingFileHandler(
    FILE_ALL, when='midnight', interval=1, backupCount=7, atTime=datetime.time(0, 0, 0, 0))
rf_handler.setFormatter(logging.Formatter(LOG_FORMAT))

f_handler = logging.FileHandler(FILE_ERROR)
f_handler.setLevel(logging.WARN)
f_handler.setFormatter(logging.Formatter(
    "%(asctime)s - %(levelname)s - %(filename)s[:%(lineno)d] - %(message)s"))

logger.addHandler(rf_handler)
logger.addHandler(f_handler)

```
## 链接

[Python日志文件](https://docs.python.org/3/library/logging.html#module-logging)

[Python 日志处理](https://www.cnblogs.com/yyds/p/6901864.html)

[日志处理](https://segmentfault.com/a/1190000016068105)

[自定义日志库](https://juejin.im/post/5afe3ddf518825673564c0f6)

[Django系统错误监控](https://www.jianshu.com/p/42e4287ffeda)
