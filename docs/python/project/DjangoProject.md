# Django 开发
## 开发步骤
1.需求分析
2.Django高级用法
3.算法
4.设计模式
5.TestCase测试
6.云计算服务

## Django
1.算法
2.实现效果
3.设计模式
4.框架原理


## 文档网站
1.知乎
2.segmentfault
3.Quora
4.stackoverflow

## 掌握的计算
1.Django高级用法
2.Channels实时消息推送
3.testCase 测试用例
4.数据库设计&网站优化
5.算法、设计模式+融合项目
6.云计算服务

## 环境搭建
1.使用pipenv管理项目环境
2.自定义用户模型
3.优先使用通用类视图
4.在系统环境变量中保存敏感信息
5.为不同环境分别配置settings.py文件
6.一定要编写测试用例(测试覆盖度)
### pipenv环境管理工具安装
[pipenv环境安装](https://segmentfault.com/a/1190000015143431)
[pipenv官网](https://pipenv.readthedocs.io/en/latest/)

## 视图
1.之定义用户视图
2.函数视图(FBV)
3.类视图(CBV)
4.通用视图(CBGV)
[Python类视图定义继承关系](http://ccbv.co.uk/)

## 在系统环境变量中保存敏感信息
依据Twelve-Factor方法论为Django应用配置环境变量
[12factor最佳实际](https://12factor.net/zh_cn/)
[更好的版本控制]

## 需求分析、功能设计、技术选型
使用百度脑图
需求分析-->规格说明书使用mkdown编写规格说明书-->功能设计-->技术选型
技术选型--->前端使用的计算-->后端使用的技术-->部署和运维-->数据库-->网站优化

## Cookiecutter环境安装
[让你的项目模板化和专业化](https://betacat.online/posts/2017-08-16/cookiecutter-intro/)
[如何创建Cookiecutter在Django文档中](https://swapps.com/blog/how-to-create-a-django-application-using-cookiecutter/)
[How to Install PostgreSQL Relational Databases on CentOS 7](https://www.linode.com/docs/databases/postgresql/how-to-install-postgresql-relational-databases-on-centos-7/)


## Python 部署原理


## parallels desktop 安装centos7默认密码和root问题
parallels desktop下载的centos7 默认用户名是parallels 密码是需要设置的。软件没有自动设置。密码必须大于8位；

并且无法进行su命令，提示 Authentication failure。

这个问题产生的原因是由于系统默认是没有激活root用户的，需要我们手工进行操作，在命令行界面下，或者在终端中输入如下命令：

sudo passwd
Password：你当前的密码
Enter new UNIX password：这个是root的密码
Retype new UNIX password：重复root的密码

然后会提示成功的信息。 在说明一点，使用su和sudo是有区别的，使用su切换用户需要输入所切换到的用户的密码，而使用sudo则是当前用户的密码。

## CentOS7
CentOS开发包的使用
[Paralle安装CentOS7](https://my.oschina.net/botkenni/blog/1592946)
[Python3安装](https://www.cnblogs.com/anxminise/p/9650206.html)
[CentOS Redis安装配置](https://www.cnblogs.com/zuidongfeng/p/8032505.html)
[CentOS Nginx安装](https://www.centos.bz/2018/01/centos-7%EF%BC%8C%E4%BD%BF%E7%94%A8yum%E5%AE%89%E8%A3%85nginx/)
[添加pip访问源](https://www.cnblogs.com/SciProgrammer/p/7795864.html)
