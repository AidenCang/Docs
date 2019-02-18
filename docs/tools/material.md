# Material for MkDocs 安装使用

MkDocs是一套静态工程文档网站模板，使用的是markdown语法编写的页面，同时Material for MkDocs在Mkdocs上使用了google的材料设计开发的网站模板，通过配置方式能够快速搭建工程文档项目，同时可以发布到githubpage，Amazon S3，其他自己搭建的服务器上

官网:[Material for MkDocs][1]
官网:[MkDocs][6]

## Python支持
```sh
python --version
# Python 2.7.13
pip --version
# pip 9.0.1
```
## Install MkDocs
Installing and verifying MkDocs is as simple as:
```sh
pip install mkdocs && mkdocs --version
# mkdocs, version 0.17.1
```
注: Material requires MkDocs >= 0.17.1.

## Installing Material
### using pip
 Material can be installed with pip:
```sh
pip install mkdocs-material
```

### using choco

If you're on Windows you can use Chocolatey to install Material:
```sh
choco install mkdocs-material
```

This will install all required dependencies like Python and MkDocs.

### cloning from GitHub

Material can also be used without a system-wide installation by cloning the repository into a subfolder of your project's root directory:
```sh
git clone https://github.com/squidfunk/mkdocs-material.git
```

This is especially useful if you want to extend the theme and override some parts of the theme. The theme will reside in the folder mkdocs-material/material.

# 开启本地服务器
```sh
mkdocs serve
```

# deploying
发布站点[deploying][2]

[GitHub page][4]:发布站点到github上

[Amazon s3][5]:发布站点到s3上

```sh
mkdocs gh-deploy
```
```sh
mkdocs gh-deploy --help
```

[ghp-import][3] github page 发布工具


[1]:https://squidfunk.github.io/mkdocs-material/
[2]:https://www.mkdocs.org/user-guide/deploying-your-docs/
[3]:https://github.com/davisp/ghp-import
[4]:https://help.github.com/articles/creating-project-pages-using-the-command-line/
[5]:https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html
[6]:https://www.mkdocs.org/
