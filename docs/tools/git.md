# 搭建Git仓库

## git

[git文档](https://git-scm.com/download)

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



## 常用Git开发工具

[processon](https://www.processon.com/view/58462dcce4b0d0d77c1084bc#map)

配置
Git密钥公钥
生成密钥
ssh-keygen -t rsa -C "liuwenrong@tianpingpai.com"
ssh -i ~/.ssh/id_rsa
查看 key
cat ~/.ssh/id_rsa.pub
测试密钥
ssh -T git@github.com
ssh -v git@github.com
Git config
配置 查看
git config --list
cat .git/config
用户目录 .gitconfig
配置
配置核心编辑器
git config --global core.editor vim
忽略文件权限
git config core.filemode false
git config --global core.filemode false
配置用户
单个项目
git config user.name "liuwenrong"
git config user.email "liuwenrong@tianpingpai.com"
全局用户
git config --global user.name "liuwenrong"
git config --global user.email "liuwenrong@tianpingpai.com"
记住密码
git config --global credential.helper store
配置远程服务器地址
git remote add simpleName url
git remote add origin githup.xxx.git
配色
git config --global color.status auto
git config --global color.diff auto
git config --global color.branch auto
git config --global color.interactive auto
基础操作
常用命令
git status   查看状态,如果对git不熟悉,建议经常敲这命令
git  add .		添加到仓库(针对新增加的文件)
当add . 出错时,试试
git add --all
git commit -s -a -m "注释必填"   提交到本地仓库
-s自动加上Signed-off-by, -a 全部提交,-m 注释Msg
git push [分支名 不填默认当前分支]  提交到远程服务器
git push origin dev
git rebase
git log
查看当前分支的提交点信息
git log origin/dev
查看本地.git仓库的dev分支log
不过要看最新的服务器提交点 需要git fetch
git log origin dev
无效 还是查看本地分支
git log FETCH_HEAD
查看远程分支的提交点log
其他筛选条件
--author=
根据用户
--branchName [branchName]
根据分支
比如：在当前分支中有一个名为v1的文件，同时还存在一个名为v1的分支 git log v1 -- 此时的v1代表的是分支名字（－－后边是空的）
git log -- v1 此时的v1代表的是名为v1的文件
git log v1 －－ v1 代表v1分支下的v1文件
git log --author=liuwenrong R6002_608 --
R6002_608分支下liuwenrong的所有提交
git show
查看本次提交的修改
Tag
提交代码流程
git add .
git commit -s -a -m '注释'
git commit -s -a
会进入编辑器
当出现 .git/index.lock时
多处编辑文件,git锁住了
可以 rm .git/index.lock  删除该文件后,继续执行commit命令
git fetch origin dev   从服务器下载到本地仓库(空格)
git rebase origin/dev   本地仓库和本地代码合并(斜杠)
git fetch <远程主机名> <分支名>
git fetch <远程主机名>
将某个远程主机的更新，全部取回本地。
git fetch取回所有分支(branch)的更新。如果只想取回特定分支的更新，可以指定分支名。
git rebase refs/remotes/origin/dev
git rebase 简写
如果 发生冲突  (修改冲突后)  git add .
	git rebase --continue
push 到服务器
git push origin dev 提交到服务器
如果是第一次push
git push -u origin master
第一次push到某个新的分支
git push set-upstream [服务器简写origin] [分支名]
修改提交信息
修改commit Msg信息
git commit -s --amend [-v] 接着修改当前这个 commit 的 messagen -v是编辑器(可不写)
git commit --amend --author="liuwenrong  <liuwenrong@coolpad.com>" 注:双引号
TFS_555725:liuwenrong_sys_task: add network
Signed-off-by: liuwenrong <liuwenrong@coolpad.com>
修改倒数第二个提交点Msg和内容
git reset --soft commitId 或者 git reset --soft HEAD^ 回退提交,但代码还在
git add . 将倒数第一个的提交内容也加进来
git commit --amend
git push origin HEAD --force
删除暂存区里的文件
git rm --cache 文件名
使用场景
1. 把已经add追踪的文件加到.gitignore中
git rm -r --cache packages/SystemUI/.idea/
删除暂存区和工作区的文件
git rm -f <file>
如果文件没有加到暂存区
先执行 git add <file>
如果只有一个文件或者全部需要删除
git add .
git rm -f -r 文件夹
检出 git checkout
切换分支
git checkout dev
git checkout master
git checkout ()提交点哈希值) 切换到该提交点的代码
检出文件/从本地仓库恢复某文件
git checkout -- xx.java
如果该文件已经 add 到暂存队列中，上面的命令就不灵光喽
需要先让这个文件取消暂存：
git reset HEAD --+ 需要取消暂存的文件名
新建并切换分支 git checkout -b xx
git checkout -b dev 新建并切换到dev分支
git checkout -b dev origin/dev 新建本地分支dev并关联到.git仓库的dev分支
git checkout -b dev origin/JV_8953_Dev
Branch dev set up to track remote branch JV_8953_Dev from origin.
Switched to a new branch "dev"
git checkout dev(远程有这个同名的分支就会关联) 注:没有 -b
branch 分支
查看分支
git branch -a    全部分支
git branch -r     查看远程分支
git branch        查看本地分支
git branch -v      查看分支最后修改
git branch -vv
查看本地分支-关联服务器分支 以及最后的提交
分支操作
git branch  xx    创建xx分支
git branch -d xx    删除xx分支(需在其他分支下操作) 未合并不能删除成功
git branch -D xx    强制删除xx分支(需在其他分支下操作)
git branch <new-branch-name> 2f865e5
在某个提交点处新建一个分支
git branch --set-upstream-to=origin/JV_LauncherBS_Dev
git rebase 设置默认的服务器分支
git branch --set-upstream dev_lwr coolyota/coolyota
关联服务器
git branch --track dev coolyota/coolyota_dev
没用
分支重命名
git branch -m oldbranchname newbranchname
Android
Ignore
项目 git clone
Coolpad coolyota Y3
常见问题
int流有格式问题,abort了本次提交
git reset --soft
git commit -s -a
子主题
子主题
repo后处于没有分支状态
git checkout JV_8953_Dev
切换到Dev并关联服务器Dev分支
git checkout -b dev yulong/JV_8953_Dev
当关联了几个服务器如 origin yulong zeusis
服务器代码覆盖本地提交
git fetch --all
git reset --hard yulong/JV_8953_Dev
不做任何合并,Rebase
HEAD指向刚刚下载的最新的版本
Int分支覆盖Dev分支
git branch 查看本地分支名 如:dev,int 或者JV_8953_Dev,JV_8953_Int
git checkout dev(或者JV_8953_Dev) git reset --hard int(或者JV_8953_Int) //先将本地的dev分支重置成int分支
git push yulong JV_8953_Dev --force //再推送到远程Dev仓库
子主题
cherry-pick 有冲突
dev分支执行了git pull 或者fetch+merge命令导致 merger会导致该commitId的parentId不是int分支
的最新提交点
解决: dev 回退代码后 用rebase合并
git reset --hard (commitId合并之前的提交点)
git fetch
git rebase (commitId int分支最新的点对应的dev中提交点)
如果有冲突,解决后 git add.
git rebase --continue
git checkout int
git cherry-pick (commitID 刚才dev分支rebase后的提交点)
子主题
合并提交点
JV_8953_Dev分支上
一个功能点新建本地分支git checkout -b [local_function]
如: git checkout -b power
当前处于功能分支上如:power分支 改完代码,生成了多个提交点,合并成一个提交点
git log
commit 333 commit 222
commit 111
git reset --soft 111
重置了222和333的提交,但本地代码还在
git status
查看状态/可以不执行
git commit -s --amend
修改111提交点的msg
TFS_565687:liuwenrong_sys_add:Modify A Screen theme and wallpaper
sys
app_BLauncher
add
fix
opt
不管注释是否修改,commitId都会变
git status
查看状态/可以不执行
git branch -a
查看所有分支
git checkout JV_8953_Dev 后处于Dev分支上:
然后将功能分支合并过来
git rebase [local_fuction]
git rebase [commit-id]
也可以是合并某一个提交点
git pull --rebase
拉取服务器代码跟本地代码合并
有冲突,解决即可
同一个提交commitId会变
git push yulong HEAD:JV_8953_Dev
当同时有yulong和zeusis的远程服务器,必须指定
要走读
git push coolyota HEAD:refs/for/coolyota_msm8953_dev
Dev上验证通过后
Dev分支上
git log
查看提交点ID,以便接下来cherry-pick
git branch -a
查看所有分支/如果自己记住了名可以不查看
git checkout JV_8953_Int
Release分支
走读
git push coolyota HEAD:refs/for/CP_LauncherB_Release
Int分支上
git cherry-pick [commit-1] [commit-2]
将要提交的点合并到Int流
git push HEAD:JV_8953_Int
git push
可以简写,表示当前分支
走读
git push yulong HEAD:refs/for/JV_8953_Int
git push --no-thin yulong HEAD:refs/for/JV_8953_Int
git push coolyota HEAD:refs/for/coolyota_msm8953_int
子主题
回退到最近一次的提交
git reset --hard HEAD
git pull
自由主题
更新代码/合并
git rebase
简介
在把从其他开发者处拉取的提交 应用到本地
将当前分支和上游分支进行合并
例: dev有一个commitId
新建一个分支power
此时,Dev上有新的提交点CommitId
git rebase dev 将Dev的提交合并过来
此次操作可能提示error,补丁失败,但不影响正常rebase
格式
git rebase [-i | --interactive] [options] [--onto ]  []
git rebase [-i | --interactive] [options] –onto   –root []
git rebase –continue | –skip | –abort
fetch+rebase
fetch+merge
回退/撤销
git reset
子主题
放弃本地代码
git reset --hard FETCH_HEAD
如果想放弃本地的文件修改，可以使用git reset --hard FETCH_HEAD，FETCH_HEAD表示上一次成功git pull之后形成的commit点。然后git pull.
子主题
git reset --hard commit_id 回退到上一提交点,工作区代码也会回退
代码回退到当前提交点,工作区代码也会回退
回退当前提交点的add和commit以及代码操作
git reset --soft commit_id
回退当前提交点之前的commit操作,会保留本地代码
git reset commit_id
回退当前提交点之前的add和commit的操作
git reset --hard HEAD~3
会将最新的3次提交全部重置，就像没有提交过一样。
git reset 撤销上一次add .
注: 要回退已经push到服务器的提交点,只能使用git revert
git revert
回退并生成一个新的提交点,适用于上一提交点已经push到服务器了,
git revert HEAD
 撤销当前的提交点,回到前一个提交点的代码,但会生成新的提交点,这就是与reset --hard的区别,注:但本地有修改会失败
git revert HEAD~1 -m 1
git revert HEAD~1
只撤销倒数第二次 commit,会保留倒数第一次的提交点
git revert HEAD~1 -m 0
git revert commit （比如：fa042ce57ebbe5bb9c8db709f719cec2c58ee7ff）撤销指定的版本
注: 本地revert不会生成ChangerId
git checkout --<bad_file>
pull
会影响github端的network图 不建议使用pull
git pull <远程主机名> <远程分支名>:<本地分支名>
取回origin主机的next分支，与本地的master分支合并，需要写成下面这样
git pull origin next:master
远程分支是与当前分支合并，则冒号后面的部分可以省略
git pull origin next
实质上，这等同于先做git fetch，再做git merge
git fetch origin git merge origin/next
如果合并需要采用rebase模式，可以使用–rebase选项。
git pull --rebase <远程主机名> <远程分支名>:<本地分支名>
push 到远程服务器
git push --set-upstream origin dev 提交到服务器并在服务器新建dev分支
举例
git push --set-upstream iReader R1001_BtPage
git push --set-upstream iReader R1001_Dict
git push <远程主机名> <本地分支名>:<远程分支名>
git push origin dev:develop
git push iReader audioRemote:R1001_audio
git push origin
将当前分支推送到origin主机的对应分支
合并分支 merge是合并全部提交
cherry-pick选择合并
merge 合并dev分支
git checkout master 切换至master分支
git merge --no-ff dev
如果出现合并冲突就 找相应文件改冲突
改完执行 git add . 和 git commit -a -m "msg"
如果出现vi 编辑界面 则输入 备注 后按Esc : wq 保存退出
git cherry-pick <commit id>
如果将Dev中的一个commitId合并到master
dev分支下git log查看CommitId并复制要合并的CommitId (一个提交点对应一个哈希值)
git checkout master
git cherry-pick <Dev-commitId>
git cherry-pick <start-commit-id>..<end-commit-id>或者git cherry-pick <start-commit-id>^..<end-commit-id>
前者表示把<start-commit-id>到<end-commit-id>之间(左开右闭，不包含start-commit-id)的提交cherry-pick到当前分支；
后者表示把<start-commit-id>到<end-commit-id>之间(闭区间，包含start-commit-id)的提交cherry-pick到当前分支。
附开发常用命令
忽略文件.gitignore
Android Studio下的.gitignore
log 查看提交信息
git log 查看提交信息
gl=git log --oneline --all --graph --decorate  $* 所有仓的直线提交图
常见错误
中级
git remote
一个Git项目绑定多个远程服务器
git remote add origin [ur] 增加一个远程路径简写为origin
git remote add githup [githup:...] 把GitHub项目路径设置为githup
push到不同服务器 push origin dev
查看远程服务器
git remote -v
git remote show origin
替换远程服务器url
git remote set-url origin [url]
重命名
git remote rename oldName newName
子主题
压缩或修改多个Commit
git rebase -i HEAD~[number_of_commits]
git rebase -i HEAD~2
压缩:把要修改的提交点 pick改成s或者squash
修改 pick改成 r或reword
查看文件谁修改过
git blame (fileName)
