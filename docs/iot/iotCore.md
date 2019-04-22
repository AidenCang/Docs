# IOTCore

## Aws IOTCore

[Aws移动开发平台blog](https://aws.amazon.com/cn/blogs/mobile/)
[IOT案例](https://aws.amazon.com/cn/solutions/case-studies/iot/)

#### AWS IoT Core认证方式

!!! info "AWS IoT Core支持基于证书认证"

    *自定义授权程序
    *相互身份验证
    *Amazon Cognito Identity

AWS IoT Core支持基于证书的相互身份验证，自定义授权程序和Amazon Cognito Identity，以验证对AWS IoT设备网关的请求。Amazon Cognito 用户池于去年普遍推出。它允许客户轻松添加用户注册并登录移动和Web应用程序。您可以使用Cognito User Pools身份通过将其链接到Cognito Federated Identities来与AWS IoT Core进行通信。



### IAM

[AWS Identity and Access Management](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/introduction.html) 是一种 Web 服务，可以帮助您安全地控制对 AWS 资源的访问。您可以使用 IAM 控制对哪个用户进行身份验证 (登录) 和授权 (具有权限) 以使用资源。

当您首次创建 AWS 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 账户 AWS，可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。强烈建议您不使用 根用户 执行日常任务，即使是管理任务。请遵守仅将用于创建首个 用户的最佳实践。然后请妥善保存 根用户 凭证，仅用它们执行少数账户和服务管理任务。

#### 访问方式

您可以通过以下任何方式使用 AWS Identity and Access Management。

AWS 管理控制台

控制台是用于管理 IAM 和 AWS 资源的基于浏览器的界面。有关通过控制台访问 IAM 的更多信息，请参阅 IAM 控制台和登录页面。有关指导您使用控制台的教程，请参阅创建您的第一个 IAM 管理员用户和组。

AWS 命令行工具

您可以使用 AWS 命令行工具，在系统的命令行中发出命令以执行 IAM 和 AWS 任务。与控制台相比，使用命令行更快、更方便。如果要构建执行 AWS 任务的脚本，命令行工具也会十分有用。

AWS 提供两组命令行工具：AWS Command Line Interface (AWS CLI) 和 适用于 Windows PowerShell 的 AWS 工具。有关安装和使用 AWS CLI 的更多信息，请参阅 AWS Command Line Interface 用户指南。有关安装和使用Windows PowerShell 工具的更多信息，请参阅适用于 Windows PowerShell 的 AWS 工具 用户指南。

AWS 开发工具包

AWS 提供的 SDK (开发工具包) 包含各种编程语言和平台 (Java、Python、Ruby、.NET、iOS、Android 等) 的库和示例代码。开发工具包提供便捷的方式来创建对 IAM 和 AWS 的编程访问。例如，开发工具包执行以下类似任务：加密签署请求、管理错误以及自动重试请求。有关 AWS 开发工具包的信息（包括如何下载及安装），请参阅适用于 Amazon Web Services 的工具页面。

IAM HTTPS API

您可以使用 IAM HTTPS API（可让您直接向服务发布 HTTPS 请求）以编程方式访问 IAM 和 AWS。使用 HTTPS API 时，必须添加代码，才能使用您的凭证对请求进行数字化签名。有关更多信息，请参见通过提出 HTTP 查询请求来调用 API和 IAM API 参考。

#### 策略

!!! info "策略"

    * 策略摘要
    * 服务摘要
    * 操作摘要

#### 基于身份和基于资源的策略

!!! info "策略分类"

    * 基于身份的策略是附加到 IAM 身份（如 IAM 用户、组或角色）的权限策略
    * 基于资源的策略是附加到资源（如 Amazon S3 存储桶或 IAM 角色信任策略）的权限策略。


基于身份的策略控制身份可以在哪些条件下对哪些资源执行哪些操作。基于身份的策略可以进一步分类：

托管策略 – 基于身份的独立策略，可附加到您的 AWS 账户中的多个用户、组和角色。您可以使用两个类型的托管策略：

AWS 托管策略 – 由 AWS 创建和管理的托管策略。如果您刚开始使用策略，建议先使用 AWS 托管策略。

客户托管策略 – 您在 AWS 账户中创建和管理的托管策略。与 AWS 托管策略相比，客户托管策略可以更精确地控制策略。您可以在可视化编辑器中创建和编辑 IAM 策略，也可以直接创建 JSON 策略文档以创建和编辑该策略。有关更多信息，请参阅 创建 IAM 策略 和 编辑 IAM 策略。

内联策略 – 由您创建和管理的策略，直接嵌入在单个用户、组或角色中。大多数情况下，我们不建议使用内联策略。

基于资源的策略控制指定的委托人可以在何种条件下对该资源执行哪些操作。基于资源的策略是内联策略，没有基于资源的托管策略。要启用跨账户访问，您可以将整个账户或其他账户中的 IAM 实体指定为基于资源的策略中的委托人。

IAM 服务仅支持一种类型的基于资源的策略（称为角色信任策略），这种策略附加到 IAM 角色。由于 IAM 角色同时是支持基于资源的策略的身份和资源，因此，您必须同时将信任策略和基于身份的策略附加到 IAM 角色。信任策略定义哪些委托人实体（账户、用户、角色和联合身份用户）可以代入该角色。要了解 IAM 角色如何与其他基于资源的策略不同，请参阅IAM 角色与基于资源的策略有何不同。


IAM 控制台中提供了策略摘要 表，这些表总结了策略中对每个服务允许或拒绝的访问级别、资源和条件。策略在三个表中概括：策略摘要、服务摘要和操作摘要。策略摘要表包含服务列表。选择其中的服务可查看服务摘要。该摘要表包含所选服务的操作和关联权限的列表。您可以选择该表中的操作以查看操作摘要。该表包含所选操作的资源和条件列表。


## Amazon Cognito 文档

[Amazon Cognito 文档](https://docs.aws.amazon.com/zh_cn/cognito/)

[Configuring Cognito User Pools to Communicate with AWS IoT Core](https://aws.amazon.com/cn/blogs/iot/configuring-cognito-user-pools-to-communicate-with-aws-iot-core/)

!!! info "经过Amazon Cognito身份验证的用户需要两个策略才能访问AWS IoT"

    * 第一个策略附加到经过身份验证的池的角色，以验证和授权Cognito用户与AWS IoT进行通信。
    * 第二个策略附加到经过身份验证的Cognito用户ID主体，以获得细粒度权限。

#### 常见任务的快速链接

[常见任务的快速链接](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/introduction_quick-links-common-tasks.html)

## 如何使用您自己的身份和访问管理系统来控制对AWS IoT资源的访问
[如何使用您自己的身份和访问管理系统来控制对AWS IoT资源的访问](https://aws.amazon.com/cn/blogs/security/how-to-use-your-own-identity-and-access-management-systems-to-control-access-to-aws-iot-resources/)

## Configuring Cognito User Pools to Communicate with AWS IoT Core
[Configuring Cognito User Pools to Communicate with AWS IoT Core](https://aws.amazon.com/cn/blogs/iot/configuring-cognito-user-pools-to-communicate-with-aws-iot-core/?nc1=b_rp)

## Understanding Amazon Cognito user pool OAuth 2.0 grants
[Understanding Amazon Cognito user pool OAuth 2.0 grants](https://aws.amazon.com/cn/blogs/mobile/understanding-amazon-cognito-user-pool-oauth-2-0-grants/?nc1=b_rp)


## Aws CLI

[CLI](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-welcome.html)


## APi Gateway

两种Api类型

Select whether you would like to create a REST API or a WebSocket API.

## API GateWay

API Gateway 的优势
Amazon API Gateway 具备下列优点：

支持有状态 (WebSocket) 和无状态 (REST) API

与 AWS 服务（如 AWS Lambda、Amazon Kinesis 和 Amazon DynamoDB）集成

能够使用 IAM 角色和策略、AWS Lambda 授权方或 Amazon Cognito 用户池来授权对您的 API 的访问

用于将 API 作为 SaaS 销售的使用计划和 API 密钥

用以安全地推出更改的金丝雀版本部署

API 使用情况和 API 更改的 CloudTrail 日志记录和监控

CloudWatch 访问日志记录和执行日志记录，包括设置警报的能力

能够使用 AWS CloudFormation 模板以支持创建 API

支持自定义域名



## GoogleIOTCore
[GoogleIOTCore](https://cloud.google.com/iot-core/)
