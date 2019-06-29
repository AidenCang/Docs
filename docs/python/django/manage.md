# Python Manage 类源码解析

## 概述

The base class from which all management commands ultimately
derive.

Use this class if you want access to all of the mechanisms which
parse the command-line arguments and work out what code to call in
response; if you don't need to change any of that behavior,
consider using one of the subclasses defined in this file.

If you are interested in overriding/customizing various aspects of
the command-parsing and -execution behavior, the normal flow works
as follows:

1. ``django-admin`` or ``manage.py`` loads the command class
   and calls its ``run_from_argv()`` method.

2. The ``run_from_argv()`` method calls ``create_parser()`` to get
   an ``ArgumentParser`` for the arguments, parses them, performs
   any environment changes requested by options like
   ``pythonpath``, and then calls the ``execute()`` method,
   passing the parsed arguments.

3. The ``execute()`` method attempts to carry out the command by
   calling the ``handle()`` method with the parsed arguments; any
   output produced by ``handle()`` will be printed to standard
   output and, if the command is intended to produce a block of
   SQL statements, will be wrapped in ``BEGIN`` and ``COMMIT``.

4. If ``handle()`` or ``execute()`` raised any exception (e.g.
   ``CommandError``), ``run_from_argv()`` will  instead print an error
   message to ``stderr``.

Thus, the ``handle()`` method is typically the starting point for
subclasses; many built-in commands and command types either place
all of their logic in ``handle()``, or perform some additional
parsing work in ``handle()`` and then delegate from it to more
specialized methods as needed.

Several attributes affect behavior at various steps along the way:

``help``
    A short description of the command, which will be printed in
    help messages.

``output_transaction``
    A boolean indicating whether the command outputs SQL
    statements; if ``True``, the output will automatically be
    wrapped with ``BEGIN;`` and ``COMMIT;``. Default value is
    ``False``.

``requires_migrations_checks``
    A boolean; if ``True``, the command prints a warning if the set of
    migrations on disk don't match the migrations in the database.

``requires_system_checks``
    A boolean; if ``True``, entire Django project will be checked for errors
    prior to executing the command. Default value is ``True``.
    To validate an individual application's models
    rather than all applications' models, call
    ``self.check(app_configs)`` from ``handle()``, where ``app_configs``
    is the list of application's configuration provided by the
    app registry.

``stealth_options``
    A tuple of any options the command uses which aren't defined by the
    argument parser.
## 关键技术

!!! info "关键技术点"

    * 1.Python 参数解析库: argparse
    * 2.pkgutil 包的遍历解析模块
    * 3.difflib 对象的差分比较
    * 4.importlib 导入库的便捷函数
    * 5.vars 快速生成字典
    * 6.命令行的颜色显示

## 源码解析
Python manage.py --help  打印系统中支持的类`django.core.management`包中包含相关的命令
```Python
def main():
    # 添加设置模块的命令到环境变量中
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'web_project.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
```

django.core.management`中包含了全局的函数，处理命令入口

```Python
def execute_from_command_line(argv=None):
    """Run a ManagementUtility."""
    utility = ManagementUtility(argv)
    utility.execute()
```

使用当前`find_commands`函数遍历`django/core/management/commands`目录下的模块名称，每一个模块处理一个命令参数
```Python
def find_commands(management_dir):
    """
    Given a path to a management directory, return a list of all the command
    names that are available.
    """
    command_dir = os.path.join(management_dir, 'commands')
    return [name for _, name, is_pkg in pkgutil.iter_modules([command_dir])
            if not is_pkg and not name.startswith('_')]
#返回的数据结果
['check', 'compilemessages', 'createcachetable', 'dbshell', 'diffsettings', 'dumpdata', 'flush', 'inspectdb', 'loaddata', 'makemessages', 'makemigrations', 'migrate', 'runserver', 'sendtestemail', 'shell', 'showmigrations', 'sqlflush', 'sqlmigrate', 'sqlsequencereset', 'squashmigrations', 'startapp', 'startproject', 'test', 'testserver']
```

调用execute执行函数
1.调用系统parser构建参数和参数的解析
2.处理系统自动加载autoreload
3.调用`self.fetch_command(subcommand).run_from_argv(self.argv)`查找并执行函数
```Python
def execute(self):
    """
    Given the command-line arguments, figure out which subcommand is being
    run, create a parser appropriate to that command, and run it.
    """
    try:
        subcommand = self.argv[1]
    except IndexError:
        subcommand = 'help'  # Display help if no arguments were given.

    # Preprocess options to extract --settings and --pythonpath.
    # These options could affect the commands that are available, so they
    # must be processed early.
    parser = CommandParser(usage='%(prog)s subcommand [options] [args]', add_help=False, allow_abbrev=False)
    parser.add_argument('--settings')
    parser.add_argument('--pythonpath')
    parser.add_argument('args', nargs='*')  # catch-all
    try:
        options, args = parser.parse_known_args(self.argv[2:])
        handle_default_options(options)
    except CommandError:
        pass  # Ignore any option errors at this point.

    try:
        settings.INSTALLED_APPS
    except ImproperlyConfigured as exc:
        self.settings_exception = exc
    except ImportError as exc:
        self.settings_exception = exc

    if settings.configured:
        # Start the auto-reloading dev server even if the code is broken.
        # The hardcoded condition is a code smell but we can't rely on a
        # flag on the command class because we haven't located it yet.
        if subcommand == 'runserver' and '--noreload' not in self.argv:
            try:
                autoreload.check_errors(django.setup)()
            except Exception:
                # The exception will be raised later in the child process
                # started by the autoreloader. Pretend it didn't happen by
                # loading an empty list of applications.
                apps.all_models = defaultdict(OrderedDict)
                apps.app_configs = OrderedDict()
                apps.apps_ready = apps.models_ready = apps.ready = True

                # Remove options not compatible with the built-in runserver
                # (e.g. options for the contrib.staticfiles' runserver).
                # Changes here require manually testing as described in
                # #27522.
                _parser = self.fetch_command('runserver').create_parser('django', 'runserver')
                _options, _args = _parser.parse_known_args(self.argv[2:])
                for _arg in _args:
                    self.argv.remove(_arg)

        # In all other cases, django.setup() is required to succeed.
        else:
            django.setup()

    self.autocomplete()

    if subcommand == 'help':
        if '--commands' in args:
            sys.stdout.write(self.main_help_text(commands_only=True) + '\n')
        elif not options.args:
            sys.stdout.write(self.main_help_text() + '\n')
        else:
            self.fetch_command(options.args[0]).print_help(self.prog_name, options.args[0])
    # Special-cases: We want 'django-admin --version' and
    # 'django-admin --help' to work, for backwards compatibility.
    elif subcommand == 'version' or self.argv[1:] == ['--version']:
        sys.stdout.write(django.get_version() + '\n')
    elif self.argv[1:] in (['--help'], ['-h']):
        sys.stdout.write(self.main_help_text() + '\n')
    else:
        self.fetch_command(subcommand).run_from_argv(self.argv)

```

使用`load_command_class`函数调用系统中的命令字符串实例化为类`import_module`
```Python
def load_command_class(app_name, name):
    """
    Given a command name and an application name, return the Command
    class instance. Allow all errors raised by the import process
    (ImportError, AttributeError) to propagate.
    """
    module = import_module('%s.management.commands.%s' % (app_name, name))
    return module.Command()
```
`BaseCommand`调用`run_from_argv`真正去执行命令

```Python
def run_from_argv(self, argv):
    """
    Set up any environment changes requested (e.g., Python path
    and Django settings), then run this command. If the
    command raises a ``CommandError``, intercept it and print it sensibly
    to stderr. If the ``--traceback`` option is present or the raised
    ``Exception`` is not ``CommandError``, raise it.
    """
    self._called_from_command_line = True
    parser = self.create_parser(argv[0], argv[1])

    options = parser.parse_args(argv[2:])
    cmd_options = vars(options)
    # Move positional args out of options to mimic legacy optparse
    args = cmd_options.pop('args', ())
    handle_default_options(options)
    try:
        self.execute(*args, **cmd_options)
    except Exception as e:
        if options.traceback or not isinstance(e, CommandError):
            raise

        # SystemCheckError takes care of its own formatting.
        if isinstance(e, SystemCheckError):
            self.stderr.write(str(e), lambda x: x)
        else:
            self.stderr.write('%s: %s' % (e.__class__.__name__, e))
        sys.exit(1)
    finally:
```

1.主要处理终端颜色输出方案
2.调用handle函数执行
```Python
def execute(self, *args, **options):
        """
        Try to execute this command, performing system checks if needed (as
        controlled by the ``requires_system_checks`` attribute, except if
        force-skipped).
        """
        if options['force_color'] and options['no_color']:
            raise CommandError("The --no-color and --force-color options can't be used together.")
        if options['force_color']:
            self.style = color_style(force_color=True)
        elif options['no_color']:
            self.style = no_style()
            self.stderr.style_func = None
        if options.get('stdout'):
            self.stdout = OutputWrapper(options['stdout'])
        if options.get('stderr'):
            self.stderr = OutputWrapper(options['stderr'], self.stderr.style_func)

        if self.requires_system_checks and not options.get('skip_checks'):
            self.check()
        if self.requires_migrations_checks:
            self.check_migrations()
        output = self.handle(*args, **options)
        if output:
            if self.output_transaction:
                connection = connections[options.get('database', DEFAULT_DB_ALIAS)]
                output = '%s\n%s\n%s' % (
                    self.style.SQL_KEYWORD(connection.ops.start_transaction_sql()),
                    output,
                    self.style.SQL_KEYWORD(connection.ops.end_transaction_sql()),
                )
            self.stdout.write(output)
        return output
```

test类中的方法主要处理的相关的方法调用testRunner调用测试用例，并且执行测试函数
```Python
def handle(self, *test_labels, **options):
    TestRunner = get_runner(settings, options['testrunner'])

    test_runner = TestRunner(**options)
    failures = test_runner.run_tests(test_labels)

    if failures:
        sys.exit(1)
```
