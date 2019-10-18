TargetPlatform
Semantics
保存Flutter相关的小部件:
  /Users/cuco/flutter/packages/flutter/lib/src/widgets/basic.dart
DrawerController
GestureRecognizer
DragGestureRecognizer
UserAccountsDrawerHeader
FutureBuilder

TickerProvider
Ticker
TickerMode
Completer
Timeline

## Flutter相关插件
https://github.com/flutter/plugins

    android_alarm_manager	pub package
    android_intent	pub package
    battery	pub package
    camera	pub package
    connectivity	pub package
    device_info	pub package
    google_maps_flutter	pub package
    google_sign_in	pub package
    image_picker	pub package
    in_app_purchase	pub package
    local_auth	pub package
    package_info	pub package
    path_provider	pub package
    quick_actions	pub package
    sensors	pub package
    share	pub package
    shared_preferences	pub package
    url_launcher	pub package
    video_player	pub package
    webview_flutter


android {
defaultConfig {
ndk { //设置支持的SO库架构（开发者可以根据需要，选择一个或多个平台的so）
abiFilters "armeabi", "armeabi-v7a", "arm64-v8a", "x86","arm64-v8a","x86_64" }
}
}
dependencies {
compile fileTree(dir: 'libs', include: ['*.jar']) //3D地图so及jar
compile 'com.amap.api:3dmap:latest.integration' //定位功能
compile 'com.amap.api:location:latest.integration' //搜索功能
compile 'com.amap.api:search:latest.integration' }
