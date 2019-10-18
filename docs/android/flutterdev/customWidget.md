# 自定义控件Widget


initState
didChangeDependencies
build
didUpdateWidget
build

控件摆放细节是如何实现的？？？？

描述了一个[element]的配置。widgets是flutr框架中的中心类层次结构。小部件是用户界面的一部分的不可变描述。小部件可以是已膨胀为元素，用于管理底层呈现树。小部件本身没有可变状态（它们的所有字段都必须是final）。如果希望将可变状态与小部件关联，请考虑使用[statefulwidget]，它创建一个[状态]对象（通过[statefulWidget.createState]）当它被膨胀成一个元素时融入到树中。给定的小部件可以包含在树中零次或多次。特别地：
给定的小部件可以多次放置在树中。每次一个小部件放置在树中，它被膨胀为多次合并到树中的小部件将被膨胀多次。[key]属性控制一个小部件如何替换/树。如果两个小部件的[RuntimeType]和[Key]属性是[operator==]，然后新的小部件替换旧的小部件更新底层元素（即，使用new widget）。否则，将从树中删除旧元素widget被扩展成一个元素，新元素被插入到树。
widget:
    PreferredSizeWidget:widgets的接口，它可以返回该widget希望的大小如果它是无约束的。有一些情况，特别是[appbar]和[tabbar]，在这里widget不需要限制自己的大小，但是需要公开首选或“默认”大小。例如一个主要的[脚手架]将其app bar高度设置为app bar的首选高度加上系统状态栏的高度。使用[PreferredSize]为任意小部件提供首选大小。
      FlexibleSpaceBar
      AppBar
    StatefulWidget:
    ProxyWidget:
    RenderObjectWidget:
      RenderObjectToWidgetAdapter
      Table
      SliverWithKeepAliveWidget
      ConstrainedLayoutBuilder
      ListWheelViewport
      SingleChildRenderObjectWidget
      LeafRenderObjectWidget
      MultiChildRenderObjectWidget
      StatelessWidget

Element:
  RenderObjectElement
    SliverMultiBoxAdaptorElement
    ListWheelElement
    LeafRenderObjectElement
    MultiChildRenderObjectElement
    SingleChildRenderObjectElement
    RootRenderObjectElement
  ComponentElement
    ProxyElement
      InheritedElement
        InheritedModelElement
    StatefulElement
    StatelessElement


RenderObject:
  RenderBox
  RenderView
  RenderAbstractViewport
  RenderSliver
  ContainerRenderObjectMixin
  RenderObjectWithChildMixin

## 处理环境变量
### 平台相关
Platform
system_chrome
