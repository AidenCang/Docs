# Django中间件使用


### WSGI
https://wsgi.readthedocs.io/en/latest/

### 如何使用wusgi部署应用程序
https://docs.djangoproject.com/en/2.2/howto/deployment/wsgi/


## SessionMiddleWare、Cookie
Django为匿名会话提供全面支持。会话框架允许您基于每个站点访问者存储和检索任意数据。它在服务器端存储数据并抽象cookie的发送和接收。`Cookie包含会话ID` - 而不是数据本身（除非您使用基于cookie的后端）。

django.contrib.sessions.middleware.SessionMiddleware
### Session保存的位置

!!! info "Session保存的位置"

    *默认数据库中
    *文件系统中
    *[缓存系统中](https://docs.djangoproject.com/en/2.2/topics/cache/)
建议保留该SESSION_COOKIE_HTTPONLY设置True以防止从JavaScript访问存储的数据。

!!! info "警告"

    如果SECRET_KEY没有保密并且您正在使用它 PickleSerializer，则可能导致任意远程代码执行。

    拥有的攻击者SECRET_KEY不仅可以生成伪造的会话数据，您的站点将信任该数据，还可以远程执行任意代码，因为数据是使用pickle序列化的。

    如果您使用基于cookie的会话，请特别注意您的密钥始终保密，对于任何可远程访问的系统。

    会话数据已签名但未加密

    使用cookie后端时，客户端可以读取会话数据。

    MAC（消息认证码）用于保护数据免受客户端的更改，以便会话数据在被篡改时无效。如果存储cookie的客户端（例如用户的浏览器）无法存储所有会话cookie并丢弃数据，则会发生相同的失效。即使Django压缩数据，它仍然完全有可能超过每个cookie 4096字节的公共限制。

    没有保鲜

    还要注意，尽管MAC可以保证数据的真实性（它是由您的站点生成的，而不是其他人生成的），以及数据的完整性（它都是正确的），但它无法保证新鲜度，即你被送回客户的最后一件事。这意味着对于会话数据的某些用途，cookie后端可能会让您重播攻击。与保存每个会话的服务器端记录并在用户注销时使其无效的其他会话后端不同，当用户注销时，基于cookie的会话不会失效。因此，如果攻击者窃取用户的cookie，即使用户退出，他们也可以使用该cookie登录该用户。如果Cookie比您的旧版本旧，则只会将其视为“陈旧” SESSION_COOKIE_AGE。

    性能

    最后，Cookie的大小会对您网站的速度产生影响。


## Django模板

### setting中配置

```json
  TEMPLATES = [
      {
          'BACKEND': 'django.template.backends.django.DjangoTemplates',
          'DIRS': [],
          'APP_DIRS': True,
          'OPTIONS': {
              'context_processors': [
                  'django.template.context_processors.debug',
                  'django.template.context_processors.request',
                  'django.contrib.auth.context_processors.auth',
                  'django.contrib.messages.context_processors.messages',
              ],
          },
      },
  ]
```
### 在View中继承`TemplateResponseMixin`这个类来对View侧获取模板名称的处理，同时使用`TemplateResponse`关联View和HTTTResponse的逻辑处理

```Python
class TemplateResponseMixin:
    """A mixin that can be used to render a template."""
    template_name = None
    template_engine = None
    response_class = TemplateResponse
    content_type = None

    def render_to_response(self, context, **response_kwargs):
        """
        Return a response, using the `response_class` for this view, with a
        template rendered with the given context.

        Pass response_kwargs to the constructor of the response class.
        """
        response_kwargs.setdefault('content_type', self.content_type)
        return self.response_class(
            request=self.request,
            template=self.get_template_names(),
            context=context,
            using=self.template_engine,
            **response_kwargs
        )

    def get_template_names(self):
        """
        Return a list of template names to be used for the request. Must return
        a list. May not be called if render_to_response() is overridden.
        """
        if self.template_name is None:
            raise ImproperlyConfigured(
                "TemplateResponseMixin requires either a definition of "
                "'template_name' or an implementation of 'get_template_names()'")
        else:
            return [self.template_name]

```

调用`python3.7/site-packages/django/template/loader.py`文件调用配置的引擎模块，在方法`select_template`中调用`django/template/__init__.py`中导入`EngineHandler`对`Engine`做一个逻辑处理，在`Engine`中加载``模板类

```Python
def get_template(self, template_name):
        """
        Return a compiled Template object for the given template name,
        handling template inheritance recursively.
        """
        template, origin = self.find_template(template_name)
        if not hasattr(template, 'render'):
            # template needs to be compiled
            template = Template(template, origin, template_name, engine=self)
        return template
```
Template类中对Html节点数据的填充和渲染
