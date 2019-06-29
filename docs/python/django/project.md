# Django 实战项目

## 环境搭建
pycharm && vscode
mysql/navicat
virturlenv和virtualenvwrapper
ver项目环境搭建
资源获取，版权说明
Python pip 安装包的使用方法
浏览器JSONView

## 前后端分离开发
1.app、pc、pad多端适配
2.SPA开发模式
3.前后端职责不清
4.开发效率低，存在等待的现象
5.前端一直配合着后端，能力有限
6.后台开发模板高度耦合，导致开发语言依赖严重

缺点
1.前端学习门槛增加
2.数据依赖导致文档依赖增加
3.前端工作量增加
4.SEO的难度增加(ssr提高排名)
5.后端开发迁移模板

Restful api 前后端分离的最佳实践
文章 理解Restful api架构
    Restful Api设计指南

前端Vue，Vue插件
1.前端工程化
2.数据双向绑定
3.组件开发

webpack
vue，vuex，vue-router，axios
ES6，babel




查看mysql是否已经启动
ps aux|grep mysqld

(env) ➜  MxShop pip list

    Package             Version
    ------------------- --------
    certifi             2019.3.9
    chardet             3.0.4
    coreapi             2.3.3
    coreschema          0.0.4
    Django              2.2.1
    django-crispy-forms 1.7.2
    django-filter       2.1.0
    django-guardian     1.5.1
    djangorestframework 3.9.4
    idna                2.8
    itypes              1.1.0
    Jinja2              2.10.1
    Markdown            3.1
    MarkupSafe          1.1.1
    pip                 18.1
    pytz                2019.1
    requests            2.21.0
    setuptools          40.6.2
    sqlparse            0.3.0
    uritemplate         3.0.0
    urllib3             1.24.3
    You are using pip version 18.1, however version 19.1.1 is available.
    You should consider upgrading via the 'pip install --upgrade pip' command.

[vscodevscode开发Django](https://code.visualstudio.com/docs/python/tutorial-django)
[vsCode Django Debug](https://code.visualstudio.com/docs/python/debugging)
创建Python虚拟运行环境

    # macOS/Linux
    sudo apt-get install python3-venv    # If needed
    python3 -m venv env

    # Windows
    python -m venv env

## Vue.js的安装
npm install
npm run dev #可以在浏览器中打开相关的类

目录文件
apps：保存所有的app
# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 添加更目录下的app、extras_app到查找路径中
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, os.path.join(BASE_DIR, 'apps'))
sys.path.insert(0, os.path.join(BASE_DIR, 'extras_app'))

### vscode Django 开发

[Vscode 开发Django](https://code.visualstudio.com/docs/python/tutorial-django)
[RestApi安装](https://www.django-rest-framework.org/)

## xadmin

[Xadmin](后台管理系统)
[xadmin开发文档](https://xadmin.readthedocs.io/en/latest/quickstart.html)
修改xadmin语言：
1.修改Django中的语言环境

    #设置时区
    LANGUAGE_CODE = 'zh-hans'  # 中文支持，django1.8以后支持；1.8以前是zh-cn
    TIME_ZONE = 'Asia/Shanghai'
    USE_I18N = True
    USE_L10N = True
    USE_TZ = False  # 默认是Ture，时间是utc时间，由于我们要用本地时间，所用手动修改为false！！！！

2.修改app中的config：

    class GoodsConfig(AppConfig):
    name = 'goods'
    verbose_name = "商品"

pip install mysqlclient
pip install pillow # 作为图片处理的包
pip install djangorestframework
pip install markdown       # Markdown support for the browsable API.
pip install django-filter  # Filtering support



跨域解决问题:
Django cors headers 库去解决
前端使用Proxy.js 代理类来解决

前后端分离之JWT
DjangoUediter 富文本编辑器
(env) ➜  MxShop pip install DjangoUeditor
[GitHub上可以找到](https://github.com/twz915/DjangoUeditor3)


## 扩展User类



## navigate 登录错误修复

安装数据库Mysql连接：
(env) ➜  MxShop pip install mysqlclient
[处理数据库连接错误问题:](https://stackoverflow.com/questions/21944936/error-1045-28000-access-denied-for-user-rootlocalhost-using-password-y
)
[设置默认存储引擎](https://stackoverflow.com/questions/37175295/cant-migrate-django-databases-on-mysql-after-upgrading-to-ubuntu-16-04)
[Django 数据库处理](https://simpleisbetterthancomplex.com/tutorial/2016/07/26/how-to-reset-migrations.html)
### 数据库配置:

DATABASES = {
'default':{
  'ENGINE':'django.db.backends.mysql',
  'NAME':'mxshop',
  'PASSWORD':'root',
  'HOST':"127.0.0.1",
  'OPTIONS':{
  'init_command':'SET storage_engine=INNODB;'
  }
}
}

提示错误

    Authentication plugin 'caching_sha2_password' cannot be loaded: dlopen(/usr/local/mysql/lib/plugin/caching_sha2_password.so, 2): image not found

    ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '@Cangck123';
