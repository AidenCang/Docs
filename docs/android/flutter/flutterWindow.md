# FlutterWidow

## RuntimeController&WindowClient&Window关系

RuntimeController 作为FlutterEngine引擎初始化Dart相关的环境的分析在开一篇来说明，这篇文章还是在说明整个FlutterEngine和FlutterUI和平台之间的一个交互框架，整体的框架理解了之后，我们在来对具体的每一个知识点进行分析，同时修改源代码逻辑。详细的信息已经在FlutterEngine启动过程中进行分析。


## RuntimeController

在前面的文字中，介绍了FlutterEngine初始化过程，FlutterEngine的初始化时，创建了`RuntimeController`做为Engine的代理对象，负责处理FlutterUI层和底层通信的接口，作为FlutterEngine的通信和调度中心
`engine/src/flutter/runtime/runtime_controller.cc`

```c++
Engine::Engine(Delegate& delegate,
               blink::DartVM& vm,
               fml::RefPtr<blink::DartSnapshot> isolate_snapshot,
               fml::RefPtr<blink::DartSnapshot> shared_snapshot,
               blink::TaskRunners task_runners,
               blink::Settings settings,
               std::unique_ptr<Animator> animator,
               fml::WeakPtr<blink::SnapshotDelegate> snapshot_delegate,
               fml::WeakPtr<blink::IOManager> io_manager)
    : delegate_(delegate),
      settings_(std::move(settings)),
      animator_(std::move(animator)),
      activity_running_(false),
      have_surface_(false),
      weak_factory_(this) {
  // Runtime controller is initialized here because it takes a reference to this
  // object as its delegate. The delegate may be called in the constructor and
  // we want to be fully initilazed by that point.
  runtime_controller_ = std::make_unique<blink::RuntimeController>(
      *this,                                 // runtime delegate
      &vm,                                   // VM
      std::move(isolate_snapshot),           // isolate snapshot
      std::move(shared_snapshot),            // shared snapshot
      std::move(task_runners),               // task runners
      std::move(snapshot_delegate),          // snapshot delegate
      std::move(io_manager),                 // io manager
      settings_.advisory_script_uri,         // advisory script uri
      settings_.advisory_script_entrypoint,  // advisory script entrypoint
      settings_.idle_notification_callback   // idle notification callback
  );
}
```


RuntimeController初始化时，作为`flutter/runtime/runtime_delegate.cc`代理对象，同时持有`DartVM`对象，`IOManager`管理上下文对象，最终创建Dart运行的`DartIsolate`对象，isolate是Dart对actor并发模式的实现。运行中的Dart程序由一个或多个actor组成，这些actor也就是Dart概念里面的isolate。isolate是有自己的内存和单线程控制的运行实体。isolate本身的意思是“隔离”，因为isolate之间的内存在逻辑上是隔离的。isolate中的代码是按顺序执行的，任何Dart程序的并发都是运行多个isolate的结果。因为Dart没有共享内存的并发，没有竞争的可能性所以不需要锁，也就不用担心死锁的问题。

![pic](docs/android/flutter/img/flutterisolate.png)

### isolate之间的通信

由于isolate之间没有共享内存，所以他们之间的通信唯一方式只能是通过Port进行，而且Dart中的消息传递总是异步的。

### isolate与普通线程的区别

我们可以看到isolate神似Thread，但实际上两者有本质的区别。操作系统内内的线程之间是可以有共享内存的而isolate没有，这是最为关键的区别。

isolate实现简述
我们可以阅读Dart源码里面的isolate.cc文件看看isolate的具体实现。
我们可以看到在isolate创建的时候有以下几个主要步骤：

初始化isolate数据结构
初始化堆内存(Heap)
进入新创建的isolate，使用跟isolate一对一的线程运行isolate
配置Port
配置消息处理机制(Message Handler)
配置Debugger，如果有必要的话
将isolate注册到全局监控器（Monitor）

### Flutter Engine Runners与Dart Isolate

有朋友看到这里可能会问既然Flutter Engine有自己的Runner，那为何还要Dart的Isolate呢，他们之间又是什么关系呢？

那我们还要从Runner具体的实现说起，Runner是一个抽象概念，我们可以往Runner里面提交任务，任务被Runner放到它所在的线程去执行，这跟iOS GCD的执行队列很像。我们查看iOS Runner的实现实际上里面是一个loop，这个loop就是CFRunloop，在iOS平台上Runner具体实现就是CFRunloop。被提交的任务被放到CFRunloop去执行。

Dart的Isolate是Dart虚拟机自己管理的，Flutter Engine无法直接访问。Root Isolate通过Dart的C++调用能力把UI渲染相关的任务提交到UI Runner执行这样就可以跟Flutter Engine相关模块进行交互，Flutter UI相关的任务也被提交到UI Runner也可以相应的给Isolate一些事件通知，UI Runner同时也处理来自App方面Native Plugin的任务。

所以简单来说Dart isolate跟Flutter Runner是相互独立的，他们通过任务调度机制相互协作。

### RuntimeController初始化

1.创建`DartIsolate`对象
2.获取Window对象
3.加载dart:ui代码到虚拟机中`DidCreateIsolate`
4.初始化FlutterUI层的参数`FlushRuntimeStateToIsolate`

```c++

RuntimeController::RuntimeController(
    RuntimeDelegate& p_client,
    DartVM* p_vm,
    fml::RefPtr<DartSnapshot> p_isolate_snapshot,
    fml::RefPtr<DartSnapshot> p_shared_snapshot,
    TaskRunners p_task_runners,
    fml::WeakPtr<SnapshotDelegate> p_snapshot_delegate,
    fml::WeakPtr<IOManager> p_io_manager,
    std::string p_advisory_script_uri,
    std::string p_advisory_script_entrypoint,
    std::function<void(int64_t)> idle_notification_callback,
    WindowData p_window_data)
    : client_(p_client),
      vm_(p_vm),
      isolate_snapshot_(std::move(p_isolate_snapshot)),
      shared_snapshot_(std::move(p_shared_snapshot)),
      task_runners_(p_task_runners),
      snapshot_delegate_(p_snapshot_delegate),
      io_manager_(p_io_manager),
      advisory_script_uri_(p_advisory_script_uri),
      advisory_script_entrypoint_(p_advisory_script_entrypoint),
      idle_notification_callback_(idle_notification_callback),
      window_data_(std::move(p_window_data)),
      root_isolate_(
          DartIsolate::CreateRootIsolate(vm_,
                                         isolate_snapshot_,
                                         shared_snapshot_,
                                         task_runners_,
                                         std::make_unique<Window>(this),
                                         snapshot_delegate_,
                                         io_manager_,
                                         p_advisory_script_uri,
                                         p_advisory_script_entrypoint)) {
  std::shared_ptr<DartIsolate> root_isolate = root_isolate_.lock();
  root_isolate->SetReturnCodeCallback([this](uint32_t code) {
    root_isolate_return_code_ = {true, code};
  });
  if (auto* window = GetWindowIfAvailable()) {
    tonic::DartState::Scope scope(root_isolate);
    ///ISOlate创建完成
    window->DidCreateIsolate();
    if (!FlushRuntimeStateToIsolate()) {
      FML_DLOG(ERROR) << "Could not setup intial isolate state.";
    }
  } else {
    FML_DCHECK(false) << "RuntimeController created without window binding.";
  }
  FML_DCHECK(Dart_CurrentIsolate() == nullptr);
}
```

这里需要一篇文件继续展开来讲解，我们现在的目的是搞清楚整个逻辑调用过程的主干，在来了解整个`DartIsolate`创建过程

参考:

engine/src/flutter/lib/ui/ui_dart_state.cc
engine/src/flutter/runtime/dart_isolate.cc

## WindowClient

RuntimeController 实现了`WindowClient`对象`engine/src/flutter/lib/ui/window/window.h`,

```c++
class WindowClient {
 public:
  virtual std::string DefaultRouteName() = 0;
  virtual void ScheduleFrame() = 0;
  virtual void Render(Scene* scene) = 0;
  virtual void UpdateSemantics(SemanticsUpdate* update) = 0;
  virtual void HandlePlatformMessage(fml::RefPtr<PlatformMessage> message) = 0;
  virtual FontCollection& GetFontCollection() = 0;
  virtual void UpdateIsolateDescription(const std::string isolate_name,
                                        int64_t isolate_port) = 0;

 protected:
  virtual ~WindowClient();
};
```

### Window::RegisterNatives

flutterUI层的ui.window.dart和FlutterEngine层的Window.cc建立管理关系，通过`RuntimeController`和
```c++
void Window::RegisterNatives(tonic::DartLibraryNatives* natives) {
  natives->Register({
      {"Window_defaultRouteName", DefaultRouteName, 1, true},
      {"Window_scheduleFrame", ScheduleFrame, 1, true},
      {"Window_sendPlatformMessage", _SendPlatformMessage, 4, true},
      {"Window_respondToPlatformMessage", _RespondToPlatformMessage, 3, true},
      {"Window_render", Render, 2, true},
      {"Window_updateSemantics", UpdateSemantics, 2, true},
      {"Window_setIsolateDebugName", SetIsolateDebugName, 2, true},
      {"Window_reportUnhandledException", ReportUnhandledException, 2, true},
  });
}
```


### Android端是怎么把SurfaceView注册到FlutterEngine中的

Android端在初始化是自定义SurfaceView作为汇总Flutter的View，在加载libflutter.so库是添加到FlutterEngine中，具体调用步骤参考下面的代码
engine/src/flutter/shell/platform/android/library_loader.cc

1.JNI_OnLoad注册本地方法

2.PlatformViewAndroid::Register(env);注册本地方法

3.SurfaceCreated通过本地方法调用和AndroidNative层的View进行关联

4.PlatformViewAndroid中中进行引用

```C++
// This is called by the VM when the shared library is first loaded.
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  // Initialize the Java VM.
  fml::jni::InitJavaVM(vm);

  JNIEnv* env = fml::jni::AttachCurrentThread();
  bool result = false;

  // Register FlutterMain.
  result = shell::FlutterMain::Register(env);
  FML_CHECK(result);

  // Register PlatformView
  result = shell::PlatformViewAndroid::Register(env);
  FML_CHECK(result);

  // Register VSyncWaiter.
  result = shell::VsyncWaiterAndroid::Register(env);
  FML_CHECK(result);

  return JNI_VERSION_1_4;
}

```

### AndroidNativeWindow

```c++
static void SurfaceCreated(JNIEnv* env,
                           jobject jcaller,
                           jlong shell_holder,
                           jobject jsurface) {
  // Note: This frame ensures that any local references used by
  // ANativeWindow_fromSurface are released immediately. This is needed as a
  // workaround for https://code.google.com/p/android/issues/detail?id=68174
  fml::jni::ScopedJavaLocalFrame scoped_local_reference_frame(env);
  auto window = fml::MakeRefCounted<AndroidNativeWindow>(
      ANativeWindow_fromSurface(env, jsurface));
  ANDROID_SHELL_HOLDER->GetPlatformView()->NotifyCreated(std::move(window));
}
```
### PlatformViewAndroid
```c++
void PlatformViewAndroid::NotifyCreated(
    fml::RefPtr<AndroidNativeWindow> native_window) {
  if (android_surface_) {
    InstallFirstFrameCallback();
    android_surface_->SetNativeWindow(native_window);
  }
  PlatformView::NotifyCreated();
}
```
### AndroidSurfaceSoftware
```c++
bool AndroidSurfaceSoftware::SetNativeWindow(
    fml::RefPtr<AndroidNativeWindow> window) {
  native_window_ = std::move(window);
  if (!(native_window_ && native_window_->IsValid()))
    return false;
  int32_t window_format = ANativeWindow_getFormat(native_window_->handle());
  if (window_format < 0)
    return false;
  if (!GetSkColorType(window_format, &target_color_type_, &target_alpha_type_))
    return false;
  return true;
}
```


## Window:render 方法
在上一篇中分析了FlutterUI的初始化过程，FlutterUI初始化完成之后，就把构建好的Scene传递到FlutterEngine层进行渲染,调用ui.window的本地方法，`  void render(Scene scene) native 'Window_render';`上一个部分在FlutterEngine中注册的本地方法，
```Dart
/// Uploads the composited layer tree to the engine.
///
/// Actually causes the output of the rendering pipeline to appear on screen.
void compositeFrame() {
  Timeline.startSync('Compositing', arguments: timelineWhitelistArguments);
  try {
    final ui.SceneBuilder builder = ui.SceneBuilder();
    final ui.Scene scene = layer.buildScene(builder);
    if (automaticSystemUiAdjustment)
      _updateSystemChrome();
    _window.render(scene);
    scene.dispose();
    assert(() {
      if (debugRepaintRainbowEnabled || debugRepaintTextRainbowEnabled)
        debugCurrentRepaintColor = debugCurrentRepaintColor.withHue((debugCurrentRepaintColor.hue + 2.0) % 360.0);
      return true;
    }());
  } finally {
    Timeline.finishSync();
  }
}
```

### Window:render

engine/src/flutter/lib/ui/window/window.cc中把数据传递个sky引擎进行渲染

```C++
void Render(Dart_NativeArguments args) {
  Dart_Handle exception = nullptr;
  Scene* scene =
      tonic::DartConverter<Scene*>::FromArguments(args, 1, exception);
  if (exception) {
    Dart_ThrowException(exception);
    return;
  }
  UIDartState::Current()->window()->client()->Render(scene);
}

```

### RuntimeController::Render
在Engine代理对象RuntimeController::Render方法中，获取Scene的Layer数据，并且调用Engine:render方法，进入FlutterEngine核心处理逻辑中

```C++
void RuntimeController::Render(Scene* scene) {
  client_.Render(scene->takeLayerTree());
}
```

### Engine::Render

```C++
void Engine::Render(std::unique_ptr<flow::LayerTree> layer_tree) {
  if (!layer_tree)
    return;

  SkISize frame_size = SkISize::Make(viewport_metrics_.physical_width,
                                     viewport_metrics_.physical_height);
  if (frame_size.isEmpty())
    return;

  layer_tree->set_frame_size(frame_size);
  animator_->Render(std::move(layer_tree));
}
```

### Animator::Render

```C++
void Animator::Render(std::unique_ptr<flow::LayerTree> layer_tree) {
  if (dimension_change_pending_ &&
      layer_tree->frame_size() != last_layer_tree_size_) {
    dimension_change_pending_ = false;
  }
  last_layer_tree_size_ = layer_tree->frame_size();

  if (layer_tree) {
    // Note the frame time for instrumentation.
    layer_tree->set_construction_time(fml::TimePoint::Now() -
                                      last_begin_frame_time_);
  }

  // Commit the pending continuation.
  producer_continuation_.Complete(std::move(layer_tree));

  delegate_.OnAnimatorDraw(layer_tree_pipeline_);
}
```

### Shell::OnAnimatorDraw

```C++
// |shell::Animator::Delegate|
void Shell::OnAnimatorDraw(
    fml::RefPtr<flutter::Pipeline<flow::LayerTree>> pipeline) {
  FML_DCHECK(is_setup_);

  task_runners_.GetGPUTaskRunner()->PostTask(
      [rasterizer = rasterizer_->GetWeakPtr(),
       pipeline = std::move(pipeline)]() {
        if (rasterizer) {
          rasterizer->Draw(pipeline);
        }
      });
}

```

### Rasterizer::Draw

```c++
void Rasterizer::Draw(
    fml::RefPtr<flutter::Pipeline<flow::LayerTree>> pipeline) {
  TRACE_EVENT0("flutter", "GPURasterizer::Draw");

  flutter::Pipeline<flow::LayerTree>::Consumer consumer =
      std::bind(&Rasterizer::DoDraw, this, std::placeholders::_1);

  // Consume as many pipeline items as possible. But yield the event loop
  // between successive tries.
  switch (pipeline->Consume(consumer)) {
    case flutter::PipelineConsumeResult::MoreAvailable: {
      task_runners_.GetGPUTaskRunner()->PostTask(
          [weak_this = weak_factory_.GetWeakPtr(), pipeline]() {
            if (weak_this) {
              weak_this->Draw(pipeline);
            }
          });
      break;
    }
    default:
      break;
  }
}
```

### ui.Window.dart

`void scheduleFrame() native 'Window_scheduleFrame';`调用通知FlutterEngine已经准备好了一帧，可以渲染到Android提供的SurfaceView上

`engine/src/flutter/lib/ui/window/window.cc`作为FlutterEngine的接口调用,整个调用过程很简单，中间省掉了部分调用过程，可以从window.cc开始追踪调用过程

### Animator::RequestFrame

```c++
void Animator::RequestFrame(bool regenerate_layer_tree) {
  if (regenerate_layer_tree) {
    regenerate_layer_tree_ = true;
  }
  if (paused_ && !dimension_change_pending_) {
    return;
  }

  if (!pending_frame_semaphore_.TryWait()) {
    // Multiple calls to Animator::RequestFrame will still result in a
    // single request to the VsyncWaiter.
    return;
  }

  // The AwaitVSync is going to call us back at the next VSync. However, we want
  // to be reasonably certain that the UI thread is not in the middle of a
  // particularly expensive callout. We post the AwaitVSync to run right after
  // an idle. This does NOT provide a guarantee that the UI thread has not
  // started an expensive operation right after posting this message however.
  // To support that, we need edge triggered wakes on VSync.

  task_runners_.GetUITaskRunner()->PostTask([self = weak_factory_.GetWeakPtr(),
                                             frame_number = frame_number_]() {
    if (!self.get()) {
      return;
    }
    TRACE_EVENT_ASYNC_BEGIN0("flutter", "Frame Request Pending", frame_number);
    self->AwaitVSync();
  });
  frame_scheduled_ = true;
}
```
### Rasterizer::DrawToSurface

在这里正在的合成一帧，张上一个步骤中已经把相关的数据传递到AndroidNative层

```c++
bool Rasterizer::DrawToSurface(flow::LayerTree& layer_tree) {
  FML_DCHECK(surface_);

  auto frame = surface_->AcquireFrame(layer_tree.frame_size());

  if (frame == nullptr) {
    return false;
  }

  // There is no way for the compositor to know how long the layer tree
  // construction took. Fortunately, the layer tree does. Grab that time
  // for instrumentation.
  compositor_context_->engine_time().SetLapTime(layer_tree.construction_time());

  auto* canvas = frame->SkiaCanvas();

  auto* external_view_embedder = surface_->GetExternalViewEmbedder();

  if (external_view_embedder != nullptr) {
    external_view_embedder->BeginFrame(layer_tree.frame_size());
  }

  auto compositor_frame = compositor_context_->AcquireFrame(
      surface_->GetContext(), canvas, external_view_embedder,
      surface_->GetRootTransformation(), true);

  if (compositor_frame && compositor_frame->Raster(layer_tree, false)) {
    frame->Submit();
    if (external_view_embedder != nullptr) {
      external_view_embedder->SubmitFrame(surface_->GetContext());
    }
    FireNextFrameCallbackIfPresent();

    if (surface_->GetContext())
      surface_->GetContext()->performDeferredCleanup(kSkiaCleanupExpiration);

    return true;
  }

  return false;
}
```
