#Flutter

Most of the screenshots in this tutorial are displayed with `debugPaintSizeEnabled` set to true so you can see the visual layout. For more information, see [Visual debugging](https://flutter.dev/docs/testing/debugging#visual-debugging), a section in [Debugging](https://flutter.dev/docs/testing/debugging) Flutter apps.

A child property if they take a single child – for example, Center or Container
A children property if they take a list of widgets – for example, Row, Column, ListView, or Stack.




Meterail UI 是一套已经定制好的UI界面
For a Material app, you can use a `Scaffold` widget; it provides a default banner, background color, and has API for adding drawers, snack bars, and bottom sheets. Then you can add the Center widget directly to the body property for the home page.

By default a non-Material app doesn’t include an AppBar, title, or background color.

App source code:

[Material app](https://github.com/flutter/website/tree/master/examples/layout/non_material)
[Non-Material app](https://github.com/flutter/website/tree/master/examples/layout/base)
