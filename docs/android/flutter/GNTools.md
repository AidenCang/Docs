# Flutter Engine 编译使用 GN Tools

## 介绍

gn 是一款构建系统，用于编译大规模代码生成ninja文件

!!! info "优点"

    * 1.可读性好
    * 2.速度更快
    * 3.修改gn 之后 构建ninja文件时候会自动更新
    * 4.依赖分明


经过几天的摸索发现这种构建系统非常有层次性，通常每个模块可以单独写一个gn文件，但是一般采用层级结构
文件根目录下通常有一个BUILD.gn文件，该文件是所有的代码模块组装的集合

.gni 文件：一般用来添加一些参数的配置，在gn文件中import这些文件或者里面定义的变量参数值

本文描述了许多GN的语法细节和行为。

1.1 使用内置的帮助！
GN具有广泛的内置帮助系统，为每个函数和内置变量提供参考。 这个页面更高级。

    GN help

您还可以阅读2016年3月的GN介绍的幻灯片。演讲者备注包含完整内容。

1.2 设计理念

编写构建文件不应该有太多的创造性的工作。理想情况下，给定相同的要求，两个人应该生成相同的构建文件。

除非确实需要，否则不应有灵活性。因为许多事情应该尽可能作为致命错误。

定义应该更像代码而不是规则。我不想写或调试Prolog。但是我们团队中的每个人都可以编写和调试C ++和Python。
应该考虑构建语言应该如何工作。它没必要去容易甚至是可能表达抽象事物。

我们应该通过改变源码或工具来使构建更加简单，而不是使构建加以复杂来满足外部需求（在合理的范围内）。
像Blaze，它什么时候是有意义的（见下文“与Blaze的区别和相似之处”）。



## 如何使用

重要参数讲解

group ：一个拥有命名的目标集合，这个集合包含很多的依赖模块
可配置项：

1.依赖的模块 data_deps,deps,public_deps

2. 配置参数 ：all_dependent_configs,public_configs

3. 根目录的gn文件就是一个个的group组成，根据不同的条件添加或者减少模块依赖，所有在根目录的子目录中创建的模块想发挥作用需要在这个文件中进行添加依赖

config ：定义一个配置对象
通俗的解释，config就是构造一个模板，这个模板有各种各样的属性

source_set :需要被编译的资源的一个集合，被编译但是不产生任何的库

static_library :生成静态库目标

target : 指定目标的类型并生成该目标

template: 定义一个函数名字，这个名字类似于一个函数

component ： 定义一个组件相当于使用gn的component模板替代了静态库、动态库或者sourceset，当允许使用这个（编译参数 is_component_build 为true的时候），模板会生成一个动态库，不允许的话会生成一个动态库，这个很复杂，详情键component官方详解

define :定义字符串，被传递给编译器，功能类似于# defines

include_dirs ：添加额外路径文件

inputs ： 添加当前编译目标在编译的时候需要的target

ldflags ：传递给链接器的标志 ，现在大部分可以用libs和lib_dirs替代使用

lib_dirs :额外的库路径列表

## 语法

GN使用了一个非常简单的动态类型语言。的类型是：

  * 布尔（true，false）。
  * 64位有符号整数。
  * 字符串。
  * 列表（任何其它类型）。
  * 作用域（有点像字典，只是内置的东西）。

有一些内置的变量，其值取决于当前的环境。参见gn help更多。
GN中有许多故意的遗漏。例如没有用户定义的函数调用（模板是最接近的了）。 根据上述设计理念，如果你需要这种东西，已经不符合其设计理念了。
变量sources有一个特殊的规则：当分配给它时，排除模式的列表会应用于它。 这是为了自动过滤掉一些类型的文件。 有关更多信息，请参阅gn help set_sources_assignment_filter和gn help label_pattern。
书呆子似的GN的完整语法在gn help grammar中提供。

### 2.1 字符串

字符串用双引号和反斜线使用作为转义字符。唯一支持的转义序列是：

  * \” （字符引用）
  * $ （字符美元符号）
  * \ （字符反斜杠）

反斜杠的任何其他用法被视为字符反斜杠。 因此，例如在模式中使用的\b不需要转义，Windows路径，如“C\foo\bar.h”也不需要转义。
通过支持简单的变量替换，其中美元符号后面的字替换为变量的值。如果没有非variable−name字符以终止变量名，可以使用选择性地包围名称。不支持更复杂的表达式，只支持变量名称替换。
```shell
a=“mypath”b=“a/foo.cc” # b -> “mypath/foo.cc”
c = “foo{a}bar.cc”  # c -> “foomypathbar.cc”

```
你可以使用“0xFF”语法编码8位字符，所以带有换行符（十六进制0A）的字符串如下：`“look0x0Alike0x0Athis”。

### 2.2 清单

我们是没有办法得到列表的长度的。 如果你发现自己想做这样的事情，那是你在构建中做了太多的工作。
列表支持附加：

```shell
a = [ "first" ]
a += [ "second" ]  # [ "first", "second" ]
a += [ "third", "fourth" ]  # [ "first", "second", "third", "fourth" ]
b = a + [ "fifth" ]  # [ "first", "second", "third", "fourth", "fifth" ]
```

将列表附加到另一个列表将项目附加在第二个列表中，而不是将列表附加为嵌套成员。
您可以从列表中删除项目：

```shell
a = [ "first", "second", "third", "first" ]
b = a - [ "first" ]  # [ "second", "third" ]
a -= [ "second" ]  # [ "first", "third", "fourth" ]
```

列表中的 - 运算符搜索匹配项并删除所有匹配的项。 从另一个列表中减去列表将删除第二个列表中的每个项目。
如果没有找到匹配的项目，将抛出一个错误，因此您需要提前知道该项目在那里，然后再删除它。 假定没有办法测试是否包含，主要用例是设置文件或标志的主列表，并根据各种条件删除不适用于当前构建的主列表。

在文体风格上，只喜欢添加到列表，并让每个源文件或依赖项出现一次。 这与Flutter Engine团队为GYP提供的建议（GYP更愿意列出所有文件，然后删除在条件语中不需要的文件）相反。
列表支持基于零的下标来提取值：

```shell
a = [ "first", "second", "third" ]
b = a[1]  # -> "second"
```

[]运算符是只读的，不能用于改变列表。 主要用例是当外部脚本返回几个已知值，并且要提取它们时。
在某些情况下，当你想要附加到列表时，很容易覆盖列表。 为了帮助捕获这种情况，将非空列表赋给包含非空列表的变量是一个错误。如果要解决此限制，请先将空列表赋给目标变量。如下：
a = [ “one” ]
a = [ “two” ] # Error: overwriting nonempty list with a nonempty list.
a = [] # OK
a = [ “two” ] # OK
注意，构建脚本执行时并不理解潜在数据的含义。这意味着它并不知道sources是一个文件名的列表。例如，如果你想删除其中一项，它必须字符串完全匹配，而不是指定一个不带后缀的名称，它并不会解析为相同的文件名。

### 2.3 条件语句

条件表达式看起来像C：

```shell
if (is_linux || (is_win && target_cpu == "x86")) {
  sources -= [ "something.cc" ]
} else if (...) {
  ...
} else {
  ...
}
```

如果目标只应在某些情况下声明，你就可以使用条件语句，甚至是整个目标。

### 2.4 循环

你可以用foreach遍历一个列表。 但不鼓励这样做。构建做的大多数事情应该都可以表达，而不是循环，如果你发现有必要使用循环，这可能说明你在构建中做了一些无用的工作。

```shell
foreach(i, mylist) {
  print(i)  # Note: i is a copy of each element, not a reference to it.
}
```

### 2.5 函数调用

简单的函数调用看起来像大多数其他的语言：
print(“hello, world”)
assert(is_win, “This should only be executed on Windows”)
这些功能是内置的，用户不能定义新的功能。
一些函数接受一个由{}括起来的代码块：

```shel
static_library("mylibrary") {
  sources = [ "a.cc" ]
}
```

其中大多数定义目标。 用户可以使用下面讨论的模板机制来定义这样的functions。
确切地说，这个表达式意味着该块变成用于函数执行的函数的参数。 大多数块风格函数执行块并将结果作为要读取的变量的字典。

### 2.6 作用域和执行

文件和函数调用后跟{}块将引入新作用域。 作用域是嵌套的。 当你读取变量时，将以相反的顺序搜索包含的作用域，直到找到匹配的名称。 变量写入始终位于最内层。
没有办法修改除最内层之外的任何封闭作用域。 这意味着，当你定义一个目标，例如，你在块里面做的什么都不会“泄漏”到文件的其余部分。
if/else/foreach语句，即使他们使用{}，不会引入一个新的作用域，所以更改会影响到语句之外。

## 命名

### 3.1文件和目录名
文件和目录名称是字符串，并且被解释为相对于当前构建文件的目录。 有三种可能的形式：
相对名称：

```shell
“foo.cc”
“SRC/foo.cc”
“../src/foo.cc”
```

Source-tree绝对名称：

```shell
“//net/foo.cc”
“//base/test/foo.cc”
```

系统绝对名称（很少，通常用于包含目录）：

```shell
"/usr/local/include/"
"/C:/Program Files/Windows Kits/Include"
```

### 3.2 标识

标识是有着预定义格式的字符串，依赖图中所有的元素（目标，配置和工具链）都由标识唯一识别。通常情况下，标识看去是以下样子。

“//base/test:test_support”
!!! info ""它由三部分组成"

    * source-tree绝对路径
    * 冒号
    * 名称

上面这个标识指示到/base/test/BUILD.gn中查找名称是“test_support”的标识。

当加载构建文件时，如果在相对于source root给定的路径不存在时，GN将查找build/secondary中的辅助树。该树的镜像结构主存储库是一种从其它存储库添加构建文件的方式（那些我们无法简单地合入BUILD文件） 辅助树只是备用而不是覆盖，因此正常位置中的文件始终优先。
完整的标识还包括处理该标识要使用的工具链。工具链通常是以继承的方式被默认指定，当然你也可以显示指定。

“//base/test:test_support(//build/toolchain/win:msvc)”

上面这个标识会去“//build/toolchain/win”文件查到名叫”msvc”的工具链定义，那个定义会知道如何处理“test_support”这个标识。
如果你指向的标识就在此个build文件，你可以省略路径，而只是从冒号开始。

“:base”

你可以以相对于当前目录的方式指定路径。标准上说，要引用非本文件中标识时，除了它要在不同上下文运行，我们建议使用绝对路径。什么是要在不同上下文运行？举个列子，一个项目它既要能构造独立版本，又可能是其它项目的子模块。

“source/plugin:myplugin” # Prefer not to do these.

“../net:url_request”

书写时，可以省略标识的第二部分、第三部分，即冒号和名称，这时名称默认使用目录的最后一段。标准上说，在这种情况建议省略第二、三部分。（以下的“=”表示等同）

“//net” = “//net:net”
“//tools/gn” = “//tools/gn:gn”

## 构建配置

### 4.1 总体构建流程

在当前目录查找.gn文件，如果不存在则向上一级目录查找直到找到一个。将这个目录设为”souce root”, 解析该目录下的gn文件以获取build confing文件名称。
执行build config文件（这是一个默认工具链），在chromium中是//build/config/BUILDCONFIG.gn;
加载root目录下的BUILD.gn文件;
根据root目录下的BUILD.gn内容加载其依赖的其它目录下的BUILD.gn文件，如果在指定位置找不到一个gn文件，GN将查找 build/secondary 的相应位置；
当一个目标的依赖都解决了，编译出.ninja文件保存到out_dir/dir，例如./out/arm/obj/ui/web_dialogs/web_dialogs.ninja;
当所有的目标都解决了， 编译出一个根 build.ninja 文件存放在out_dir根目录下。

### 4.2 构建配置文件

第一个要执行的是构建配置文件，它在指示源码库根目录的“.gn”文件中指定。Flutter Engine源码树中该文件是“//build/config/BUILDCONFIG.gn”。整个系统有且只有一个构造配置文件。
除设置其它build文件执行时的工作域外，该文件还设置参数、变量、默认值，等等。设置在该文件的值对所有build文件可见。
每个工具链会执行一次该文件（见“工具链”）。

### 4.3 构建参数

参数可以从命令行（和其他工具链，参见下面的“工具链”）传入。 你可以通过declare_args声明接受哪些参数和指定默认值。
有关参数是如何工作的，请参阅gn help buildargs。 有关声明它们的细节，请参阅gn help declare_args。
在给定作用域内多次声明给定的参数是一个错误。 通常，参数将在导入文件中声明（在构建的某些子集之间共享它们）或在主构建配置文件中（使它们是全局的）。

### 4.4 默认目标

您可以为给定的目标类型设置一些默认值。 这通常在构建配置文件中完成，以设置一个默认配置列表，它定义每个目标类型的构建标志和其他设置信息。
请参阅gn help set_defaults。
例如，当您声明static_library时，将应用静态库的目标默认值。 这些值可以由目标覆盖，修改或保留。

```shell
#This call is typically in the build config file (see above).
set_defaults("static_library") {
  configs = [ "//build:rtti_setup", "//build:extra_warnings" ]
}

# This would be in your directory's BUILD.gn file.
static_library("mylib") {
  # At this point configs is set to [ "//build:rtti_setup", "//build:extra_warnings" ]
  # by default but may be modified.
  configs -= "//build:extra_warnings"  # Don't want these warnings.
  configs += ":mylib_config"  # Add some more configs.
}
```

用于设置目标默认值的其他用例是，当您通过模板定义自己的目标类型并想要指定某些默认值。

## 目标

目标是构造表中的一个节点，通常用于表示某个要产生的可执行或库文件。目标经常会依赖其它目标，以下是内置的目标类型（参考gn help ）：

!!! info "gn help"

    * action：运行一个脚本来生成一个文件。
    * action_foreach：循环运行脚本依次产生文件。
    * bundle_data：产生要加入Mac/iOS包的数据。
    * create_bundle：产生Mac/iOS包。
    * executable：生成一个可执行文件。
    * group：包含一个或多个目标的虚拟节点（目标）。
    * shared_library：一个.dll或的.so。
    * loadable_module：一个只用于运行时的.dll或.so。
    * source_set：一个轻量的虚拟静态库（通常指向一个真实静态库）。
    * static_library：一个的.lib或某文件（正常情况下你会想要一个source_set代替）。
    * 你可以用模板（templates）来扩展可使用的目标。Flutter Engine就定义了以下类型。
    * component：基于构造类型，或是源文件集合或是共享库。
    * test：可执行测试。在移动平台，它用于创建测试原生app。
    * app：可执行程序或Mac/iOS应用。
    * android_apk：生成一个APK。有许多Android应用，参考//build/config/android/rules.gni。

## CONFIGS

配置是指定标志集，包含目录和定义的命名对象。 它们可以应用于目标并推送到依赖目标。

```shell
config("myconfig") {
  includes = [ "src/include" ]
  defines = [ "ENABLE_DOOM_MELON" ]
}
```

将配置应用于目标：

```shell
executable("doom_melon") {
  configs = [ ":myconfig" ]
}

```
build config文件通常指定设置默认配置列表的目标默认值。 根据需要，目标可以添加或删除到此列表。 所以在实践中，你通常使用configs + =“：myconfig”附加到默认列表。
有关如何声明和应用配置的更多信息，请参阅gn help config。
公共CONFIGS
目标可以将设置应用于依赖它的目标。 最常见的例子是第三方目标，它需要一些定义或包含目录来使其头文件正确include。 希望这些设置适用于第三方库本身，以及使用该库的所有目标。
为此，我们需要为要应用的设置编写config：

```shell
config("my_external_library_config") {
  includes = "."
  defines = [ "DISABLE_JANK" ]
}
```

然后将这个配置被添加到public_configs。 它将应用于该目标以及直接依赖该目标的目标。

```shell
shared_library("my_external_library") {
  ...
  # Targets that depend on this get this config applied.
  public_configs = [ ":my_external_library_config" ]
}
```

依赖目标可以通过将你的目标作为“公共”依赖来将该依赖树转发到另一个级别。

```shell

static_library("intermediate_library") {
  ...
  # Targets that depend on this one also get the configs from "my external library".
  public_deps = [ ":my_external_library" ]
}
```

目标可以将配置转发到所有依赖项，直到达到链接边界，将其设置为all_dependent_config。 但建议不要这样做，因为它可以喷涂标志和定义超过必要的更多的构建。 相反，使用public_deps控制哪些标志适用于哪里。
在Flutter Engine中，更喜欢使用构建标志头系统（build/buildflag_header.gni）来防止编译器定义导致的大多数编译错误。

## 工具链

Toolchains 是一组构建命令来运行不同类型的输入文件和链接的任务。
可以设置有多个 Toolchains 的 build。 不过最简单的方法是每个 toolchains 分开 build同时在他们之间加上依赖关系。 这意味着,例如,32 位 Windows 建立可能取决于一个 64 位助手的 target。 他们每个可以依赖“//base:base”将 32 位基础背景下的 32 位工具链,和 64 位背景下的 64 位工具链。
当 target 指定依赖于另一个 target,当前的 toolchains 是继承的,除非它是明确覆盖(请参见上面的“Labels”)。

### 7.1 工具链和构建配置

当你有一个简单的版本只有一个 toolchain，build config 文件是在构建之初只加载一次。它必须调用 set_default_toolchain 告诉 GN toolchain 定义的 label 标签。 此 toolchain 定义了需要用的编译器和连接器的命令。 toolchain 定义的 toolchain_args 被忽略。当 target 对使用不同的 toolchain target 的依赖， GN 将使用辅助工具链来解决目标开始构建。 GN 将加载与工具链定义中指定的参数生成配置文件。 由于工具链已经知道， 调用 set_default_toolchain 将被忽略。所以 oolchain configuration 结构是双向的。 在默认的 toolchain（即主要的构建 target）的配置从构建配置文件的工具链流向： 构建配置文件着眼于构建（操作系统类型， CPU 架构等）的状态， 并决定使用哪些 toolchain（通过 set_default_toolchin）。 在二次 toolchain，配置从 toolchain 流向构建配置文件：在 toolchain 定义 toolchain_args 指定的参数重新调用构建。

### 7.2 工具链例子

假设默认的构建是一个 64 位版本。 无论这是根据当前系统默认的 CPU 架构， 或者用户在命令行上传递 target_cpu=“64”。 build config file 应该像这样设置默认的工具链：

```shell

# Set default toolchain only has an effect when run in the context of
# the default toolchain. Pick the right one according to the current CPU
# architecture.
if (target_cpu == "x64") {
  set_default_toolchain("//toolchains:64")
} else if (target_cpu == "x86") {
  set_default_toolchain("//toolchains:32")
}
```

如果一个 64 位的 target 要依靠一个 32 位二进制数， 它会使用 data_deps 指定的依赖关系（data_deps 依赖库在运行时才需要链接时不需要， 因为你不能直接链接 32 位和 64位的库）。

```shell
executable("my_program") {
  ...
  if (target_cpu == "x64") {
    # The 64-bit build needs this 32-bit helper.
    data_deps = [ ":helper(//toolchains:32)" ]
  }
}

if (target_cpu == "x86") {
  # Our helper library is only compiled in 32-bits.
  shared_library("helper") {
    ...
  }
}

上述（引用的工具链文件toolchains/BUILD.gn）将定义两个工具链：

toolchain("32") {
  tool("cc") {
    ...
  }
  ... more tools ...

  # Arguments to the build when re-invoking as a secondary toolchain.
  toolchain_args = {
    current_cpu = "x86"
  }
}

toolchain("64") {
  tool("cc") {
    ...
  }
  ... more tools ...

  # Arguments to the build when re-invoking as a secondary toolchain.
  toolchain_args = {
    current_cpu = "x64"
  }

```

工具链args明确指定CPU体系结构，因此如果目标依赖于使用该工具链的东西，那么在重新调用该生成时，将设置该cpu体系结构。 这些参数被忽略为默认工具链，因为当他们知道的时候，构建配置已经运行。 通常，工具链args和用于设置默认工具链的条件应该一致。
有关多版本设置的好处是， 你可以写你的目标条件语句来引用当前 toolchain 的状态。构建文件将根据每个 toolchain 不同的状态重新运行。 对于上面的例子 my_program， 你可以看到它查询 CPU 架构， 加入了只依赖该程序的 64 位版本。 32 位版本便不会得到这种依赖性。

### 7.3 声明工具链

工具链均使用 toolchain 的命令声明， 它的命令用于每个编译和链接操作。 该toolchain 在执行时还指定一组参数传递到 build config 文件。 这使您可以配置信息传递给备用 toolchain。

## 模板

模板是 GN 重复使用代码的主要方式。 通常， 模板会扩展到一个或多个其他目标类型。

```shell
# Declares a script that compiles IDL files to source, and then compiles those
# source files.
template("idl") {
  # Always base helper targets on target_name so they're unique. Target name
  # will be the string passed as the name when the template is invoked.
  idl_target_name = "${target_name}_generate"
  action_foreach(idl_target_name) {
    ...
  }

  # Your template should always define a target with the name target_name.
  # When other targets depend on your template invocation, this will be the
  # destination of that dependency.
  source_set(target_name) {
    ...
    deps = [ ":$idl_target_name" ]  # Require the sources to be compiled.
  }
}
```

通常情况下你的模板定义在一个.gni 文件中， 用户 import 该文件看到模板的定义：

```shell

import("//tools/idl_compiler.gni")

idl("my_interfaces") {
  sources = [ "a.idl", "b.idl" ]
}
```

声明模板会在当时在范围内的变量周围创建一个闭包。 当调用模板时，魔术变量调用器用于从调用作用域读取变量。 模板通常将其感兴趣的值复制到其自己的范围中：

```shell
template("idl") {
  source_set(target_name) {
    sources = invoker.sources
  }
}
```

模板执行时的当前目录将是调用构建文件的目录，而不是模板源文件。 这是从模板调用器传递的文件将是正确的（这通常说明大多数文件处理模板）。 但是，如果模板本身有文件（也许它生成一个运行脚本的动作），你将需要使用绝对路径（“// foo / …”）来引用这些文件， 当前目录在调用期间将不可预测。 有关更多信息和更完整的示例，请参阅gn帮助模板。

## 其他功能

### 9.1 Imports

您可以 import .gni 文件到当前文件中。 这不是 C++中的 include。 Import 的文件将独立执行并将执行的结果复制到当前文件中（C ++执行的时候， 当遇到 include 指令时才会在当前环境中 include 文件）。 Import 允许导入的结果被缓存， 并且还防止了一些“creative”的用途包括像嵌套 include 文件。通常一个.gni 文件将定义 build 的参数和模板。 命令 gn help import 查看更多信息。.gni 文件可以定义像_this 名字前使用一个下划线的临时变量， 从而它不会被传出文件外。。

### 9.2 路径处理

通常你想使一个文件名或文件列表名相对于不同的目录。 这在运行 scripts 时特别常见的， 当构建输出目录为当前目录执行的时候， 构建文件通常是指相对于包含他们的目录的文件。您可以使用 rebase_path 转化目录。命令 gn help rebase_path 查看纤细信息。

### 9.3 模式

Patterns 被用来在一个部分表示一个或多个标签。

命令： gn help set_sources_assignment_filter
       gn help label_pattern 查看更多信息。

### 9.4 执行脚本

有两种方式来执行脚本。 GN中的所有外部脚本都在Python中。第一种方式是构建步骤。这样的脚本将需要一些输入并生成一些输出作为构建的一部分。调用脚本的目标使用“action”目标类型声明（请参阅gn help action）。
在构建文件执行期间，执行脚本的第二种方式是同步的。在某些情况下，这是必要的，以确定要编译的文件集，或者获取构建文件可能依赖的某些系统配置。构建文件可以读取脚本的stdout并以不同的方式对其执行操作。
同步脚本执行由exec_script函数完成（有关详细信息和示例，请参阅gn help exec_script）。因为同步执行脚本需要暂停当前的buildfile执行，直到Python进程完成执行，所以依赖外部脚本很慢，应该最小化。
为了防止滥用，允许调用exec_script的文件可以在toplevel .gn文件中列入白名单。 Flutter Engine会执行此操作，需要对此类添加进行其他代码审核。请参阅gn help dotfile。
您可以同步读取和写入在同步运行脚本时不鼓励但偶尔需要的文件。典型的用例是传递比当前平台的命令行限制更长的文件名列表。有关如何读取和写入文件，请参阅gn help read_file和gn help write_file。如果可能，应避免这些功能。
超过命令行长度限制的操作可以使用响应文件来解决此限制，而不同步写入文件。请参阅gn help response_file_contents。

## 与Blaze的区别和相似之处

Blaze是Google的内部构建系统，现在作为Bazel公开发布。它启发了许多其他系统，如Pants和buck。
在Google的同类环境中，对条件的需求非常低，他们可以通过一些hacks（abi_deps）来实现。 Flutter Engine在所有地方使用条件，需要添加这些是文件看起来不同的主要原因。
GN还添加了“configs”的概念来管理一些棘手的依赖和配置问题，这些问题同样不会出现在服务器上。 Blaze有一个“配置”的概念，它像GN工具链，但内置到工具本身。工具链在GN中的工作方式是尝试将这个概念以干净的方式分离到构建文件中的结果。
GN保持一些GYP概念像“所有依赖”设置，在Blaze中工作方式有点不同。这部分地使得从现有GYP代码的转换更容易，并且GYP构造通常提供更细粒度的控制（其取决于情况是好还是坏）。
GN也使用像“sources”而不是“srcs”的GYP名称，因为缩写这似乎不必要地模糊，虽然它使用Blaze的“deps”，因为“dependencies”很难键入。 Chromium还在一个目标中编译多种语言，因此指定了目标名称前缀的语言类型（例如从cc_library）。

## 总结

GN构建系统是一个组织源代码的依赖关系，并且能够配置编译不同产物的参数，GN构建系统使用的是一个`顺藤摸瓜`的方式从源码`root`目录的`.gn`文件开发，不断读取相关关联的文件，目的是为下一步的编译构建好，编译文件依赖和相关的参数配置，下一步才是正在的编译工作，`Ninja`工具在构建的时候只会更加`GN`生成的配置文件进行源代码查找编译,下一篇中我们见介绍相关的`Ninja`脚本文件

## 参考资料

[GN官方文档](https://gn.googlesource.com/gn/+/master/docs/quick_start.md#declaring-dependencies)
[源代码仓库](https://gn.googlesource.com/gn/+/master/)
[How GN handles cross-compiling](https://gn.googlesource.com/gn/+/master/docs/cross_compiles.md)
[depot_tools_tutorial](http://dev.chromium.org/developers/how-tos/depottools)
