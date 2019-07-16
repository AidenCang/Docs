# Oauth解决方案

The authorization server asks resource owners for their consensus to let client applications access their data. It also manages and issues the tokens needed for all the authorization flows supported by OAuth2 spec. Usually the same application offering resources through an OAuth2-protected API also behaves like an authorization server.

## 测试工具

[django-oauth-toolkit](http://django-oauth-toolkit.herokuapp.com/consumer/)


## Django 使用Oauth2认证服务器

1.安装

    pip install django-oauth-toolkit djangorestframework

    配置:

    INSTALLED_APPS = (
    'django.contrib.admin',
    ...
    'oauth2_provider',
    'rest_framework',
)

添加认证方式:

    REST_FRAMEWORK = {
        'DEFAULT_AUTHENTICATION_CLASSES': (
            'oauth2_provider.contrib.rest_framework.OAuth2Authentication',
        )
    }

插件简单的API

    from django.urls import path, include
    from django.contrib.auth.models import User, Group
    from django.contrib import admin
    admin.autodiscover()

    from rest_framework import generics, permissions, serializers

    from oauth2_provider.contrib.rest_framework import TokenHasReadWriteScope, TokenHasScope

    # first we define the serializers
    class UserSerializer(serializers.ModelSerializer):
        class Meta:
            model = User
            fields = ('username', 'email', "first_name", "last_name")

    class GroupSerializer(serializers.ModelSerializer):
        class Meta:
            model = Group
            fields = ("name", )

    # Create the API views
    class UserList(generics.ListCreateAPIView):
        permission_classes = [permissions.IsAuthenticated, TokenHasReadWriteScope]
        queryset = User.objects.all()
        serializer_class = UserSerializer

    class UserDetails(generics.RetrieveAPIView):
        permission_classes = [permissions.IsAuthenticated, TokenHasReadWriteScope]
        queryset = User.objects.all()
        serializer_class = UserSerializer

    class GroupList(generics.ListAPIView):
        permission_classes = [permissions.IsAuthenticated, TokenHasScope]
        required_scopes = ['groups']
        queryset = Group.objects.all()
        serializer_class = GroupSerializer

    # Setup the URLs and include login URLs for the browsable API.
    urlpatterns = [
        path('admin/', admin.site.urls),
        path('o/', include('oauth2_provider.urls', namespace='oauth2_provider')),
        path('users/', UserList.as_view()),
        path('users/<pk>/', UserDetails.as_view()),
        path('groups/', GroupList.as_view()),
        # ...
    ]


添加与模型

    OAUTH2_PROVIDER = {
        # this is the list of available scopes
        'SCOPES': {'read': 'Read scope', 'write': 'Write scope', 'groups': 'Access to your groups'}
    }

    REST_FRAMEWORK = {
        # ...

        'DEFAULT_PERMISSION_CLASSES': (
            'rest_framework.permissions.IsAuthenticated',
        )
    }

## 授权类型

### Authorization Code Grant

The authorization code grant type is used to obtain both access tokens and refresh tokens and is optimized for confidential clients. Since this is a redirection-based flow, the client must be capable of interacting with the resource owner’s user-agent (typically a web browser) and capable of receiving incoming requests (via redirection) from the authorization server:

    +----------+
    | Resource |
    |   Owner  |
    |          |
    +----------+
         ^
         |
        (B)
    +----|-----+          Client Identifier      +---------------+
    |         -+----(A)-- & Redirection URI ---->|               |
    |  User-   |                                 | Authorization |
    |  Agent  -+----(B)-- User authenticates --->|     Server    |
    |          |                                 |               |
    |         -+----(C)-- Authorization Code ---<|               |
    +-|----|---+                                 +---------------+
      |    |                                         ^      v
     (A)  (C)                                        |      |
      |    |                                         |      |
      ^    v                                         |      |
    +---------+                                      |      |
    |         |>---(D)-- Authorization Code ---------'      |
    |  Client |          & Redirection URI                  |
    |         |                                             |
    |         |<---(E)----- Access Token -------------------'
    +---------+       (w/ Optional Refresh Token)



### Implicit Grant

The implicit grant type is used to obtain access tokens (it does not support the issuance of refresh tokens) and is optimized for public clients known to operate a particular redirection URI. These clients are typically implemented in a browser using a scripting language such as JavaScript.

Unlike the authorization code grant type, in which the client makes separate requests for authorization and for an access token, the client receives the access token as the result of the authorization request.

The implicit grant type does not include client authentication, and relies on the presence of the resource owner and the registration of the redirection URI. Because the access token is encoded into the redirection URI, it may be exposed to the resource owner and other applications residing on the same device:

    +----------+
    | Resource |
    |  Owner   |
    |          |
    +----------+
         ^
         |
        (B)
    +----|-----+          Client Identifier     +---------------+
    |         -+----(A)-- & Redirection URI --->|               |
    |  User-   |                                | Authorization |
    |  Agent  -|----(B)-- User authenticates -->|     Server    |
    |          |                                |               |
    |          |<---(C)--- Redirection URI ----<|               |
    |          |          with Access Token     +---------------+
    |          |            in Fragment
    |          |                                +---------------+
    |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
    |          |          without Fragment      |     Client    |
    |          |                                |    Resource   |
    |     (F)  |<---(E)------- Script ---------<|               |
    |          |                                +---------------+
    +-|--------+
      |    |
     (A)  (G) Access Token
      |    |
      ^    v
    +---------+
    |         |
    |  Client |
    |         |
    +---------+

### Resource Owner Password Credentials Grant

The resource owner password credentials grant type is suitable in cases where the resource owner has a trust relationship with the client, such as the device operating system or a highly privileged application. The authorization server should take special care when enabling this grant type and only allow it when other flows are not viable.

This grant type is suitable for clients capable of obtaining the resource owner’s credentials (username and password, typically using an interactive form). It is also used to migrate existing clients using direct authentication schemes such as HTTP Basic or Digest authentication to OAuth by converting the stored credentials to an access token:

    +----------+
    | Resource |
    |  Owner   |
    |          |
    +----------+
         v
         |    Resource Owner
        (A) Password Credentials
         |
         v
    +---------+                                  +---------------+
    |         |>--(B)---- Resource Owner ------->|               |
    |         |         Password Credentials     | Authorization |
    | Client  |                                  |     Server    |
    |         |<--(C)---- Access Token ---------<|               |
    |         |    (w/ Optional Refresh Token)   |               |
    +---------+                                  +---------------+

### Client Credentials Grant

The client can request an access token using only its client credentials (or other supported means of authentication) when the client is requesting access to the protected resources under its control, or those of another resource owner that have been previously arranged with the authorization server (the method of which is beyond the scope of this specification).

The client credentials grant type MUST only be used by confidential clients:

    +---------+                                  +---------------+
    :         :                                  :               :
    :         :>-- A - Client Authentication --->: Authorization :
    : Client  :                                  :     Server    :
    :         :<-- B ---- Access Token ---------<:               :
    :         :                                  :               :
    +---------+                                  +---------------+

### JWT Profile for Client Authentication and Authorization Grants

    If you’re looking at JWT Tokens, please see Bearer Tokens instead.

    The JWT Profile RFC7523 implements the RFC7521 abstract assertion protocol. It aims to extend the OAuth2 protocol to use JWT as an additional authorization grant.

    Currently, this is not implemented but all PRs are welcome. See how to Contribute.

### Bearer Tokens

The most common OAuth 2 token type.

Bearer tokens is the default setting for all configured endpoints. Generally you will not need to ever construct a token yourself as the provided servers will do so for you.

By default, *Server generate Bearer tokens as random strings. However, you can change the default behavior to generate JWT instead. All preconfigured servers take as parameters token_generator and refresh_token_generator to fit your needs.

[Bearer Tokens](https://oauthlib.readthedocs.io/en/v3.0.1/oauth2/tokens/bearer.html#id2)

# 跨域提交问题

XHR POST:提交数据:
解决方案:使用第三方库来解决跨域访问问题:

Python第三方认证环境搭建:

[oauthlib](https://oauthlib.readthedocs.io/en/v3.0.1/index.html)

Django REST_FRAMEWORK 框架

[Django REST framework](https://www.django-rest-framework.org/)

跨域访问

[wiki百科 对跨域问题的说 Cross-origin_resource_sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)

Django后端解决跨域访问问题

[django-cors-middleware](https://github.com/zestedesavoir/django-cors-middleware)

Ajax访问服务器

[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/send)

第三方使用的授权方案:

[接入方式及流程](https://doc-bot.tmall.com/docs/doc.htm?spm=0.7629140.0.0.3c061780hi7eyy&treeId=393&articleId=106999&docType=1)

[授权方案](https://doc-bot.tmall.com/docs/doc.htm?spm=0.7629140.0.0.77411780K4cdv7&treeId=393&articleId=107000&docType=1)
