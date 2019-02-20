# 搭建Git仓库


Git 是一个开源的分布式代码管理工具，对代码进行跟踪，能够提供团队协作开发，管理源代码，目前很多软件都支持Git代码管理工具，Github，Gitlab、[CVS](http://www.nongnu.org/cvs/)、[SVN](https://opencores.org/howto/svn)

## Git的诞生

很多人都知道，Linus在1991年创建了开源的Linux，从此，Linux系统不断发展，已经成为最大的服务器系统软件了。

Linus虽然创建了Linux，但Linux的壮大是靠全世界热心的志愿者参与的，这么多人在世界各地为Linux编写代码，那Linux的代码是如何管理的呢？

事实是，在2002年以前，世界各地的志愿者把源代码文件通过`diff`的方式发给`Linus`，然后由Linus本人通过手工方式合并代码！

你也许会想，为什么Linus不把Linux代码放到版本控制系统里呢？不是有CVS、SVN这些免费的版本控制系统吗？因为Linus坚定地反对CVS和SVN，这些集中式的版本控制系统不但速度慢，而且必须联网才能使用。有一些商用的版本控制系统，虽然比CVS、SVN好用，但那是付费的，和Linux的开源精神不符。

不过，到了2002年，Linux系统已经发展了十年了，代码库之大让Linus很难继续通过手工方式管理了，社区的弟兄们也对这种方式表达了强烈不满，于是Linus选择了一个商业的版本控制系统BitKeeper，BitKeeper的东家BitMover公司出于人道主义精神，授权Linux社区免费使用这个版本控制系统。

安定团结的大好局面在2005年就被打破了，原因是Linux社区牛人聚集，不免沾染了一些梁山好汉的江湖习气。开发Samba的Andrew试图破解BitKeeper的协议（这么干的其实也不只他一个），被BitMover公司发现了（监控工作做得不错！），于是BitMover公司怒了，要收回Linux社区的免费使用权。

Linus可以向BitMover公司道个歉，保证以后严格管教弟兄们，嗯，这是不可能的。实际情况是这样的：

Linus花了两周时间自己用C写了一个分布式版本控制系统，这就是Git！一个月之内，Linux系统的源码已经由Git管理了！牛是怎么定义的呢？大家可以体会一下。

Git迅速成为最流行的分布式版本控制系统，尤其是2008年，GitHub网站上线了，它为开源项目免费提供Git存储，无数开源项目开始迁移至GitHub，包括jQuery，PHP，Ruby等等。

历史就是这么偶然，如果不是当年BitMover公司威胁Linux社区，可能现在我们就没有免费而超级好用的Git了。


## 集中式vs分布式


Linus一直痛恨的CVS及SVN都是集中式的版本控制系统，而Git是分布式版本控制系统，集中式和分布式版本控制系统有什么区别呢？

先说集中式版本控制系统，版本库是集中存放在中央服务器的，而干活的时候，用的都是自己的电脑，所以要先从中央服务器取得最新的版本，然后开始干活，干完活了，再把自己的活推送给中央服务器。中央服务器就好比是一个图书馆，你要改一本书，必须先从图书馆借出来，然后回到家自己改，改完了，再放回图书馆。

![server](../assets/images/git/git0.jpeg)

集中式版本控制系统最大的毛病就是必须联网才能工作，如果在局域网内还好，带宽够大，速度够快，可如果在互联网上，遇到网速慢的话，可能提交一个10M的文件就需要5分钟，这还不得把人给憋死啊。

那分布式版本控制系统与集中式版本控制系统有何不同呢？首先，分布式版本控制系统根本没有“中央服务器”，每个人的电脑上都是一个完整的版本库，这样，你工作的时候，就不需要联网了，因为版本库就在你自己的电脑上。既然每个人电脑上都有一个完整的版本库，那多个人如何协作呢？比方说你在自己电脑上改了文件A，你的同事也在他的电脑上改了文件A，这时，你们俩之间只需把各自的修改推送给对方，就可以互相看到对方的修改了。

和集中式版本控制系统相比，分布式版本控制系统的安全性要高很多，因为每个人电脑里都有完整的版本库，某一个人的电脑坏掉了不要紧，随便从其他人那里复制一个就可以了。而集中式版本控制系统的中央服务器要是出了问题，所有人都没法干活了。

在实际使用分布式版本控制系统的时候，其实很少在两人之间的电脑上推送版本库的修改，因为可能你们俩不在一个局域网内，两台电脑互相访问不了，也可能今天你的同事病了，他的电脑压根没有开机。因此，分布式版本控制系统通常也有一台充当“中央服务器”的电脑，但这个服务器的作用仅仅是用来方便“交换”大家的修改，没有它大家也一样干活，只是交换修改不方便而已。

![](../assets/images/git/git1.jpeg)

当然，Git的优势不单是不必联网这么简单，后面我们还会看到Git极其强大的分支管理，把SVN等远远抛在了后面。

CVS作为最早的开源而且免费的集中式版本控制系统，直到现在还有不少人在用。由于CVS自身设计的问题，会造成提交文件不完整，版本库莫名其妙损坏的情况。同样是开源而且免费的SVN修正了CVS的一些稳定性问题，是目前用得最多的集中式版本库控制系统。

除了免费的外，还有收费的集中式版本控制系统，比如IBM的ClearCase（以前是Rational公司的，被IBM收购了），特点是安装比Windows还大，运行比蜗牛还慢，能用ClearCase的一般是世界500强，他们有个共同的特点是财大气粗，或者人傻钱多。

微软自己也有一个集中式版本控制系统叫VSS，集成在Visual Studio中。由于其反人类的设计，连微软自己都不好意思用了。

分布式版本控制系统除了Git以及促使Git诞生的BitKeeper外，还有类似Git的Mercurial和Bazaar等。这些分布式版本控制系统各有特点，但最快、最简单也最流行的依然是Git！


## Git 安装

  * [Git 官网](https://git-scm.com/about)

  * [Git文档](https://git-scm.com/book/en/v2)

  * Download for Linux and Unix [Link](https://git-scm.com/download/linux)

  * Windown [Link](https://git-scm.com/download/win)

  * Mac [Link](https://git-scm.com/download/mac)

  * Git基础教程[Link](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)

  * 支持WEb版本[Link](http://zodiacg.net/2014/05/gitolite_gitweb_nginx/)

  * 安装[Link](http://perthcharles.github.io/2015/08/24/setup-gitolite-service-git-1/)

  * 参考文档[Link](https://wiki.archlinux.org/index.php/gitweb#Nginx)

  *  配置文件github [Link](https://gist.github.com/alanbriolat/1259389)


## 版本回退
Git 代码对每一次提交都作为一次comment id，回退也是在现有的堆栈只是做了一次基本，并不会把最后的内容回滚掉
1.回退到上一个版本
查看当前的提交记录`最上面的记录是最新提交的`


```sh
git@cuco:~/testing$ git log
commit 8ae3a92ed8db9ede3f5c0799419c5abc1e222d49 (HEAD -> master, origin/master)
Author: Aige <shenzhencuco@gmail.com>
Date:   Tue Feb 19 15:13:24 2019 +0800

    添加测试log

commit 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
Author: Aige <shenzhencuco@gmail.com>
Date:   Tue Feb 19 15:12:11 2019 +0800

    test
```

2.回退到上一个版本`commit 35ea583ac4ee6834f2de39cefd550c1e8782fb8f`

```sh
git@cuco:~/testing$ git reset --hard 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
HEAD is now at 35ea583 test
```
回退后可以看到的提交记录:
```sh
git@cuco:~/testing$ git log
commit 35ea583ac4ee6834f2de39cefd550c1e8782fb8f (HEAD -> master)
Author: Aige <shenzhencuco@gmail.com>
Date:   Tue Feb 19 15:12:11 2019 +0800

    test
```

3.此时又想回退到回退操作的最后一次提交`查看全部的提交记录，找到最后提交的comment id`

```sh
git@cuco:~/testing$ git reflog
35ea583 (HEAD -> master) HEAD@{0}: reset: moving to 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
8ae3a92 (origin/master) HEAD@{1}: pull: Fast-forward
35ea583 (HEAD -> master) HEAD@{2}: reset: moving to 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
8ae3a92 (origin/master) HEAD@{3}: reset: moving to 8ae3a92
35ea583 (HEAD -> master) HEAD@{4}: reset: moving to 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
35ea583 (HEAD -> master) HEAD@{5}: reset: moving to 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
8ae3a92 (origin/master) HEAD@{6}: reset: moving to 8ae3a92ed8db9ede3f5c0799419c5abc1e222d49
8ae3a92 (origin/master) HEAD@{7}: commit: 添加测试log
35ea583 (HEAD -> master) HEAD@{8}: commit (initial): test
```


4.回退到想要的版本
```sh
git@cuco:~/testing$ git reset --hard 35ea583ac4ee6834f2de39cefd550c1e8782fb8f
HEAD is now at 35ea583 test
```
## Git的区域

工作区--->暂存区--->本地代码仓库--->远程代码工具

* 场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令git checkout -- file。

* 场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令git reset HEAD <file>，就回到了场景1，第二步按场景1操作。

* 场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考版本回退一节，不过前提是没有推送到远程库。


## 本地分支和远程分支关联

    要关联一个远程库，使用命令git remote add origin git@server-name:path/repo-name.git；

    关联后，使用命令git push -u origin master第一次推送master分支的所有内容；

    此后，每次本地提交后，只要有必要，就可以使用命令git push origin master推送最新修改；

## 合并分支

    Git鼓励大量使用分支：

    查看分支：git branch

    创建分支：git branch <name>

    切换分支：git checkout <name>

    创建+切换分支：git checkout -b <name>

    合并某分支到当前分支：git merge <name>

    删除分支：git branch -d <name>


## 暂存代码

工作现场还在，Git把stash内容存在某个地方了，但是需要恢复一下，有两个办法：

一是用git stash apply恢复，但是恢复后，stash内容并不删除，你需要用git stash drop来删除；

另一种方式是用git stash pop，恢复的同时把stash内容也删了：

再用git stash list查看，就看不到任何stash内容了：

修复bug时，我们会通过创建新的bug分支进行修复，然后合并，最后删除；

当手头工作没有完成时，先把工作现场git stash一下，然后去修复bug，修复后，再git stash pop，回到工作现场。

## 远程分支操作

查看远程库信息，使用git remote -v；

本地新建的分支如果不推送到远程，对其他人就是不可见的；

从本地推送分支，使用git push origin branch-name，如果推送失败，先用git pull抓取远程的新提交；

在本地创建和远程分支对应的分支，使用git checkout -b branch-name origin/branch-name，本地和远程分支的名称最好一致；

建立本地分支和远程分支的关联，使用git branch --set-upstream branch-name origin/branch-name；

从远程抓取分支，使用git pull，如果有冲突，要先处理冲突。

## 打tag标记

命令git tag <tagname>用于新建一个标签，默认为HEAD，也可以指定一个commit id；

命令git tag -a <tagname> -m "blablabla..."可以指定标签信息；

命令git tag可以查看所有标签。

命令git push origin <tagname>可以推送一个本地标签；

命令git push origin --tags可以推送全部未推送过的本地标签；

命令git tag -d <tagname>可以删除一个本地标签；

命令git push origin :refs/tags/<tagname>可以删除一个远程标签。



## 服务器上的 Git - 生成 SSH 公钥(https://git-scm.com/book/zh/v2/%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%B8%8A%E7%9A%84-Git-%E7%94%9F%E6%88%90-SSH-%E5%85%AC%E9%92%A5)


## Gitosis:

> 配置

  https://github.com/sitaramc/gitolite


!!! info "系统需求"

    * any unix system
    * sh
    * git 1.6.6 or later
    * perl 5.8.8 or later
    * openssh 5.0 or later
    * a dedicated userid to host the repos (in this document, we assume it is "git", but it can be anything; substitute accordingly)
    * this user id does NOT currently have any ssh pubkey-based access
    * ideally, this user id has shell access ONLY by "su - git" from some other userid on the same server (this ensure minimal confusion for ssh newbies!)


## 安装

参考文档[Link](https://www.cnblogs.com/hupengcool/p/3919201.html)

```sh
# 切换为 git 用户
# su git
[git@server ~]$ cd ~
[git@server ~]$ git clone git://github.com/sitaramc/gitolite
```

下载源码之后安装:

```sh
# 创建 ~/bin 目录
[git@server ~]$ mkdir bin
# 把 /home/git/bin 添加到环境变量里, 通过修改git 家下面的.bashrc
[git@server ~]$ vim .bashrc
# 在文件最后添加
export PATH=/home/git/bin:$PATH
# Install gitolite into $HOME/git/bin
[git@server ~]$ gitolite/install -ln
[git@server ~]$
```

上传客户端管理员的SSH 公钥 {#ssh_key}
<small>客户端如果生成ssh key, 参考: [Github - Generating SSH Keys](https://help.github.com/articles/connecting-to-github-with-ssh/)<small>

```sh
[ahnniu@client ~] cd ~/.ssh
[ahnniu@client .ssh] ls -al
# 如果不存在 id_rsa, id_rsa.pub 则运行下面的命令创建
[ahnniu@client .ssh] ssh-keygen -t rsa -C "your_email@example.com"
# 复制一份id_rsa.pub并重命名为 ahnniu.pub, 注 ahnniu为 gitolite管理员的用户名
[ahnniu@client .ssh] cp id_rsa.pub ahnniu.pub
# 通过ssh上传到服务器上(/home/git/)，特别注意文件的owern应该为git
[ahnniu@client .ssh] scp ~/.ssh/ahnniu.pub git@192.168.2.223:/home/git/
```

设置Gitolite
```sh
[git@server ~]$ cd ~
# 基于提供的ahnniu.pub 创建 gitolite-admin 管理仓库
[git@server ~]$ gitolite setup -pk $HOME/ahnniu.pub
Initialized empty Git repository in /home/git/repositories/gitolite-admin.git/
Initialized empty Git repository in /home/git/repositories/testing.git/
WARNING: /home/git/.ssh missing; creating a new one
    (this is normal on a brand new install)
WARNING: /home/git/.ssh/authorized_keys missing; creating a new one
    (this is normal on a brand new install)
```
至此，SSH方式的Git服务已经搭建好了

客户端SSH方式clone, push
```sh
# 首先需确保，上传的管理员key ahnniu.pub是在这台电脑上生成的，否则是没有权限的
[ahnniu@client ~] git clone git@192.168.2.223:gitolite-admin.git
Cloning into 'gitolite-admin'...
remote: Counting objects: 6, done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (6/6), done.
Checking connectivity... done.
```


团队开发过程中建议的Gitolite使用方式

Gitolite的管理方式
我认为Gitolite是典型的吃自己的狗粮，他的管理完全是操作Git来完成， 他可以允许多个管理员同时管理，因为是基于一个git仓库，那么通过merge可以解决冲突的问题

Gitolite有一个gitolite-admin.git的仓库, 通过操作：

/keydir/ 来管理SSH用户
/conf/gitolite.conf 来管理repo（增删，权限）
下面我们探讨如果通过gitolite打造Github那样的Git Server.



Git仓库的几种权限
Public / Private
Public: 仓库可以给任何人Clone,pull
Private: 仓库只能给指定的人Clone,pull

几种权限组
权限组: Owner
仓库的拥有者，可以对仓库做任何想做的事情，比如push, 修改其它人访问这个仓库的权限，甚至删除，至少需要有一个人

权限组: RW
可读写组, clone, push, pull

权限组: R
可读组, clone, pull

其中 Owner包含 RW, RW权限 包含 R

准备工作
克隆gitolite管理仓库

!!! info "NOTE: 需使用安装Gitolite指定的SSH Key对应的电脑（或者Copy 对应的 id_rsa到你使用的电脑~/.ssh）, HTTP方式好像不能操作gitolite-admin.git仓库。"
