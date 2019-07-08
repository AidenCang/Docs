# Django message


uwsgi's default configuration enforces a maximum size of 4kb for all the
HTTP headers. In order to leave some room for other cookies and headers,
restrict the session cookie to 1/2 of 4kb. See #18781.

## Uwsgi 每一个请求的默认信息列表,主要包括请求信息

```JSON
{
	'TMPDIR': '/var/folders/96/lqx674_55nn4hw_3vvdxqbcc0000gn/T/',
	'__CF_USER_TEXT_ENCODING': '0x1F5:0x19:0x34',
	'SHELL': '/bin/zsh',
	'HOME': '/Users/cangck',
	'Apple_PubSub_Socket_Render': '/private/tmp/com.apple.launchd.pGPFSHWK0a/Render',
	'SSH_AUTH_SOCK': '/private/tmp/com.apple.launchd.mhtrkiZCub/Listeners',
	'PATH': '/Users/cangck/PycharmProjects/hello_django/env/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/Users/cangck/.rvm/bin',
	'LOGNAME': 'cangck',
	'XPC_SERVICE_NAME': '0',
	'USER': 'cangck',
	'XPC_FLAGS': '0x0',
	'LC_CTYPE': 'zh_CN.UTF-8',
	'LESS': '-R',
	'LSCOLORS': 'Gxfxcxdxbxegedabagacad',
	'OLDPWD': '/Users/cangck/PycharmProjects/hello_django',
	'PAGER': 'less',
	'PWD': '/Users/cangck/PycharmProjects/hello_django',
	'SHLVL': '1',
	'ZSH': '/Users/cangck/.oh-my-zsh',
	'rvm_bin_path': '/Users/cangck/.rvm/bin',
	'rvm_path': '/Users/cangck/.rvm',
	'rvm_prefix': '/Users/cangck',
	'rvm_version': '1.29.3 ()',
	'TERM_PROGRAM': 'vscode',
	'TERM_PROGRAM_VERSION': '1.33.1',
	'LANG': 'zh_CN.UTF-8',
	'TERM': 'xterm-256color',
	'_system_type': 'Darwin',
	'_system_name': 'OSX',
	'_system_version': '10.14',
	'_system_arch': 'x86_64',
	'VIRTUAL_ENV': '/Users/cangck/PycharmProjects/hello_django/env',
	'PS1': '(env) ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)',
	'rvm_alias_expanded': '',
	'rvm_bin_flag': '',
	'rvm_docs_type': '',
	'rvm_gemstone_package_file': '',
	'rvm_gemstone_url': '',
	'rvm_niceness': '',
	'rvm_nightly_flag': '',
	'rvm_only_path_flag': '',
	'rvm_pretty_print_flag': '',
	'rvm_proxy': '',
	'rvm_quiet_flag': '',
	'rvm_ruby_bits': '',
	'rvm_ruby_file': '',
	'rvm_ruby_make': '',
	'rvm_ruby_make_install': '',
	'rvm_ruby_mode': '',
	'rvm_script_name': '',
	'rvm_sdk': '',
	'rvm_silent_flag': '',
	'rvm_use_flag': '',
	'rvm_wrapper_name': '',
	'rvm_hook': '',
	'_': '/Users/cangck/PycharmProjects/hello_django/env/bin/python',
	'__PYVENV_LAUNCHER__': '/Users/cangck/PycharmProjects/hello_django/env/bin/python',
	'DJANGO_SETTINGS_MODULE': 'web_project.settings',
	'TZ': 'UTC',
	'RUN_MAIN': 'true',
	'SERVER_NAME': '1.0.0.127.in-addr.arpa',
	'GATEWAY_INTERFACE': 'CGI/1.1',
	'SERVER_PORT': '8003',
	'REMOTE_HOST': '',
	'CONTENT_LENGTH': '',
	'SCRIPT_NAME': '',
	'SERVER_PROTOCOL': 'HTTP/1.1',
	'SERVER_SOFTWARE': 'WSGIServer/0.2',
	'REQUEST_METHOD': 'GET',
	'PATH_INFO': '/hello/current_time/',
	'QUERY_STRING': '',
	'REMOTE_ADDR': '127.0.0.1',
	'CONTENT_TYPE': 'text/plain',
	'HTTP_HOST': '127.0.0.1:8003',
	'HTTP_CONNECTION': 'keep-alive',
	'HTTP_CACHE_CONTROL': 'max-age=0',
	'HTTP_UPGRADE_INSECURE_REQUESTS': '1',
	'HTTP_USER_AGENT': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36',
	'HTTP_ACCEPT': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
	'HTTP_ACCEPT_ENCODING': 'gzip, deflate, br',
	'HTTP_ACCEPT_LANGUAGE': 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7',
	'HTTP_COOKIE': '_ga=GA1.1.990647925.1517999642; csrftoken=XYsCozyDARDQwLnztaLrpX47fdPbB93cR71ehOIJXvJ0MxSQzSCJl6tUjVU8xXWd; sessionid=pmkov2tmpfieugfbbl8t74lr8wk8dkbb; _gid=GA1.1.1186369822.1556894918; __lfcc=1; messages="aaaec40dc811d4ff7019b51ba217c91e594493e7$[[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]\\054[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]\\054[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]\\054[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]\\054[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]\\054[\\"__json_message\\"\\0540\\05420\\054\\"hello world\\"]]"',
	'wsgi.input': < django.core.handlers.wsgi.LimitedStream object at 0x1083e8978 > ,
	'wsgi.errors': < _io.TextIOWrapper name = '<stderr>'
	mode = 'w'
	encoding = 'UTF-8' > ,
	'wsgi.version': (1, 0),
	'wsgi.run_once': False,
	'wsgi.url_scheme': 'http',
	'wsgi.multithread': True,
	'wsgi.multiprocess': False,
	'wsgi.file_wrapper': < class 'wsgiref.util.FileWrapper' >
}

```

```JSON
{
	'Content-Length': '',
	'Content-Type': 'text/plain',
	'Host': '127.0.0.1:8003',
	'Connection': 'keep-alive',
	'Cache-Control': 'max-age=0',
	'Upgrade-Insecure-Requests': '1',
	'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36',
	'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
	'Accept-Encoding': 'gzip, deflate, br',
	'Accept-Language': 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7',
	'Cookie': '_ga=GA1.1.990647925.1517999642; csrftoken=XYsCozyDARDQwLnztaLrpX47fdPbB93cR71ehOIJXvJ0MxSQzSCJl6tUjVU8xXWd; sessionid=pmkov2tmpfieugfbbl8t74lr8wk8dkbb; _gid=GA1.1.1186369822.1556894918; __lfcc=1; 313442014.cache-source=[%220%20Stars%22%2C%220%20Forks%22]'
}
```
## 关联

[DjangoMessage](https://docs.djangoproject.com/en/2.2/ref/contrib/messages/)
