---
title: 项目利用Cocoapods组件化
date: 2018-04-29 00:07:03
tags:
---

> 最近公司项目重构，准备利用Cocoapods组件化。
> 网上[这篇文章](http://blog.wtlucky.com/blog/2015/02/26/create-private-podspec/)已经说的非常好了，我也是参照这篇文章，不过也有一些小坑需要趟一下,所以整理如下。


Cocoapods是非常好的项目依赖管理工具，类似的还有Carthage，不过一番权衡，还是用CP了。

既然是公司项目肯定得建个私有库，将项目的不同部分合适的切分成不同的模块，有的模块还有父子依赖关系，再上传到私有库上，定期维护这些库就可以了，这样可以有效和划分人员和代码的职责，方便管理。

最终，项目被分成了三个库，分别是A（工具库）、B（数据库）、C（一个复杂视图封装好的组件库），BC依赖于A，BC之间互相独立。

下面是具体实现记录：

### 创建并设置一个私有的`Spec Repo`

上面的ABC就是我们的私有pods, 而`Spec Repo`就是私有的pods的集合仓库，地位等同于公共的Cocoapods仓库，等我们配置完成后，用命令`pod search XXXX`,就会依次搜索公共ocoapods仓库和我们的私有仓库。

`Spec Repo`本质是一个git仓库，仓库中保存着每一个私有pods的索引文件，索引文件记录了各个私有pods的关键信息，比如名称，代码地址，介绍之类的。

首先建一个普通的私有仓库，一般放在公司的服务器上，可以取名叫某某公司的pods就行，让后告诉cocoapod这是我们的私有仓库

```
 pod repo add WTSpecs https://coding.net/wtlucky/WTSpecs.git
```

本地的`/Users/xxx/.cocoapods/repo/`文件夹下就会多出这个仓库了

### 创建Pod项目

pods集合仓库建好后，就开始逐个创建私有pods的仓库，因为所有的私有pod都依赖A仓库，所以要先搞A

具体命令是`pod lib create A`, Cocoapods会根据你的设置创建好模板工程，让后就可以在模板里写代码了，

pod的模板工程中包括以下的几个关键的文件或文件夹，
`A/`,存放代码和资源的地方,里面包括`Class`,`Assets`
`A.podspec`,这个就是私有pod的身份证了，里面记录了这个pod的所有信息，当我们把这个pod提交到pods集合仓库时，本质就是提交这个podspec文件过去，不然pods集合仓库的空间根本不够用。
`Example/`，这是在创建模板时，默认会建的文件夹，里面存放了依赖这个pod的demo工程，当让也可以用模板的，手动搞一个。

首先看看podspec的内容：

```
#
# Be sure to run `pod lib lint A.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'A'
  s.version          = '0.1.0'
  s.summary          = 'A short description of A.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chdo002/A'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chdo002' => '1107661983@qq.com' }
  s.source           = { :git => 'https://github.com/chdo002/A.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'A/Classes/**/*'
  
  # s.resource_bundles = {
  #   'A' => ['A/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

```
拣几个关键的说下，

`s.name` 需要想好，最好有公司或者单位前缀，不然有大坑，而且不好改，后面细说
`s.version`指定了这个pod的版本，非常重要。
`s.homepage`和`s.source`，指定了仓库的地址，需要填写正确
`s.source_files` 指向我们的代码路径，这里统配了这个路径下的所有文件
`s.resource_bundles` 是说明我们的pod所包含的资源文件用的，在工程中，这些资源会被打包成bundle，放在这个pod名的framework下，所以不需要担心资源重名问题
`s.frameworks`和`s.dependency`是pod的系统依赖和对其他pod的依赖，这里有点需要注意，如果依赖的其他pod是私有库的话，我们也不能在这里说明，需要在外部处理，见下文。

这些属性的验证可以通过命令`pod lib lint`检查，实际上这个命令也是检查项目代码能否顺利编译。

在哪写私有pod代码呢？

打开`example`下的项目worksapce文件，可以看到在`pods`target下有个`Development Pods`文件夹，这个就是我们的私有pods存在的地方，删掉里面的`ReplaceMe.m`文件就可以了。

当写完一部分代码，想要看看是否奏效时，在`example`路径下执行`pod install`更新工程，这个和普通的操作没有区别。

一番编写调试完成，我们的私有pods没有问题的话，那就可以提交第一个版本了


### 向Spec Repo提交podspec

向Spec Repo提交podspec之前还是需要几步操作，

首先向pod远程仓库提交代码，用`pod lib lint`验证，可以加上`--verbose`查看具体的编译过程，这一步也是比较容易出错的地方，不过出错的原因都会详细说明。

编译通过的话，就可以commit，并在这个commit打上个tag，tag要与这此pod的版本一致。

比如我这次提交的pod版本是0.0.1，那我就要打个0.0.1的tag，`git tag -m "A pod first Release" "0.0.1"`

然后都push上去，`git  push origin --tags`

最后就是`pod repo push WTSpecs A.podspec `, 这一步也是会执行`pod lib lint`的，你也可以添加`--verbose`和其他参数。

如果一切顺利，在本地路径`/Users/xx/.cocoapods/repo/WTSpecs`下可以发现我们提交的pod，这样你就可以在自己的工程引用这个私有的pod了

### 使用私有pod

在`Podfile`中有两种方法可以引用，

#### 方法一

```
use_frameworks!

target 'Test_Example' do
    # 这里可以单独指定这个私有pod的源
  pod 'A', :source => 'https://coding.net/wtlucky/podTestLibrary.git'

end

```

#### 方法二

```
use_frameworks!

# 在这里也可以全局指定pod源，这样在加载pod时，就会先从官方库中找，然后去我们的私有库中找，所以一定要把私有pod的名称和官方库中pod的名称区分开，最好先pod search确定下。

source 'https://github.com/CocoaPods/Specs.git'  # 官方库
source 'https://coding.net/wtlucky/podTestLibrary.git'   # 私有库

target 'Test_Example' do
    # 这里可以单独指定这个私有pod的源
  pod 'A'
  pod 'FMDB'

end

```

### pod的更新。

对pod`A`的维护更新，也是比较简单的。

改完的代码提交一个commit，然后打上相应的tag，比如说`0.0.2`,让后都push上去，

再`pod repo push WTSpecs A.podspec `即可


###  其他

#### 依赖问题

在做`B`pod时，因为依赖了私有库`A`，所以要写`s.dependency 'A'`,同时这个pod还依赖了其他官方库中的pod，比如说`AFNetworking`。

在`pod lib lint`或者`pod repo push`,就需要说明这个pod的源了，具体为什么不能再pods spec中指明各个依赖的源[还不清楚](https://github.com/CocoaPods/CocoaPods/issues/4921),

在命令后面加上

```
--sources=https://github.com/CocoaPods/Specs.git,https://coding.net/wtlucky/podTestLibrary.git
```

就可以了，意思是要指明编译时的源


#### 缓存

`pod repo push` 提交后一般要清一下pod缓存 `pod cache clean --all`, 然后调用` pod setup`更新


#### 常用命令

删除本地tag `git tag -d 0.0.1`
删除远程tag `git push origin --delete tag 0.0.1`


