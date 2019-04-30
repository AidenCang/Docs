# Python 操作亚马逊服务器相关的服务

## DynamoDB for Python
您也可以构建由事件触发的函数组成的无服务器应用程序，并使用 CodePipeline 和 AWS CodeBuild 自动部署这些应用程序
AWS Lambda 管理提供内存、CPU、网络和其他资源均衡的计算机群


### Profile

PynamoDB uses botocore to interact with the DynamoDB API. Thus, any method of configuration supported by botocore works with PynamoDB. For local development the use of environment variables such as AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY is probably preferable. You can of course use IAM users, as recommended by AWS. In addition EC2 roles will work as well and would be recommended when running on EC2.

!!! info "Profile"

    * botocore
    * DynamoDB API
    * AWS_ACCESS_KEY_ID
    * AWS_SECRET_ACCESS_KEY

### 相关的概念

High Level API
Low Level API
Exceptions
Migration API

### Default Configuration

Default settings may be overridden by providing a Python module which exports the desired new values. Set the PYNAMODB_CONFIG environment variable to an absolute path to this module or write it to /etc/pynamodb/global_default_settings.py to have it automatically discovered.

## Python Signals

Signals allow certain senders to notify subscribers that something happened. PynamoDB currently sends signals before and after every DynamoDB API call.

### PynamoDB支持两个信号:

User Arguments：

The callback must taking the following arguments:

!!! info "Arguments	Description"

    sender	The object that fired that method.
    operation_name	The string name of the `DynamoDB action`_
    table_name	The name of the table the operation is called upon.
    req_uuid	A unique identifer so subscribers can correlate the before and after events.

#### Tow Method

    pre_dynamodb_send

    post_dynamodb_send

```Python3
from pynamodb.signals import pre_dynamodb_send, post_dynamodb_send

def record_pre_dynamodb_send(sender, operation_name, table_name, req_uuid):
    pre_recorded.append((operation_name, table_name, req_uuid))

def record_post_dynamodb_send(sender, operation_name, table_name, req_uuid):
    post_recorded.append((operation_name, table_name, req_uuid))

pre_dynamodb_send.connect(record_pre_dynamodb_send)
post_dynamodb_send.connect(record_post_dynamodb_send)
```

### Set AccessKey

```Python3
from pynamodb.models import Model

class MyModel(Model):
    class Meta:
        aws_access_key_id = 'my_access_key_id'
        aws_secret_access_key = 'my_secret_access_key'
```
### Link

[GitHub Source](https://github.com/pynamodb/PynamoDB)

[Java environment](https://java.com/en/)

[DynamoDB Local Developer Debug](https://aws.amazon.com/cn/about-aws/whats-new/2013/09/12/amazon-dynamodb-local/)

[DynamoDB Local Debug](https://aws.amazon.com/cn/blogs/aws/dynamodb-local-for-desktop-development/)

[pynamoDB Docs](https://pynamodb.readthedocs.io/en/latest/index.html)

[dynalite](https://github.com/mhart/dynalite)

[aws DynamoDB Libs](https://docs.aws.amazon.com/zh_cn/amazondynamodb/latest/developerguide/DynamoDBLocal.html)

[Python信号库](https://pypi.org/project/blinker/)
