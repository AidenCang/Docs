# Python反射机制

## 概述

在程序开发中,常常会遇到这样的需求:在执行对象中的某个方法,或者在调用对象的某个变量,但是由于一些原因,我们无法确定或者并不知道该方法或者变量是否存在,这时我们需要一个特殊的方法或者机制来访问或操作该未知的方法或变量,这种机制就被称之为反射.

反射机制：反射就是通过字符串的形式,导入模块.通过字符串的形式,去模块中寻找指定函数,对其进行操作,也就是利用字符串的形式去对象(模块)中操作成员,一种基于字符串的事件驱动,这种机制就叫做反射机制.

Python 中的反射功能是由以下四个内置函数提供：hasattr、getattr、setattr、delattr,这四个函数分别用于在对象内部执行：检查是否含有某成员、获取成员、设置成员、删除成员、导入模块以字符串方式导入,接下来我们将具体介绍它们的应用场景.

## hasattr:

检查指定类中是否有指定成员,也就是检查是否含有指定成员函数.

    import os
    import sys

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self):
    		print("%s 在吃东西..."%self.name)

    d = dog("dogging")
    choice = input("输入数据:").strip()

    # (d=类的实例名称) (choice=数据保存位置)
    print(hasattr(d,choice))

    #--输出结果-----------------------------------
    输入数据:eat
    True

## getattr:

获取指定类中是否有指定的成员,结果打印出1个字符串,映射出函数所在内存地址.

    import os
    import sys

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self):
    		print("%s 在吃东西...",self.names)

    d= dog("dogging")
    choice = input("输入数据:").strip()

    # (d=类的实例名称) (choice=数据保存位置)
    print(getattr(d,choice))

    # 同样的,在getattr后面加上括号,则可调用指定方法.
    getattr(d,choice)()

    #--输出结果-----------------------------------
    输入数据:eat
    <bound method dog.eat of <__main__.dog object at 0x000001D71FD47128>>
    dogging 在吃东西..

## getattr:

    getattr一般的通用写法,映射出函数所在内存地址后,给函数传递参数.

    import os
    import sys

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self,food):
    		print("%s 在吃东西..."%self.name,food)

    d= dog("dogging")
    choice=input("输入数据:").strip()

    func=getattr(d,choice)
    func("调用传递参数..")
    #--输出结果-----------------------------------
    输入数据:eat
    dogging 在吃东西... 调用传递参数..

## setattr:

    动态装配函数,在外部创建函数,然后将外部函数,动态的装配到指定类的内部.

    import os
    import sys

    def bulk(self):                               #定义一个外部函数.
    	print("%s 在大叫..."%self.name)

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self,food):
    		print("%s 在吃东西..."%self.name,food)


    d= dog("dogging")
    choice=input("输入数据:").strip()           #传递字符串
    setattr(d,choice,bulk)                     #将bulk()外部方法,动态添加到dog类中.
    d.bulk(d)                                  #调用bulk()方法,这里要将d自己传递进去.
    #--输出结果-----------------------------------
    输入数据:bulk                              #调用成功,说明装配成功啦.
    dogging 在大叫...

## setattr:

    动态装配属性,在外部动态装配属性,并设置默认初始值为22.

    import os
    import sys

    def bulk(self):
    	print("%s 在大叫..."%self.name)

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self,food):
    		print("%s 在吃东西..."%self.name,food)

    d= dog("dogging")
    choice=input("输入装配变量:").strip()    #输入装配变量名

    setattr(d,choice,22)                    #设置初始值为22
    print(getattr(d,choice))                #打印装配的变量值

    #--输出结果-----------------------------------
    输入装配变量:temp
    22

## delattr:

    动态删除函数,以下演示动态的删除dog类中的,eat这个函数,后期再次调用会发现不存在了.

    import os
    import sys

    class dog(object):
    	def __init__(self,name):
    		self.name=name

    	def eat(self):
    		print("%s 在吃东西..."%self.name)

    d= dog("dogging")
    choice=input("输入内容:").strip()       #输入要删除的方法名

    delattr(d,choice,eat)                  #通过此方法,删除eat函数
    d.eat()                                #再次调用会错误,已经动态删除了

    #--输出结果-----------------------------------
    输入内容:eat
    Traceback (most recent call last):
      File "test.py", line 15, in <module>
        delattr(d,choice,eat)
    NameError: name 'eat' is not defined

## python基础-对象_类反射、模块反射

[python基础-对象_类反射、模块反射](python基础-对象_类反射、模块反射)

[Python 异常处理与反射机制](https://www.mkdirs.com/2019/02/01/Python/Python-%E5%BC%82%E5%B8%B8%E5%A4%84%E7%90%86%E4%B8%8E%E5%8F%8D%E5%B0%84%E6%9C%BA%E5%88%B6-9/)
