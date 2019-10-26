# Android&IOS打包发布


## 概要
应用程序正在改变世界，丰富人们的生活，并使像您这样的开发人员能够前所未有地进行创新。结果，App Store已成长为一个激动人心且充满活力的生态系统，为数百万开发人员和超过10亿用户所用。无论您是第一次开发人员还是经验丰富的程序员组成的庞大团队，我们都为您正在为App Store创建应用程序而感到兴奋，并希望帮助您了解我们的指南，因此您可以确信自己的应用程序将快速通过审核过程。

## 介绍
应用市场的指导原则很简单-我们希望为用户提供获取应用程序的安全体验，并为所有开发人员取得成功提供巨大的机会。我们通过提供高度策划的应用来做到这一点，其中的每个应用程序都经过专家审查，编辑团队可以帮助用户每天发现新应用程序。对于其他所有方面，始终都有开放的Internet。如果应用市场模型和指南不适合您的应用或业务构想，那么我们也提供Safari来提供出色的Web体验。
在以下页面上，您会发现我们的最新指南分为五个清晰的部分：安全，性能，业务，设计和法律。应用市场总是在不断变化和改进，以适应我们客户和我们产品的需求。您的应用程序也应该进行更改和改进，以便保留在应用市场中。

1.安全
2.性能
3.业务
4.设计
5.法律法规(不同国家和地区)

## 确保

测试您的应用程序是否崩溃和错误
确保所有应用信息和元数据完整且准确
更新您的联系信息，以防App Review需要与您联系
提供有效的演示帐户和登录信息，以及查看您的应用程序可能需要的任何其他硬件或资源（例如，登录凭据或示例QR码）
启用后端服务，以便它们在审核期间处于活动状态并可以访问
在App Review注释中包括对非显而易见功能和应用内购买的详细说明，并在适当时包括支持文档。

## Android打包
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore ./key.jks -destkeystore ./key.jks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。

## [IOS打包](https://developer.apple.com/app-store/review/guidelines/)

我们会审查提交给AppStore的所有应用程序和应用程序更新，以确定它们是否可靠，是否达到预期效果以及是否没有令人反感的材料。在计划和开发应用程序时，请确保使用这些准则和资源。

1.规划和开发应用程序
2.是否到达预期
3.是否可靠
4.是否有让人发的内容
5.提交应用市场


### 检查您的应用是否遵循其他文档中的指导

发展方针

[应用程式设计指南](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007072)
[App Extension编程指南](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/)
[iOS数据存储准则](https://developer.apple.com/icloud/documentation/data-storage/index.html)
[macOS文件系统文档](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010672)
[Safari应用程序扩展](https://developer.apple.com/documentation/safariservices/safari_app_extensions)
[App Store Connect帮助](https://help.apple.com/app-store-connect/)

设计准则

[人机界面准则](https://developer.apple.com/design/human-interface-guidelines/)

品牌与行销准则

[营销资源和身份准则](https://developer.apple.com/app-store/marketing/guidelines/)
[Apple Pay身份准则](https://developer.apple.com/apple-pay/marketing/)
[添加到Apple电子钱包指南](https://developer.apple.com/wallet/Add-to-Apple-Wallet-Guidelines.pdf)
[使用苹果商标和版权的准则](http://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html)


### 开发、测试、数据统计
[Xcode Help](https://help.apple.com/xcode/mac/current/#/devc8c2a6be1)
[Apple Developer Program](https://developer.apple.com/programs/)
[测试](https://developer.apple.com/testflight/)


#### 数据统计

衡量iOS，macOS和tvOS上的应用的用户参与度，营销活动，获利等。
[Access App Analytic](https://developer.apple.com/app-store-connect/analytics/)

App Store来源
借助App Analytics，您可以查看有多少用户在搜索或浏览App Store时发现了您的应用（包括在iOS上点击适用于您的应用的Search Ads）以了解您的营销和元数据如何影响下载。

应用引荐来源
App Analytics会统计从另一个应用程序中的链接访问iOS或tvOS上您应用程序产品页面的用户。通过关注可带来最多App Store印象，下载和账单的应用来优化您的营销活动。

网络推荐人
链接到应用程序产品页面的博客，网站和其他在线资源对于通过口碑营销和PR来吸引用户至关重要。借助App Analytics，您可以查看哪些有机营销渠道为您的应用带来了最高的流量，下载量，使用量和收入。

App Store展示次数
查看您的应用程序图标在App Store上浏览了多少次，包括在搜索结果，精选，热门图表和App Store产品页面中。借助App Store展示次数，您可以计算出用户点击浏览您的应用的频率，而无需查看在App Store上的任何位置。

用户参与度
App Analytics提供了用户参与度指标，包括会话数，活动设备以及iOS和tvOS上您的应用程序的保留时间。借助这些指标，您可以评估产品更改的影响（例如修改初始的入职体验），以查看哪些更改可以改善与应用程序的互动。

删除新
查看有多少用户从运行iOS 12.3或更高版本的设备上删除了您的应用。测量“应用程序删除”，以更好地了解用户对应用程序更改（例如内容更新，价格调整或崩溃）的反应。按来源或用户组比较“应用删除”，以查看哪些类型的用户更有可能卸载您的应用。

营销活动
App Analytics可让您评估您的营销工作，以便您可以专注于最有效的广告系列。为每个营销活动创建唯一的链接，以了解哪些活动带来了最多的下载量和每个用户的平均支出。您还可以使用StoreKit API跟踪广告系列。

App Store产品页面
出色的产品页面可以吸引受众的注意力，传达您的应用价值，并说服用户下载。现在，您可以通过将下载次数与产品页面浏览量相关联来计算产品页面的效果。

付费用户
App Analytics根据Apple ID（而不是设备类型）对用户进行计数，从而使您可以更准确地了解付费用户数据。查看您一天有多少付费用户，以评估您所做的任何更改是否会影响应用程序内的支出。您还可以按来源过滤，以查看用户是否来自特定的广告系列或网站。

崩溃
找出您的应用每天在iOS或tvOS上崩溃的次数。您可以按平台，应用程序版本和操作系统版本筛选崩溃数据，以查明原因，帮助您为用户创造更好的体验。

按下载日期分类
只有Apple可以提供Apple ID首次从App Store下载应用程序的日期。您可以根据用户的购买日期过滤用户组，以在比较和分析用户行为时形成更完整的图片。

苹果电视数据
评估您的tvOS应用程序的用户参与度和获利。除了查看产品页面浏览量，下载量和参与度方面的数据外，您还可以查看通过营销活动获得的iOS用户在Apple TV上打开了同一个应用程序。*您还可以在另一个tvOS应用程序中推广tvOS应用程序，使用广告系列链接跟踪结果。

## [App Store Connect 使用入门](https://help.apple.com/app-store-connect/?lang=zh-cn#/)

App Store Connect 使用入门
添加、编辑和删除用户
管理 App 和版本
添加 App 图标、App 预览和截屏
管理构建版本
测试 Beta 版本
在 App Store 上发行
维护您的 App
衡量 App 表现
管理协议、税务和银行业务
获得付款
配置 App Store 功能
提供 App 内购买项目
参考

##
