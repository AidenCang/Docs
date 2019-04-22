# aws IOT 实现方案
角色:
arn:aws:iam::223598429371:role/lambda_invoke_function_assume_apigw_role
/2015-03-31/functions/arn:aws:lambda:us-east-1:223598429371:function:Calc/invocations

## 需要解决的问题

### 安装CLI

[命令行接口安装](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/install-macos.html)

### 如何标记一款产品和多个设备

productid : IoT 设备 ID
accessToken: IoT 设备 Token
timestamp : 证书申请时间戳
applyState : 申请状态（如果申请过证书设置为-1，标记此设备已经注册过证书了）
certID : 设备关联的证书 ID

### 物联网设备往往没有屏幕，也没有工作人员在设备前进行手动管理。

升级操作如何触发？升级失败后如何回滚，并上报升级状态？

### 在物联网多人权限管理的场景中

我们使用 STS 服务分发临时凭证，以满足权限的细粒度控制

### 多个APP的交互问题

[多个控制端 APP 交互管理多个设备](https://aws.amazon.com/cn/blogs/china/aws-iot-series-5/)
### 在 IoT 场景下，考虑到设备与服务端的交互的高可用性，以及对时间和资源调度的不可预知性

利用 API Gateway 和 Lambda 组合的无服务器架构方式可以更好的满足实际使用需求。这是因为 API Gateway 和 Lambda 按照请求数量和持续时间进行计费，无需管理服务器，并获得持续扩展的能力。

### 那么设备又如何连接到云端呢？

AWS IoT 提供了 MQTT, MQTT over WebSocket,  HTTP 三种接入方式
MQTT 或 MQTT over WebSocket 支持云端主动向客户端发送消息，而 HTTP 则不能。

### 云端又如何做身份识别的呢？

X.509 设备证书和 HTTP SigV4 两种认证方式


### AWS 提供了多种证书下发的方式

如果使用您自己的 CA 签发的设备证书，您可以通过 JITR(Just-In-Time-Registration) 或 JITP(Just-In-Time-Provision) 的方式将设备连接至云端并指定相关控制策略；如果使用 AWS IoT Core 签发的设备证书，您可以通过 CVM(Certificate Vendor Machine) 的方式将设备连接至云端并控制相关控制策略；当然，用户也可以根据自己的需求使用 AWS IOT API 定制自己的身份认证过程。

### 根据自己的需求使用 AWS IOT API 定制自己的身份认证过程。

[设备预配置](https://docs.aws.amazon.com/zh_cn/iot/latest/developerguide/iot-provision.html)

!!! info "如果使用您自己的 CA 签发的设备证书"

    * 您可以通过 JITR(Just-In-Time-Registration)
    * JITP(Just-In-Time-Provision)

!!! info "AWS 的服务进行架构设计和业务逻辑设计"

    * IoT Core: 用于设备连接，设备管理，设备认证，消息转发。
    * Lambda: 提供设备配置信息，调用 AWS IoT Core API, DynamoDB API。
    * API Gateway: 管理维护 Restful API，并且触发 Lambda。
    * DynamoDB: 存放用户和设备的绑定关系。
    * STS: 获得 AWS 临时授权，用于设备连接至 IoT Core。
    * CloudFormation: 帮助用户在不同地区快速部署相同的架构、服务。

物联网场景中，终端设备的生产者和销售者往往并不是同一个，而产品的最终使用地点也可能因为销售路径的不同而有差异。为了在全球区域提供相同的使用体验，设备应该能够根据其所在的区域进行自发性的连接选择，并通过这种方式提供更低的网络时延。作为 IoT 服务提供者，需要设计部署一套跨区域的合理架构从而满足这样的需求。

[物联网设备全球部署架构方案](https://aws.amazon.com/cn/blogs/china/aws-iot-series-6/)

### 区域设置

要将 REST API 与 Lambda 集成，您必须选择一个同时提供 API Gateway 和 Lambda 服务的区域。有关区域可用性，请参阅区域和终端节点。

API 终端节点
API Gateway 中部署到特定区域的 API 的主机名。主机名的格式是 {api-id}.execute-api.{region}.amazonaws.com。支持以下类型的 API 终端节点：

边缘优化的 API 终端节点

私有 API 终端节点

区域 API 终端节点

#### API GageWay授权控制

!!! info "API Gateway授权控制"

   * [IAM 权限](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/permissions.html)
   * [Lambda 授权方](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html)
   * [ Amazon Cognito 用户池](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-integrate-with-cognito.html)
   * [统计使用情况](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-api-usage-plans.html)

!!! info "使用方式"

    * 您可以使用 API Gateway 控制台
    * API Gateway REST API
    * AWS CLI
    * 某个 AWS 软件开发工具包执行这些任务和其他任务

[区域和终端节点](https://docs.aws.amazon.com/general/latest/gr/rande.html#apigateway_region)

### IoT设备的状态控制和数据分析

[AWS IoT DAY-Shenzhen-AWS IoT设备的状态控制和数据分析](http://aws.amazon.bokecc.com/news/show-1062.html)


### APIGateway  Access DynamoDB
[将 AWS Lambda 与 Amazon API Gateway 结合使用](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/with-on-demand-https-example.html)
[在 API Gateway 中为 AWS Lambda 函数创建 REST API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/integrating-api-with-aws-services-lambda.html)
[在 API Gateway 中创建 REST API 作为 Amazon S3 代理](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/integrating-api-with-aws-services-s3.html)
