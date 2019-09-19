# 自定义控件Widget
控件摆放细节是如何实现的？？？？
widget:
    PreferredSizeWidget:widgets的接口，它可以返回该widget希望的大小如果它是无约束的。有一些情况，特别是[appbar]和[tabbar]，在这里widget不需要限制自己的大小，但是需要公开首选或“默认”大小。例如一个主要的[脚手架]将其app bar高度设置为app bar的首选高度加上系统状态栏的高度。使用[PreferredSize]为任意小部件提供首选大小。
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
