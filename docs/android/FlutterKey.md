# Flutter中的Key，LocalKey，GlobalKey... And More

## 开始
  从这一篇文章开始，花时间慢慢阅读源码，从web前端角度看Flutter，然后也把一些收获也分享给大家。
React和React Native受到Facebook条款限制，大公司们（主要BAT）都开始若有所思，RN也似乎一下掉下了神坛，同志们，此时此刻正是Flutter当立的时候，大家一起跨进新的时代！

## 各种各样的Key
立马跳到framework.dart文件（这个文件一看名字就很重要啦），Flutter代码的组织并不像Java反而倾向于JS这种组织方式，一个文件里面塞着不同的Class（当然他们之间肯定有联系的），其实个人更倾向于Java那种一个类一个文件，阅读和分析感觉都比较方便舒服。
framework.dart一开始你就会遇到几个名词：Key，LocalKey，UniqueKey等等。
clipboard.png

一下子冒出几个兄弟来，得一个一个分清楚他们的各有什么能力。

## key的作用
首先key有何用尼？
Flutter是受React启发的，所以Virtual Dom的diff算法也参考过来了（应该是略有修改），在diff的过程中如果节点有Key来比较的话，能够最大程度重用已有的节点（特别在列表的场景），除了这一点这个Key也用在很多其他的地方这个以后会总结一下。总之，这里我们可以知道key能够提高性能，所以每个Widget都会构建方法都会有一个key的参数可选，贯穿着整个框架。

## key之间的关系

这里就是Key的类型层级关系，可以看到：
Key有两个重要的子类：LocalKey 和 GlobalKey，而他们各自也有不同的子类实现，接下来会继续深入分析。

## 普通的Key

他们的老大哥Key，这个Key的实现有点特别。

@immutable
abstract class Key {
  /// Construct a [ValueKey<String>] with the given [String].
  ///
  /// This is the simplest way to create keys.
  const factory Key(String value) = ValueKey<String>;

  /// Default constructor, used by subclasses.
  ///
  /// Useful so that subclasses can call us, because the Key() factory
  /// constructor shadows the implicit constructor.
  const Key._();
}
看上去很简单，没有什么特别方法的实现，那为啥特别尼，我个人认为这种特别来自Dart语言的一些特性（其实是Dart语言基础太浅，大神用的太溜）。

const Key._();
首先这里用到命名构造函数（named constructors），大致作用就是给构造函数加多一个有意义的名称，能够让使用者更容易明白各个构造函数的区别（因为类似Java这样，只能靠参数列表来区分确实容易造成混乱）。这里是一个空的实现（并不是Java那一种抽象方法）这里来源一个建议 传送门;

const factory Key(String value) = ValueKey<String>;
这里就是Key默认构造函数（只能有一个默认构造函数，哪怕修改参数列表也不行，之后你只能定义命名构造函数了），但是跟Java又有点不一样啊，首先是factory这个关键字，这是Dart语言内置了对工厂模式的支持（其实大部分语言都可以支持这种模式，这里语言层面上再强化了），而加了这个关键字会怎样？我们知道构建方法返回的一般都是当前类所刚构建的对象，但是加上factory关键字之后你可以修改返回的值，可以让返回的对象是之前已经创建好的，也可以返回这个类的子类对象。
这里还有涉及到一个factory redirect(官网貌似没有介绍，估计新加的语法)传送门
等效于

const factory Key(String value) => new ValueKey<String>(value);
所以这里其实返回了一个ValueKey。

## ValueKey
顺藤摸瓜来到ValueKey，而ValueKey其实就是LocalKey的一个子类，但是LocalKey并没有特别的实现只是简单调用了Key._()构造函数。而ValueKey则是：

class ValueKey<T> extends LocalKey
构造函数需要传入一个value的参数:

const ValueKey(this.value);
ValueKey是一个泛型类，并且覆盖了自身的operator==方法（跟 C++覆盖操作符一样），调用了目标类型T的运算符==来比较，当然覆盖了operator==方法也需要覆盖获取hashCode的方法（道理跟Java一样）。所以ValueKey的比较取决于value的operator==的实现，例如Value是字符串类型那就是内容的比较。

## ObjectKey
构造函数跟ValueKey差不多:

const ObjectKey(this.value);
虽然同样覆盖了自身的operator==方法，但是它调用的是identical()方法，所以比较的是value的引用。

## UniqueKey
也没有特别的实现，没有覆盖operator==方法，所以UniqueKey比较的时候，也就比较引用了（Object默认的operator==调用的就是identical()方法）。

## GlobalKey
abstract class GlobalKey<T extends State<StatefulWidget>> extends Key
也是一个泛型类型，但是T必须要继承自State<StatefulWidget>，可以说这个GlobalKey专门用于组件了。
再看：

static final Map<GlobalKey, Element> _registry = <GlobalKey, Element>{};
GlobalKey里含有一个Map，key和value分别为自身和Element。
那什么时候会用到这个Map尼？
跟踪代码很快就找到Element类的mount方法：

void mount(Element parent, dynamic newSlot) {
    ...
    if (widget.key is GlobalKey) {
      final GlobalKey key = widget.key;
      key._register(this);
    }
   ...
  }
可见GlobalKey会在组件Mount阶段把自身放到一个Map里面缓存起来。
缓存又有何作用尼？
答案依然是为了性能。
思考一个场景，A页面是一个商品列表有许多商品图片（大概就单列这样），B页面是一个商品详情页（有商品大图），当用户在A页面点击一个其中详情，可能会出现一个过渡动画，A页面的商品图片慢慢放大然后下面的介绍文字也会跟着出现，然后就这样平滑的过渡到B页面。
此时A页面和B页面都其实共用了一个商品图片的组件，B页面没必要重复创建这个组件可以直接把A页面的组件“借”过来。
使用GlobalKey的组件生命周期是如何的尼，这里暂时挖一个坑先，哈哈。
总之框架要求同一个父节点下子节点的Key都是唯一的就可以了，GlobalKey可以保证全局是唯一的，所以GlobalKey的组件能够依附在不同的节点上。
而从GlobalKey对象上，你可以得到几个有用的属性currentElement，currentWidget，currentState。

## GlobalObjectKey
GlobalObjectKey跟LocalObjectKey也差不多，不同点就在与它是Global的。

## LabeledGlobalKey
LabeledGlobalKey是用于调试的。

结束
这是第一篇开始深入框架代码的文章，代码阅读还不是很全面，很有可能会有错漏，如有发现，希望能够及时指正。
