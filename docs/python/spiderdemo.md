# scrapy相关知识点

Scrapy 官网:
https://doc.scrapy.org/en/latest/index.html

Scrapy github仓库:
https://github.com/scrapy/scrapy

Github仓库:
https://github.com/cangchengkun/ScrapyDemo


settings 类的使用:
Scrapy  事件驱动的网络库:Twisted
https://twistedmatrix.com/trac/

运行Scrapy脚本:
https://www.cnblogs.com/lawlietfans/p/7475742.html

使用脚本方式启动spider:
https://www.cnblogs.com/lawlietfans/p/7475742.html

Python爬虫scrapy-redis分布式实例
https://www.cnblogs.com/xinyangsdut/p/7631222.html

Python模拟登陆京东
https://blog.csdn.net/qq_34288630/article/details/80669052

python爬虫selenium+firefox抓取京东商品评论
https://blog.csdn.net/castingA3T/article/details/79099468

使用python抓取京东全站数据（商品，店铺，分类，评论）
https://blog.csdn.net/Kandy_Ye/article/details/70183110


Pyton使用文件读取系统中的配置文件
    /Users/cuco/PycharmProjects/ScrapyJindong/test/test.py

调用命令行工具执行
scrapy.commands.shell.Command

python 内建类型和方法:
/Users/cuco/Library/Caches/PyCharm2018.1/python_stubs/-1556761322/builtins.py

###使用系统默认的类来构造类扩展
scrapy genspider -t crawl tencentcrawl  tencent.com

信号机制:
/Users/cuco/PycharmProjects/ScrapyJindong/venv/lib/python3.7/site-packages/scrapy/utils/signal.py

系统警告信息:
/usr/local/Cellar/python/3.7.0/Frameworks/Python.framework/Versions/3.7/lib/python3.7/warnings.py



scrapy输出格式:




#新浪微博抓取
https://www.cnblogs.com/xinyangsdut/p/7631163.html

1.创建工程

    scrapy startproject sinaNews  #scrapy/templates/project 使用的创建模板

切换到工程里面创建一个爬虫类

    cd sinaNews
    scrapy genspider example example.com


文件里面设置运行环境编码:

    import sys
    reload(sys)
    sys.setdefaultencoding("utf-8")

#数据保存到Mogodb
https://www.cnblogs.com/xinyangsdut/p/7688130.html

##爬虫模拟网站登录:


#下载中间件设置 ：设置动态Uesr-Agent和代理IP
https://www.cnblogs.com/xinyangsdut/p/7755438.html


#使用阿里服务识别爬虫验证码
爬虫实战篇---使用Scrapy框架进行模拟登录(包括借助阿里云服务自动识别验证码)
https://www.cnblogs.com/518894-lu/p/9178043.html

#urllib库的使用

#爬取链家网成交房源数据（上）
https://www.cnblogs.com/cnkai/p/7404972.html
使用两款火狐插件:
    1.firebug
    2.firepath
用户代理:《特性检测并非浏览器检测》
https://www.cnblogs.com/hykun/p/Ua.html
服务器处理User-agent:
http://www.2zzt.com/jianzhan/7347.html
