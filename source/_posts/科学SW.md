---
title: 科学SW
date: 2017-09-22 16:54:18
tags:
---


## 安装
```
https://teddysun.com/342.html
```

### 本脚本适用环境：
系统支持：CentOS 6，7，Debian，Ubuntu
内存要求：≥128M
日期：2017 年 07 月 21 日

### 关于本脚本：
一键安装 Python 版 Shadowsocks 的最新版。
友情提示：如果你有问题，请先参考这篇《Shadowsocks Troubleshooting》后再问。


### 默认配置：
服务器端口：自己设定（如不设定，默认为 8989）
密码：自己设定（如不设定，默认为 teddysun.com）
加密方式：自己设定（如不设定，默认为 aes-256-gcm）
备注：脚本默认创建单用户配置文件，如需配置多用户，安装完毕后参照下面的教程示例手动修改配置文件后重启即可。

Shadowsocks for Windows 客户端下载：
https://github.com/shadowsocks/shadowsocks-windows/releases

### 使用方法：
使用root用户登录，运行以下命令：
```
wget --no-check-certificate -O shadowsocks.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh 2>&1 | tee shadowsocks.log
```

安装完成后，脚本提示如下：
```
Congratulations, Shadowsocks-python server install completed!
Your Server IP        :your_server_ip
Your Server Port      :your_server_port
Your Password         :your_password
Your Encryption Method:your_encryption_method

Welcome to visit:https://teddysun.com/342.html
Enjoy it!
```

### 卸载方法：
使用root用户登录，运行以下命令：
```
./shadowsocks.sh uninstall
```

单用户配置文件示例（2015 年 08 月 28 日修正）：
配置文件路径：/etc/shadowsocks.json
```
{
    "server":"0.0.0.0",
    "server_port":your_server_port,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"your_password",
    "timeout":300,
    "method":"your_encryption_method",
    "fast_open": false
}
```

多用户多端口配置文件示例（2015 年 08 月 28 日修正）：
配置文件路径：/etc/shadowsocks.json
```
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
         "8989":"password0",
         "9001":"password1",
         "9002":"password2",
         "9003":"password3",
         "9004":"password4"
    },
    "timeout":300,
    "method":"your_encryption_method",
    "fast_open": false
}
```

使用命令（2015 年 08 月 28 日修正）：

启动：/etc/init.d/shadowsocks start
停止：/etc/init.d/shadowsocks stop
重启：/etc/init.d/shadowsocks restart
状态：/etc/init.d/shadowsocks status




## 问题
```
https://teddysun.com/399.html
```

用 Shadowsocks 有很长一段时间了，想当初为了方便自己部署，写了几个一键安装脚本。在这期间，经常被问到很多问题，我回答的零零散散，因此有必要在这里归纳总结一下。
如果你在使用 Shadowsocks 的过程中也遇到了问题，请参考此文对症下药。
友情提示：如果你看了此文，还是解决不了或者提问，请参考作者的这篇《Troubleshooting》后再问。


1）Shadowsocks 有几种版本？区别是什么？
首先要明确一点，不管 Shadowsocks 有几种版本，都分为服务端和客户端，服务端是部署在服务器（VPS）上的，客户端是在你的电脑上使用的。
Shadowsocks 服务端大体上有 4 种版本，按照程序语言划分，分别为 Python ，libev ，Go ， Nodejs ，目前主流使用前 3 种。
Shadowsocks 客户端几乎包括了所有的终端设备，PC ，Mac ，Android ，iOS ，Linux 等。
其实作者已经作了详细总结，包括 UDP 转发，多用户等 Feature ，具体可参考《Feature Comparison across Different Versions》一文，英文很简单，耐心一点，能看懂的。

2）Shadowsocks 的最低安装需求是多少？
个人建议最少 128MB 内存，因为在连接数比较多的情况下，还是占用不少内存的，如果内存不足，进程就会被系统 kill 掉，这时候就需要手动重启进程。当然，低于 128MB 也是可以安装的，Go 版是二进制安装，无需编译，非常简单快捷，libev 版运行过程中，占用内存较少，可以搭建在 Openwrt 的路由器上。
自己个人使用，且连接数不是特别大的情况下，64MB 内存也基本够用了。如果你要分享给朋友们一起使用，最好还是选用大内存的。

3）为什么我安装（启动） Shadowsocks 失败？
我只能说脚本并没有在所有的 VPS 上都测试过，所以遇到问题是在所难免的。大部分情况下，请参考《Troubleshooting》一文，自行解决。据我所知，很多人都是配置文件出了问题导致的启动失败。还有部分是改错了 iptables 导致的。
在 Amazon EC2 ，百度云，青云上启动失败，连接不上怎么办？
在这类云 VPS 上搭建，需要注意，配置服务器端时，应使用内网IP；Amazon EC2 缺省不允许 inbound traffic，需要在security group里配置允许连接的端口，和开通SSH client连接类似，这个在 Amazon EC2 使用指南里有说明。同样的，青云，百度云也差不多，默认不允许入网流量，网卡绑定的是内网IP，因此需要将配置文件里的 server 值改为对应的内网 IP 后再重新启动。然后在云管理界面，允许入网端口。
我帮人设置了过之后，才发觉这些云和普通的 VPS 不一样，所以需要注意以上事项。

4）Shadowsocks 有没有控制面板？
答案是有的，有人基于 PHP + MySQL 写出来一个前端控制面板，被很多人用来发布收费或免费的 Shadowsocks 服务。Github 地址如下：
https://github.com/orvice/ss-panel
具体怎么安装和使用，别来问我，自己研究去。

5）多用户怎么开启？
Shadowsocks 有多种服务端程序，目前据我所知只有 Python 和 Go 版是支持在配置文件里直接设置多端口的，至于 libev 版则需要使用多个配置文件并开启多个实例才行。
所谓的多用户，其实就是把不同的端口给不同的人使用，每个端口则对应不同的密码。Python 和 Go 版通过简单的修改单一配置文件，然后重启程序即可。

6）有没有必要简单学习 Linux ？
很有必要。
很多人问怎么修改配置文件，你用 winscp 连接上你的 vps ，把配置文件下载到本地，用记事本改吧改吧，改完后再上传覆盖一下不就完了么。
那为什么我还要建议你稍微懂一点 Linux 呢，说白了就是懂一点 Shell 命令。
看看这篇《Linux系统中常用操作命令》，在 putty 或者 xshell 的界面里，你用 vi 或者 nano 命令就能搞定配置文件，这样多好。

最后，请仔细阅读下面的话，姑且称之为作者有话说。@clowwindy
Shadowsocks 没有办法离开去中心化的服务器。要么自己花钱买 VPS，要么用有人分享的账号，要么用有人提供的付费服务，他们各有所长，适合不同的人。所以作为开发者，保持中立，不偏袒其中任何一方，顺其自然发展下去是最好的吧。
很多人要么一窝蜂的支持，要么一窝蜂的反对，还要把它给封禁掉，大概这种心理鲁迅先生也曾批判过。如果你们真的那么讨厌商业，那你们应该首先把你们的苹果设备给摔了，因为它就是商业社会巅峰造极的产物。我反对不喜欢一个东西就要拿出简单粗暴的制裁手段，正是这种习性成就了 GFW。
维护这个项目到现在大概总共回复过几千个问题，开始慢慢想清楚了一件事，为什么会存在 GFW。从这些提问可以看出，大部分人的自理能力都很差，只是等着别人帮他。特别是那些从 App Store 下载了 App 用着公共服务器的人，经常发来一封只有四个字的邮件：“不能用了？” 我觉得这是一个社会常识，花一分钟写的问题，不能期待一个毫无交情的陌生人花一个小时耐心地问你版本和操作步骤，模拟出你的环境来帮你分析解决。
Windows 版加上 GFWList 功能以来，我反复呼吁给 GFWList 提交规则，但是一个月过去了竟然一个提交都没有。如果没有人做一点什么，它自己是不会更新的啊，没有人会义务地帮你打理这些。我觉得，政府无限的权力，都是大部分人自己放弃的。假货坑爹，让政府审核。孩子管不好，让政府关网吧。房价太高，让政府去限购。我们的文化实在太独特，创造出了家长式威权政府，GFW 正是在这种背景下产生的，一个社会矛盾的终极调和器，最终生活不能自理的你每天做的每一件事情都要给政府审查一遍，以免伤害到其他同样生活不能自理的人。这是一个零和游戏，越和这样的用户打交道，越对未来持悲观态度，觉得 GFW 可能永远也不会消失，而墙内的这个局域网看起来还似乎生机勃勃的自成一体，真是让人绝望。
