---
title: jenkins-fastlane持续集成和自动化打包
date: 2017-12-09 11:36:53
tags: 自动化
categories: 自动化
---

# jenkins-fastlane 持续集成和自动化打包
## 目录
> * 背景
> * 自动化打包脚本
> * 配置 Jenkins


## 背景
先看下目前都有哪些打包方式：
### 方式一
debug 包：直接 build 出一个 app，放到 itunes 里，然后上传 fir 或者 蒲公英。
release 包：archive 出一个 ipa，通过 application loader 上传到 itunes。

### 方式二
自动化脚本，一键打出 debug 包和 release 包，以前都会使用 shenzhen 去做自动化脚本，现在 shenzhen 已经被 fastlane 替代。

### 方式三
Jenkins + Fastlane + GitLab + fir (或者蒲公英)

很明显`方式二`更快捷，也节约了时间成本，但是还是会不够自动化，是手动触发去打包的，所以综上所诉`方式三`是最能满足需求的，不仅可以基于触发器自动打包，还可以在 Jenkins 上引入需要的插件来扩展功能。

<!--more-->

## 自动化打包脚本套件

#### 安装 Fastlane
Fastlane 是一套使用Ruby写的自动化工具集，用于iOS和Android的自动化打包、发布等工作，可以节省大量的时间

```
sudo gem install fastlane --verbose
```
#### 安装 fir

```
sudo gem install fir-cli
```

#### 编写 shell 脚本
可以参考我写的这个脚本
https://github.com/karosLi/jenkins-fastlane/blob/master/build.sh

脚本说明：
> * 支持版本号自增长
> * 支持传入自定的宏，用于在代码里使用此预编译的宏来区分开发环境和发布环境
> * 支持自动上传到 fir 和 testflight
> * 上传成功后弹窗提示

上传到 fir 的用法：

```
./build.sh -m "xxxx_app_test" -t test
```

上传到 testflight 的用法：

```
./build.sh -m "xxxx_app_pro" -t pro
```


## Jenkins 安装
Jenkins 是一个开源项目，提供了一种易于使用的持续集成系统，使开发者从繁杂的集成中解脱出来，专注于更为重要的业务逻辑实现上。同时 Jenkins 能实施监控集成中存在的错误，提供详细的日志文件和提醒功能，还能用图表的形式形象地展示项目构建的趋势和稳定性。

#### 下载 Jenkins
点击 http://mirrors.jenkins.io/war-stable/latest/jenkins.war 下载最新的Jenkins.war

#### 运行服务器：

需要先安装 java sdk （http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html）

```
java -jar jenkins.war
```
#### 配置 Jenkins：
浏览器打开 http://localhost:8080/ 输入安全密码，安全密码命令行输出的一个文件里面。

然后自动安装推荐的插件，并新建管理员账号密码。

#### 安装插件
登录http://localhost:8080/ ，选择系统管理 - 管理插件。

在可选插件中选择GitLab Plugin，Gitlab Hook Plugin，和 Cocoapod plugin 进行安装。

#### 构建任务
1. 点击新建，输入名称，构建一个自由风格的软件项目。

2. 配置 Git 仓库地址，并添加 git 账号。

3. 配置构建脚本
![](http://olf3t4omk.bkt.clouddn.com/jenkins_build_commnd.jpg)

5. 完成配置后就可以添加构建任务

如果在构建的时候，出现连不上 github 的错误，可能是由于没有关闭 vpn 的引起的，也有可能是没有配置 Cocoapod plugin 引起的。


## 参考链接
* http://www.jianshu.com/p/0a113f754c09
* http://www.jianshu.com/p/2f2dcf41667c
* http://www.jianshu.com/p/1a92d87f12f3
* http://www.cocoachina.com/ios/20150728/12733.html
* http://www.infoq.com/cn/articles/ios-code-server-jenkins-travis-fastlane



