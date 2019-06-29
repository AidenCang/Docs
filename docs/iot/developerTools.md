# aws 开发工具

## Pycharm 开发工具


[Pycharm下载工具](https://aws.amazon.com/cn/pycharm/)
[AWS Toolkit for JetBrains](https://docs.aws.amazon.com/zh_cn/toolkit-for-jetbrains/latest/userguide/welcome.html)
[AWS Serverless Application Model (SAM) 开发库](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md)
[API Gateway + Cognito Auth + Cognito Hosted Auth Example](https://github.com/awslabs/serverless-application-model/tree/master/examples/2016-10-31/api_cognito_auth)


sam init --runtime python3.6 --name python-debugging
$ DEBUGGER_ARGS="-m ikpdb --ikpdb-port=5858 --ikpdb-working-directory=/var/task/ --ikpdb-client-working-directory=/myApp --ikpdb-address=0.0.0.0" echo {} | sam local invoke -d 5858 myFunction
