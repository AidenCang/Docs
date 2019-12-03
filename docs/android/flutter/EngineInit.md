# FlutterEngine引擎初始化

在[Android加载Dart文件](../flutterAndroidInit)和[Android初始化View](../AndroidViewinit)两篇代码分析的过程中，已经分析了加载`libflutter.so` 的初始化话过程，`platform_view_android_jni.cc`中调用`AttachJNI`初始化`AndroidShellHolder`对象对平台进行初始化,进行来分析FlutterEngine初始化过程。

!!! info "Flutter Engine初始化过程"

    * 1.`Platfrom,UI,IO,GUP`线程的管理，配置参数的的加载
    * 2.创建一个线程清理虚拟机退出的清理工作
    * 3.`thread_host_`负责管理相关的线程,托管四个相处`TaskRunner`,`TaskRunners`
    * 4.`PlatformViewAndroid`的创建，负责管理平台侧是事件处理在UI线程执行
    * 5.`Rasterizer`的初始化栅格化在GPU线程执行
    * 6.`MessageLoop`的创建，在platfrom中运行
    * 7.`TaskRunners`管理添加到不同平台中的线程执行，负责管理四个任务运行器
    * 8.`Shell`加载第三方库，Java虚拟机的创建

## 加载Flutter资源

### JNI_OnLoad

Flutter.so中Android端的入口函数`engine/src/flutter/shell/platform/android/library_loader.cc`

Java加载Flutter.so库完成时，开始初始化Flutter引擎

1.注册Flutter层的代码

2.初始化AndroidView

3.初始化FlutterMain

在Android端初始化Flutter 相关的环境通过两个步骤来完成：
```C
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
###  FlutterMain::Register(env);

1.转换FlutterJNI中的`nativeInit`函数到JNI`init`函数并且初始化相关的引擎

2.加载`FlutterMain`中的所有native函数


开始初始化Register查找Flutter.jar中的Java方法
```C
bool FlutterMain::Register(JNIEnv* env) {
  static const JNINativeMethod methods[] = {
      {
          .name = "nativeInit",
          .signature = "(Landroid/content/Context;[Ljava/lang/String;Ljava/"
                       "lang/String;Ljava/lang/String;Ljava/lang/String;)V",
          .fnPtr = reinterpret_cast<void*>(&Init),
      },
      {
          .name = "nativeRecordStartTimestamp",
          .signature = "(J)V",
          .fnPtr = reinterpret_cast<void*>(&RecordStartTimestamp),
      },
  };

  jclass clazz = env->FindClass("io/flutter/view/FlutterMain");

  if (clazz == nullptr) {
    return false;
  }

  return env->RegisterNatives(clazz, methods, arraysize(methods)) == 0;
}
```

FlutterMain.cc文件时FlutterEngine和Android平台相关的入口类，主要处理Android相关的资源文件和初始化FlutterMain.cc

1.在调用Register函数时，已经把FlutterJNI中的`nativeInit`映射到FlutterMain中的`nativeInit`,传入Flutter在Android端的相关文件

2.找到Android引擎启动时从Apk包中解压出来的资源文件

3.加载Flutter编译出来的相关文件`kernel_blob`

4.初始化FlutterMain`g_flutter_main.reset(new FlutterMain(std::move(settings)));`


```C
void FlutterMain::Init(JNIEnv* env,
                       jclass clazz,
                       jobject context,
                       jobjectArray jargs,
                       jstring bundlePath,
                       jstring appStoragePath,
                       jstring engineCachesPath) {
  std::vector<std::string> args;
  args.push_back("flutter");
  for (auto& arg : fml::jni::StringArrayToVector(env, jargs)) {
    args.push_back(std::move(arg));
  }
  auto command_line = fml::CommandLineFromIterators(args.begin(), args.end());

  auto settings = SettingsFromCommandLine(command_line);

  settings.assets_path = fml::jni::JavaStringToString(env, bundlePath);

  // Restore the callback cache.
  // TODO(chinmaygarde): Route all cache file access through FML and remove this
  // setter.
  blink::DartCallbackCache::SetCachePath(
      fml::jni::JavaStringToString(env, appStoragePath));

  fml::paths::InitializeAndroidCachesPath(
      fml::jni::JavaStringToString(env, engineCachesPath));

  blink::DartCallbackCache::LoadCacheFromDisk();

  if (!blink::DartVM::IsRunningPrecompiledCode()) {
    // Check to see if the appropriate kernel files are present and configure
    // settings accordingly.
    auto application_kernel_path =
        fml::paths::JoinPaths({settings.assets_path, "kernel_blob.bin"});

    if (fml::IsFile(application_kernel_path)) {
      settings.application_kernel_asset = application_kernel_path;
    }
  }

  settings.task_observer_add = [](intptr_t key, fml::closure callback) {
    fml::MessageLoop::GetCurrent().AddTaskObserver(key, std::move(callback));
  };

  settings.task_observer_remove = [](intptr_t key) {
    fml::MessageLoop::GetCurrent().RemoveTaskObserver(key);
  };

#if FLUTTER_RUNTIME_MODE == FLUTTER_RUNTIME_MODE_DEBUG
  // There are no ownership concerns here as all mappings are owned by the
  // embedder and not the engine.
  auto make_mapping_callback = [](const uint8_t* mapping, size_t size) {
    return [mapping, size]() {
      return std::make_unique<fml::NonOwnedMapping>(mapping, size);
    };
  };

  settings.dart_library_sources_kernel =
      make_mapping_callback(kPlatformStrongDill, kPlatformStrongDillSize);
#endif  // FLUTTER_RUNTIME_MODE == FLUTTER_RUNTIME_MODE_DEBUG

  // Not thread safe. Will be removed when FlutterMain is refactored to no
  // longer be a singleton.
  g_flutter_main.reset(new FlutterMain(std::move(settings)));
}
```

倒目前为止已经加载完成Flutter相关的资源文件，接下来就需要开始初始化View相关的逻辑和Android端通信

在下图中:

  * 1.初始化Flutter Engine 运行FlutterUI库的环境，初始化AndroidShellHolder：来管理Flutter相关的引环境
  * 2.[PlatformViewAndroid](../EngineView)在JNI层进行View的绘制和事件处理,注册SurfaceView给Flutter Eingine，提供给引擎进行绘制的画布，调用ANative_window类来连接FlutterUI和AndroidUI的桥梁

![pic](../../assets/images/android/flutter/fluttersurfaceView.png)

## PlatformViewAndroid

### JNI调用的绑定关系

初始化Android平台相关的View逻辑，绑定Flutter.jar类和Android 绘图引擎的初始化绑定工作，初始化工作主要的内容是在注册相关的Java层的本地方法到JNI层，建立好C++和Java层相互调用函数关系

1.io/flutter/view/FlutterCallbackInformation

2.io/flutter/embedding/engine/FlutterJNI

3.android/graphics/SurfaceTexture

4.attachToGLContext

5.updateTexImage

6.getTransformMatrix

7.detachFromGLContext


```C
bool PlatformViewAndroid::Register(JNIEnv* env) {
  if (env == nullptr) {
    FML_LOG(ERROR) << "No JNIEnv provided";
    return false;
  }

  g_flutter_callback_info_class = new fml::jni::ScopedJavaGlobalRef<jclass>(
      env, env->FindClass("io/flutter/view/FlutterCallbackInformation"));
  if (g_flutter_callback_info_class->is_null()) {
    FML_LOG(ERROR) << "Could not locate FlutterCallbackInformation class";
    return false;
  }

  g_flutter_callback_info_constructor = env->GetMethodID(
      g_flutter_callback_info_class->obj(), "<init>",
      "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
  if (g_flutter_callback_info_constructor == nullptr) {
    FML_LOG(ERROR) << "Could not locate FlutterCallbackInformation constructor";
    return false;
  }

  g_flutter_jni_class = new fml::jni::ScopedJavaGlobalRef<jclass>(
      env, env->FindClass("io/flutter/embedding/engine/FlutterJNI"));
  if (g_flutter_jni_class->is_null()) {
    FML_LOG(ERROR) << "Failed to find FlutterJNI Class.";
    return false;
  }

  g_surface_texture_class = new fml::jni::ScopedJavaGlobalRef<jclass>(
      env, env->FindClass("android/graphics/SurfaceTexture"));
  if (g_surface_texture_class->is_null()) {
    FML_LOG(ERROR) << "Could not locate SurfaceTexture class";
    return false;
  }

  static const JNINativeMethod callback_info_methods[] = {
      {
          .name = "nativeLookupCallbackInformation",
          .signature = "(J)Lio/flutter/view/FlutterCallbackInformation;",
          .fnPtr = reinterpret_cast<void*>(&shell::LookupCallbackInformation),
      },
  };

  if (env->RegisterNatives(g_flutter_callback_info_class->obj(),
                           callback_info_methods,
                           arraysize(callback_info_methods)) != 0) {
    FML_LOG(ERROR) << "Failed to RegisterNatives with FlutterCallbackInfo";
    return false;
  }

  g_attach_to_gl_context_method = env->GetMethodID(
      g_surface_texture_class->obj(), "attachToGLContext", "(I)V");

  if (g_attach_to_gl_context_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate attachToGlContext method";
    return false;
  }

  g_update_tex_image_method =
      env->GetMethodID(g_surface_texture_class->obj(), "updateTexImage", "()V");

  if (g_update_tex_image_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate updateTexImage method";
    return false;
  }

  g_get_transform_matrix_method = env->GetMethodID(
      g_surface_texture_class->obj(), "getTransformMatrix", "([F)V");

  if (g_get_transform_matrix_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate getTransformMatrix method";
    return false;
  }

  g_detach_from_gl_context_method = env->GetMethodID(
      g_surface_texture_class->obj(), "detachFromGLContext", "()V");

  if (g_detach_from_gl_context_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate detachFromGlContext method";
    return false;
  }

  return RegisterApi(env);
}

}  // namespace shell

```
注册Android端和View操作相关的逻辑，初始化FlutterView自己的环境

FlutterJNI

      1.AttachJNI
      2.DestroyJNI
      3.AssetManager

```C
bool RegisterApi(JNIEnv* env) {
  static const JNINativeMethod flutter_jni_methods[] = {
      // Start of methods from FlutterNativeView
      {
          .name = "nativeAttach",
          .signature = "(Lio/flutter/embedding/engine/FlutterJNI;Z)J",
          .fnPtr = reinterpret_cast<void*>(&shell::AttachJNI),
      },
      {
          .name = "nativeDestroy",
          .signature = "(J)V",
          .fnPtr = reinterpret_cast<void*>(&shell::DestroyJNI),
      },
      {
          .name = "nativeRunBundleAndSnapshotFromLibrary",
          .signature = "(J[Ljava/lang/String;Ljava/lang/String;"
                       "Ljava/lang/String;Landroid/content/res/AssetManager;)V",
          .fnPtr =
              reinterpret_cast<void*>(&shell::RunBundleAndSnapshotFromLibrary),
      },
      {
          .name = "nativeGetObservatoryUri",
          .signature = "()Ljava/lang/String;",
          .fnPtr = reinterpret_cast<void*>(&shell::GetObservatoryUri),
      },
      {
          .name = "nativeDispatchEmptyPlatformMessage",
          .signature = "(JLjava/lang/String;I)V",
          .fnPtr =
              reinterpret_cast<void*>(&shell::DispatchEmptyPlatformMessage),
      },
      {
          .name = "nativeDispatchPlatformMessage",
          .signature = "(JLjava/lang/String;Ljava/nio/ByteBuffer;II)V",
          .fnPtr = reinterpret_cast<void*>(&shell::DispatchPlatformMessage),
      },
      {
          .name = "nativeInvokePlatformMessageResponseCallback",
          .signature = "(JILjava/nio/ByteBuffer;I)V",
          .fnPtr = reinterpret_cast<void*>(
              &shell::InvokePlatformMessageResponseCallback),
      },
      {
          .name = "nativeInvokePlatformMessageEmptyResponseCallback",
          .signature = "(JI)V",
          .fnPtr = reinterpret_cast<void*>(
              &shell::InvokePlatformMessageEmptyResponseCallback),
      },

      // Start of methods from FlutterView
      {
          .name = "nativeGetBitmap",
          .signature = "(J)Landroid/graphics/Bitmap;",
          .fnPtr = reinterpret_cast<void*>(&shell::GetBitmap),
      },
      {
          .name = "nativeSurfaceCreated",
          .signature = "(JLandroid/view/Surface;)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SurfaceCreated),
      },
      {
          .name = "nativeSurfaceChanged",
          .signature = "(JII)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SurfaceChanged),
      },
      {
          .name = "nativeSurfaceDestroyed",
          .signature = "(J)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SurfaceDestroyed),
      },
      {
          .name = "nativeSetViewportMetrics",
          .signature = "(JFIIIIIIIIII)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SetViewportMetrics),
      },
      {
          .name = "nativeDispatchPointerDataPacket",
          .signature = "(JLjava/nio/ByteBuffer;I)V",
          .fnPtr = reinterpret_cast<void*>(&shell::DispatchPointerDataPacket),
      },
      {
          .name = "nativeDispatchSemanticsAction",
          .signature = "(JIILjava/nio/ByteBuffer;I)V",
          .fnPtr = reinterpret_cast<void*>(&shell::DispatchSemanticsAction),
      },
      {
          .name = "nativeSetSemanticsEnabled",
          .signature = "(JZ)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SetSemanticsEnabled),
      },
      {
          .name = "nativeSetAccessibilityFeatures",
          .signature = "(JI)V",
          .fnPtr = reinterpret_cast<void*>(&shell::SetAccessibilityFeatures),
      },
      {
          .name = "nativeGetIsSoftwareRenderingEnabled",
          .signature = "()Z",
          .fnPtr = reinterpret_cast<void*>(&shell::GetIsSoftwareRendering),
      },
      {
          .name = "nativeRegisterTexture",
          .signature = "(JJLandroid/graphics/SurfaceTexture;)V",
          .fnPtr = reinterpret_cast<void*>(&shell::RegisterTexture),
      },
      {
          .name = "nativeMarkTextureFrameAvailable",
          .signature = "(JJ)V",
          .fnPtr = reinterpret_cast<void*>(&shell::MarkTextureFrameAvailable),
      },
      {
          .name = "nativeUnregisterTexture",
          .signature = "(JJ)V",
          .fnPtr = reinterpret_cast<void*>(&shell::UnregisterTexture),
      },
  };

  if (env->RegisterNatives(g_flutter_jni_class->obj(), flutter_jni_methods,
                           arraysize(flutter_jni_methods)) != 0) {
    FML_LOG(ERROR) << "Failed to RegisterNatives with FlutterJNI";
    return false;
  }

  g_handle_platform_message_method =
      env->GetMethodID(g_flutter_jni_class->obj(), "handlePlatformMessage",
                       "(Ljava/lang/String;[BI)V");

  if (g_handle_platform_message_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate handlePlatformMessage method";
    return false;
  }

  g_handle_platform_message_response_method = env->GetMethodID(
      g_flutter_jni_class->obj(), "handlePlatformMessageResponse", "(I[B)V");

  if (g_handle_platform_message_response_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate handlePlatformMessageResponse method";
    return false;
  }

  g_update_semantics_method =
      env->GetMethodID(g_flutter_jni_class->obj(), "updateSemantics",
                       "(Ljava/nio/ByteBuffer;[Ljava/lang/String;)V");

  if (g_update_semantics_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate updateSemantics method";
    return false;
  }

  g_update_custom_accessibility_actions_method = env->GetMethodID(
      g_flutter_jni_class->obj(), "updateCustomAccessibilityActions",
      "(Ljava/nio/ByteBuffer;[Ljava/lang/String;)V");

  if (g_update_custom_accessibility_actions_method == nullptr) {
    FML_LOG(ERROR)
        << "Could not locate updateCustomAccessibilityActions method";
    return false;
  }

  g_on_first_frame_method =
      env->GetMethodID(g_flutter_jni_class->obj(), "onFirstFrame", "()V");

  if (g_on_first_frame_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate onFirstFrame method";
    return false;
  }

  g_on_engine_restart_method =
      env->GetMethodID(g_flutter_jni_class->obj(), "onPreEngineRestart", "()V");

  if (g_on_engine_restart_method == nullptr) {
    FML_LOG(ERROR) << "Could not locate onEngineRestart method";
    return false;
  }

  return true;
}
```

### FlutterView 初始化

FlutterNativeView初始化时注册Android PluginMessage到JNI中

```Java
public FlutterNativeView(@NonNull Context context, boolean isBackgroundView) {
        this.flutterUiDisplayListener = new FlutterUiDisplayListener() {
            public void onFlutterUiDisplayed() {
                if (FlutterNativeView.this.mFlutterView != null) {
                    FlutterNativeView.this.mFlutterView.onFirstFrame();
                }
            }

            public void onFlutterUiNoLongerDisplayed() {
            }
        };
        this.mContext = context;
        this.mPluginRegistry = new FlutterPluginRegistry(this, context);
        this.mFlutterJNI = new FlutterJNI();
        this.mFlutterJNI.addIsDisplayingFlutterUiListener(this.flutterUiDisplayListener);
        this.dartExecutor = new DartExecutor(this.mFlutterJNI, context.getAssets());
        this.mFlutterJNI.addEngineLifecycleListener(new FlutterNativeView.EngineLifecycleListenerImpl());
        this.attach(this, isBackgroundView);
        this.assertAttached();
    }
```

### FlutterNativeView
```Java
public FlutterNativeView(@NonNull Context context, boolean isBackgroundView) {
    this.flutterUiDisplayListener = new FlutterUiDisplayListener() {
        public void onFlutterUiDisplayed() {
            if (FlutterNativeView.this.mFlutterView != null) {
                FlutterNativeView.this.mFlutterView.onFirstFrame();
            }
        }

        public void onFlutterUiNoLongerDisplayed() {
        }
    };
    this.mContext = context;
    this.mPluginRegistry = new FlutterPluginRegistry(this, context);
    this.mFlutterJNI = new FlutterJNI();
    this.mFlutterJNI.addIsDisplayingFlutterUiListener(this.flutterUiDisplayListener);
    this.dartExecutor = new DartExecutor(this.mFlutterJNI, context.getAssets());
    this.mFlutterJNI.addEngineLifecycleListener(new FlutterNativeView.EngineLifecycleListenerImpl());
    初始化JIN
    this.attach(this, isBackgroundView);
    this.assertAttached();
}
```
### AttachJNI

接下来进行分析在JNI层的调用过程:AttachJNI中调用`std::make_unique<AndroidShellHolder>`方法创建`AndroidShellHolder`实例`engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`
```c++
    // Called By Java
    // 方法注册进入JNI
    static jlong AttachJNI(JNIEnv* env,
                           jclass clazz,
                           jobject flutterJNI,
                           jboolean is_background_view) {
      fml::jni::JavaObjectWeakGlobalRef java_object(env, flutterJNI);
      auto shell_holder = std::make_unique<AndroidShellHolder>(
          FlutterMain::Get().GetSettings(), java_object, is_background_view);
      if (shell_holder->IsValid()) {
        return reinterpret_cast<jlong>(shell_holder.release());
      } else {
        return 0;
      }
    }
```

`AndroidShellHolder`类是对Platfrom层调用JNI的接口作为一个代理对象来进行统一的代理入口，使用C++11的智能指针对象来统一管理一个对象[C++智能指针](../SmartPtr)


## AndroidShellHolder

### FlutterEngine的初始化入口
AndroidShellHolder：主要是管理flutter engine 在Platform端的入口:

  * 1.Platfrom,UI,IO,GUP线程的管理，配置参数的的加载
  * 2.创建一个线程清理虚拟机退出的清理工作
  * 3.thread_host_负责管理相关的线程,托管四个相处
  * 4.PlatformViewAndroid的创建，负责管理平台侧是事件处理在UI线程执行
  * 5.Rasterizer的初始化栅格化在GPU线程执行
  * 6.MessageLoop的创建，在platfrom中运行
  * 7.TaskRunners管理添加到不同平台中的线程执行，负责管理四个任务运行器
  * 8.Shell加载第三方库，Java虚拟机的创建

![pic](../../assets/images/android/flutter/AndroidShellHolder.png)


```c++
//  参数说明:
//
//   blink::Settings settings,//配置数据
//   fml::jni::JavaObjectWeakGlobalRef java_object,//FlutterJNI 对象
//   bool is_background_view
//   static size_t shell_count = 1;  Shell:对象的个数为一个
//   完成：
//     1.加载Settings配置文件，绑定全局对象java_object
//     2.创建一个线程清理虚拟机退出的清理工作
//     3.ThreadHost类来管理Flutter engine的Platform，io，GPU，UI线程
//     4.初始化消息队列：fml::MessageLoop::EnsureInitializedForCurrentThread();
    //FlutterEngine的初始化入口
AndroidShellHolder::AndroidShellHolder(
    blink::Settings settings,
    fml::jni::JavaObjectWeakGlobalRef java_object,
    bool is_background_view)
    : settings_(std::move(settings)), java_object_(java_object) {
  static size_t shell_count = 1;
  auto thread_label = std::to_string(shell_count++);
  // 创建一个线程清理虚拟机退出的清理工作
  FML_CHECK(pthread_key_create(&thread_destruct_key_, ThreadDestructCallback) ==
            0);

  if (is_background_view) {
    thread_host_ = {thread_label, ThreadHost::Type::UI};
  } else {
    thread_host_ = {thread_label, ThreadHost::Type::UI | ThreadHost::Type::GPU |
                                      ThreadHost::Type::IO};
  }

  // Detach from JNI when the UI and GPU threads exit.
  auto jni_exit_task([key = thread_destruct_key_]() {
    FML_CHECK(pthread_setspecific(key, reinterpret_cast<void*>(1)) == 0);
  });
  thread_host_.ui_thread->GetTaskRunner()->PostTask(jni_exit_task);
  if (!is_background_view) {
    thread_host_.gpu_thread->GetTaskRunner()->PostTask(jni_exit_task);
  }

  fml::WeakPtr<PlatformViewAndroid> weak_platform_view;
  Shell::CreateCallback<PlatformView> on_create_platform_view =
      [is_background_view, java_object, &weak_platform_view](Shell& shell) {
        std::unique_ptr<PlatformViewAndroid> platform_view_android;
        if (is_background_view) {
          platform_view_android = std::make_unique<PlatformViewAndroid>(
              shell,                   // delegate
              shell.GetTaskRunners(),  // task runners
              java_object              // java object handle for JNI interop
          );

        } else {
          platform_view_android = std::make_unique<PlatformViewAndroid>(
              shell,                   // delegate
              shell.GetTaskRunners(),  // task runners
              java_object,             // java object handle for JNI interop
              shell.GetSettings()
                  .enable_software_rendering  // use software rendering
          );
        }
        weak_platform_view = platform_view_android->GetWeakPtr();
        return platform_view_android;
      };

  Shell::CreateCallback<Rasterizer> on_create_rasterizer = [](Shell& shell) {
    return std::make_unique<Rasterizer>(shell.GetTaskRunners());
  };

  // The current thread will be used as the platform thread. Ensure that the
  // message loop is initialized.
  fml::MessageLoop::EnsureInitializedForCurrentThread();
  fml::RefPtr<fml::TaskRunner> gpu_runner;
  fml::RefPtr<fml::TaskRunner> ui_runner;
  fml::RefPtr<fml::TaskRunner> io_runner;
  fml::RefPtr<fml::TaskRunner> platform_runner =
      fml::MessageLoop::GetCurrent().GetTaskRunner();
  if (is_background_view) {
    auto single_task_runner = thread_host_.ui_thread->GetTaskRunner();
    gpu_runner = single_task_runner;
    ui_runner = single_task_runner;
    io_runner = single_task_runner;
  } else {
    gpu_runner = thread_host_.gpu_thread->GetTaskRunner();
    ui_runner = thread_host_.ui_thread->GetTaskRunner();
    io_runner = thread_host_.io_thread->GetTaskRunner();
  }
  blink::TaskRunners task_runners(thread_label,     // label
                                  platform_runner,  // platform
                                  gpu_runner,       // gpu
                                  ui_runner,        // ui
                                  io_runner         // io
  );

  shell_ =
      Shell::Create(task_runners,             // task runners
                    settings_,                // settings
                    on_create_platform_view,  // platform view create callback
                    on_create_rasterizer      // rasterizer create callback
      );

  platform_view_ = weak_platform_view;
  FML_DCHECK(platform_view_);

  is_valid_ = shell_ != nullptr;

  if (is_valid_) {
    task_runners.GetGPUTaskRunner()->PostTask([]() {
      // Android describes -8 as "most important display threads, for
      // compositing the screen and retrieving input events". Conservatively
      // set the GPU thread to slightly lower priority than it.
      if (::setpriority(PRIO_PROCESS, gettid(), -5) != 0) {
        // Defensive fallback. Depending on the OEM, it may not be possible
        // to set priority to -5.
        if (::setpriority(PRIO_PROCESS, gettid(), -2) != 0) {
          FML_LOG(ERROR) << "Failed to set GPU task runner priority";
        }
      }
    });
    task_runners.GetUITaskRunner()->PostTask([]() {
      if (::setpriority(PRIO_PROCESS, gettid(), -1) != 0) {
        FML_LOG(ERROR) << "Failed to set UI task runner priority";
      }
    });
  }
}
```

### 创建一个线程处理JNI退出任务

 创建一个线程来对DartVM虚拟机退出后做一起扫尾工作,并且添加到`ui_thread`,如果`is_background_view`(该参数是在FlutterJNI调用是传入)是在后台工作，也添加到GPU_Thread里面

```c++
// 创建一个线程清理虚拟机退出的清理工作
FML_CHECK(pthread_key_create(&thread_destruct_key_, ThreadDestructCallback) == 0);
```

```c++
// Detach from JNI when the UI and GPU threads exit.
auto jni_exit_task([key = thread_destruct_key_]() {
  FML_CHECK(pthread_setspecific(key, reinterpret_cast<void*>(1)) == 0);
});
thread_host_.ui_thread->GetTaskRunner()->PostTask(jni_exit_task);
if (!is_background_view) {
  thread_host_.gpu_thread->GetTaskRunner()->PostTask(jni_exit_task);
}
```

### Flutter Engine线程池模式

Flutter Engine要求Embeder提供四个Task Runner，Embeder指的是将引擎移植到平台的中间层代码。这四个主要的Task Runner包括：

![pic](../../assets/images/android/flutter/flutterThread.jpeg)

根据在java层调用native层的调用是传入的参数判断创建线程的类型:

  * 1.创建一个ThreadHost来管理4个线程对象
  * 2.定义一个线程类的代理类`/engine/src/flutter/fml/thread.cc`
  * 3.在线程代理类中创建MessageLoop、绑定TaskRunner,同时启动MessageLoop
  * 4.创建一个TaskRunners类来管理四个任务运行器

### ThreadHost

```c++
if (is_background_view) {
  thread_host_ = {thread_label, ThreadHost::Type::UI};
} else {
  thread_host_ = {thread_label, ThreadHost::Type::UI | ThreadHost::Type::GPU |
                                    ThreadHost::Type::IO};
}
```
`ThreadHost` 类主要是创建的Platform，UI，IO，GPU线程，主要用来对四个线程的宿主对象,定义一个枚举类型来标记四种线程的类型:

```c++

enum Type {
  Platform = 1 << 0,
  UI = 1 << 1,
  GPU = 1 << 2,
  IO = 1 << 3,
};
```
构造方法创建四个线程[C++智能指针](../SmartPtr):
```c++
ThreadHost::ThreadHost(std::string name_prefix, uint64_t mask) {
  if (mask & ThreadHost::Type::Platform) {
    platform_thread = std::make_unique<fml::Thread>(name_prefix + ".platform");
  }

  if (mask & ThreadHost::Type::UI) {
    ui_thread = std::make_unique<fml::Thread>(name_prefix + ".ui");
  }

  if (mask & ThreadHost::Type::GPU) {
    gpu_thread = std::make_unique<fml::Thread>(name_prefix + ".gpu");
  }

  if (mask & ThreadHost::Type::IO) {
    io_thread = std::make_unique<fml::Thread>(name_prefix + ".io");
  }
}
```

### MessageLoop

在`engine/src/flutter/fml/thread.cc`构造方法中创建线程类，同时初始化[MessageLoop](../MessageLoop),关联任务运行器到消息队列，同时启动消息队列`loop.Run()`,是个线程创建的时候分别创建了四个不同的MessageLoop

```c++
Thread::Thread(const std::string& name) : joined_(false) {
  fml::AutoResetWaitableEvent latch;
  fml::RefPtr<fml::TaskRunner> runner;
  thread_ = std::make_unique<std::thread>([&latch, &runner, name]() -> void {
    SetCurrentThreadName(name);
    fml::MessageLoop::EnsureInitializedForCurrentThread();//初始化消息队列
    auto& loop = MessageLoop::GetCurrent();
    runner = loop.GetTaskRunner();
    latch.Signal();
    loop.Run();//启动消息队列
  });
  // 当前线程等待状态
  latch.Wait();
  task_runner_ = runner;
}
```


### `Platform Task Runner:`

Flutter Engine的主Task Runner，类似于Android Main Thread或者iOS的Main Thread。但是需要注意他们还是有区别的。

一般来说，一个Flutter应用启动的时候会创建一个Engine实例，Engine创建的时候会创建一个线程供Platform Runner使用。

跟Flutter Engine的所有交互（接口调用）必须在Platform Thread进行，否则可能导致无法预期的异常。这跟iOS UI相关的操作都必须在主线程进行相类似。需要注意的是在Flutter Engine中有很多模块都是非线程安全的。

规则很简单，对于Flutter Engine的接口调用都需保证在Platform Thread进行。

阻塞Platform Thread不会直接导致Flutter应用的卡顿（跟iOS android主线程不同）。尽管如此，也不建议在这个Runner执行繁重的操作，长时间卡住Platform Thread应用有可能会被系统Watchdog强杀。

### `UI Task Runner Thread（Dart Runner）`

UI Task Runner用于执行Dart root isolate代码（isolate我们后面会讲到，姑且先简单理解为Dart VM里面的线程）。Root isolate比较特殊，它绑定了不少Flutter需要的函数方法，以便进行渲染相关操作。对于每一帧，引擎要做的事情有：

Root isolate通知Flutter Engine有帧需要渲染。
Flutter Engine通知平台，需要在下一个vsync的时候得到通知。
平台等待下一个vsync
对创建的对象和Widgets进行Layout并生成一个Layer Tree，这个Tree马上被提交给Flutter Engine。当前阶段没有进行任何光栅化，这个步骤仅是生成了对需要绘制内容的描述。
创建或者更新Tree，这个Tree包含了用于屏幕上显示Widgets的语义信息。这个东西主要用于平台相关的辅助Accessibility元素的配置和渲染。
除了渲染相关逻辑之外Root Isolate还是处理来自Native Plugins的消息，Timers，Microtasks和异步IO等操作。Root Isolate负责创建管理的Layer Tree最终决定绘制到屏幕上的内容。因此这个线程的过载会直接导致卡顿掉帧。

### `GPU Task Runner`

GPU Task Runner主要用于执行设备GPU的指令。UI Task Runner创建的Layer Tree是跨平台的，它不关心到底由谁来完成绘制。GPU Task Runner负责将Layer Tree提供的信息转化为平台可执行的GPU指令。GPU Task Runner同时负责绘制所需要的GPU资源的管理。资源主要包括平台Framebuffer，Surface，Texture和Buffers等。

一般来说UI Runner和GPU Runner跑在不同的线程。GPU Runner会根据目前帧执行的进度去向UI Runner要求下一帧的数据，在任务繁重的时候可能会告诉UI Runner延迟任务。这种调度机制确保GPU Runner不至于过载，同时也避免了UI Runner不必要的消耗。

建议为每一个Engine实例都新建一个专用的GPU Runner线程。

### `IO Task Runner`

前面讨论的几个Runner对于执行流畅度有比较高的要求。Platform Runner过载可能导致系统WatchDog强杀，UI和GPU Runner过载则可能导致Flutter应用的卡顿。但是GPU线程的一些必要操作，例如IO，放到哪里执行呢？答案正是IO Runner。

IO Runner的主要功能是从图片存储（比如磁盘）中读取压缩的图片格式，将图片数据进行处理为GPU Runner的渲染做好准备。IO Runner首先要读取压缩的图片二进制数据（比如PNG，JPEG），将其解压转换成GPU能够处理的格式然后将数据上传到GPU。

获取诸如ui.Image这样的资源只有通过async call去调用，当调用发生的时候Flutter Framework告诉IO Runner进行加载的异步操作。

IO Runner直接决定了图片和其它一些资源加载的延迟间接影响性能。所以建议为IO Runner创建一个专用的线程。



## TaskRunner

ThreadHost创建完成四个线程之后，在创建四个`TaskRunner`来管理Platform，UI，GPU，IO线程中的任务`engine/src/flutter/fml/task_runner.h`

提供四个方法处理提交到MessageLoop的任务的执行时间和关联到消息队列

  * PostTask
  * PostTaskForTime
  * PostDelayedTask
  * RunNowOrPostTask
  * RefPtr<MessageLoopImpl> loop_

```C
namespace fml {

class MessageLoopImpl;

class TaskRunner : public fml::RefCountedThreadSafe<TaskRunner> {
 public:
  virtual void PostTask(fml::closure task);

  virtual void PostTaskForTime(fml::closure task, fml::TimePoint target_time);

  virtual void PostDelayedTask(fml::closure task, fml::TimeDelta delay);

  virtual bool RunsTasksOnCurrentThread();

  virtual ~TaskRunner();

  static void RunNowOrPostTask(fml::RefPtr<fml::TaskRunner> runner,
                               fml::closure task);

 protected:
  TaskRunner(fml::RefPtr<MessageLoopImpl> loop);

 private:
  fml::RefPtr<MessageLoopImpl> loop_;

  FML_FRIEND_MAKE_REF_COUNTED(TaskRunner);
  FML_FRIEND_REF_COUNTED_THREAD_SAFE(TaskRunner);
  FML_DISALLOW_COPY_AND_ASSIGN(TaskRunner);
};

}  // namespace fml

#endif  // FLUTTER_FML_TASK_RUNNER_H_
```


## TaskRunners

创建一个TaskRunners统一管理四个线程中的任务

```C
TaskRunners task_runners(thread_label,     // label
                                platform_runner,  // platform
                                gpu_runner,       // gpu
                                ui_runner,        // ui
                                io_runner         // io
```

```C
namespace blink {

记录平台相关的四个相关的线程的任务统一的管理。
class TaskRunners {
 public:
  TaskRunners(std::string label,
              fml::RefPtr<fml::TaskRunner> platform, //平台线程关联
              fml::RefPtr<fml::TaskRunner> gpu,//gpu线程关联
              fml::RefPtr<fml::TaskRunner> ui,//ui相处的关联
              fml::RefPtr<fml::TaskRunner> io);//io相处
........
 private:
  const std::string label_;
  fml::RefPtr<fml::TaskRunner> platform_;
  fml::RefPtr<fml::TaskRunner> gpu_;
  fml::RefPtr<fml::TaskRunner> ui_;
  fml::RefPtr<fml::TaskRunner> io_;
};

}  // namespace blink

#endif  // FLUTTER_COMMON_TASK_RUNNERS_H_
```

## Shell类初始化:

Shell 类的初始化，主要负责管理客户端相关的资源`/engine/src/flutter/shell/platform/android/android_shell_holder.cc`,创建的地方

![pic](../../assets/images/android/flutter/shell.png)

!!! info "Shell主要的功能初始化以下四个对象"

    * platform_view_ = std::move(platform_view);
    * engine_ = std::move(engine);
    * rasterizer_ = std::move(rasterizer);
    * io_manager_ = std::move(io_manager);
    * 创建DartVM虚拟机


主要执行的动作:


!!! waring "在new Shell时候有从新创建了一个DartVM"

  * 1.记录开始时间
  * 2.初始化日志设置
  * 3.初始化Skia：InitSkiaEventTracer
  * 4.初始化：SkGraphics
  * 5.初始化本地化库:InitializeICU
  * 6.创建虚拟机:blink::DartVM::ForProcess(settings);
  * 7.开启平台任务任务
  * new Shell
  * 7.2:在new Shell时候有从新创建了一个DartVM：
  * 7.3 Install service protocol handlers.
  * 8.真正创建平台操作的对象/engine/src/flutter/shell/platform/android/platform_view_android.cc
  * 9.创建一个CreateVSyncWaiter对象
  * 10.创建IOManager管理器，在IO线程执行
  * 11.创建Rasterizer执行在GPU线程
  * 12.创建engine在UI线程执行

```c

Shell::Shell(blink::TaskRunners task_runners, blink::Settings settings)
: task_runners_(std::move(task_runners)),//任务运行器
settings_(std::move(settings)),
vm_(blink::DartVM::ForProcess(settings_)) {//创建一个新的DartVM
FML_DCHECK(task_runners_.IsValid());
FML_DCHECK(task_runners_.GetPlatformTaskRunner()->RunsTasksOnCurrentThread());
```

```C

shell_ =
    Shell::Create(task_runners,             // task runners
                  settings_,                // settings
                  on_create_platform_view,  // platform view create callback
                  on_create_rasterizer      // rasterizer create callback
    );

在Shell创建时:

  std::unique_ptr<Shell> Shell::Create(
      blink::TaskRunners task_runners,
      blink::Settings settings,
      Shell::CreateCallback<PlatformView> on_create_platform_view,
      Shell::CreateCallback<Rasterizer> on_create_rasterizer) {
    //初始化第三方库
    PerformInitializationTasks(settings);

    //初始化DartVM虚拟机
    auto vm = blink::DartVM::ForProcess(settings);
    FML_CHECK(vm) << "Must be able to initialize the VM.";
    return Shell::Create(std::move(task_runners),             //
                         std::move(settings),                 //
                         vm->GetIsolateSnapshot(),            //
                         blink::DartSnapshot::Empty(),        //
                         std::move(on_create_platform_view),  //
                         std::move(on_create_rasterizer)      //
    );
  }

```
### 初始化DartVM
[DartVM::ForProcess](DartVM)

Dart VM 虚拟机在Shell创建的时候初始化：`auto vm = blink::DartVM::ForProcess(settings);`,`/engine/src/flutter/shell/common/shell.cc`,Shell::Create，Dart虚拟机的分析，在后续在进行扩展

  * 1.加载dart虚拟机快照
  * 2.加载Isolate快照
  * 3.调用DartVM构造方法初始化虚拟机

```c
  fml::RefPtr<DartVM> DartVM::ForProcess(
    Settings settings,
    fml::RefPtr<DartSnapshot> vm_snapshot,
    fml::RefPtr<DartSnapshot> isolate_snapshot,
    fml::RefPtr<DartSnapshot> shared_snapshot) {
  std::lock_guard<std::mutex> lock(gVMMutex);
  std::call_once(gVMInitialization, [settings,          //
                                     vm_snapshot,       //
                                     isolate_snapshot,  //
                                     shared_snapshot    //
  ]() mutable {
    if (!vm_snapshot) {
      vm_snapshot = DartSnapshot::VMSnapshotFromSettings(settings);
    }
    if (!(vm_snapshot && vm_snapshot->IsValid())) {
      FML_LOG(ERROR) << "VM snapshot must be valid.";
      return;
    }
    if (!isolate_snapshot) {
      isolate_snapshot = DartSnapshot::IsolateSnapshotFromSettings(settings);
    }
    if (!(isolate_snapshot && isolate_snapshot->IsValid())) {
      FML_LOG(ERROR) << "Isolate snapshot must be valid.";
      return;
    }
    if (!shared_snapshot) {
      shared_snapshot = DartSnapshot::Empty();
    }
    gVM = fml::MakeRefCounted<DartVM>(settings,                     //
                                      std::move(vm_snapshot),       //
                                      std::move(isolate_snapshot),  //
                                      std::move(shared_snapshot)    //
    );
  });
  return gVM;
  }

```

### Shell创建时第三方库初始化位置

`PerformInitializationTasks`,`/engine/src/flutter/shell/common/shell.cc`

  *  RecordStartupTimestamp()记录时间戳
  * fml::SetLogSettings(log_settings) 设置日志信息
  * InitSkiaEventTracer(settings.trace_skia) 初始化Skia2d图像引擎库跟踪器
  * SkGraphics::Init();  初始化2d图形引擎库
  * fml::icu::InitializeICU(settings.icu_data_path); 初始化国际化处理ICU


```c++
// Though there can be multiple shells, some settings apply to all components in
// the process. These have to be setup before the shell or any of its
// sub-components can be initialized. In a perfect world, this would be empty.
// TODO(chinmaygarde): The unfortunate side effect of this call is that settings
// that cause shell initialization failures will still lead to some of their
// settings being applied.
static void PerformInitializationTasks(const blink::Settings& settings) {
  static std::once_flag gShellSettingsInitialization = {};
  std::call_once(gShellSettingsInitialization, [&settings] {
    RecordStartupTimestamp();

    {
      fml::LogSettings log_settings;
      log_settings.min_log_level =
          settings.verbose_logging ? fml::LOG_INFO : fml::LOG_ERROR;
      fml::SetLogSettings(log_settings);
    }

    tonic::SetLogHandler(
        [](const char* message) { FML_LOG(ERROR) << message; });

    if (settings.trace_skia) {
      InitSkiaEventTracer(settings.trace_skia);
    }

    if (!settings.skia_deterministic_rendering_on_cpu) {
      SkGraphics::Init();
    } else {
      FML_DLOG(INFO) << "Skia deterministic rendering is enabled.";
    }

    if (settings.icu_initialization_required) {
      if (settings.icu_data_path.size() != 0) {
        fml::icu::InitializeICU(settings.icu_data_path);
      } else if (settings.icu_mapper) {
        fml::icu::InitializeICUFromMapping(settings.icu_mapper());
      } else {
        FML_DLOG(WARNING) << "Skipping ICU initialization in the shell.";
      }
    }
  });
}
```


### CreateShellOnPlatformThread

Shell创建所需要的在这个类里面进行初始化`CreateShellOnPlatformThread`对Shell对应的platefrom,IO,GPU,UI,`/engine/src/flutter/shell/common/shell.cc`，以下的类主要观察构造方法中传入的参数，能够帮助理解相关的逻辑调用
!!! WARNING "以下代码片段是真正初始化对象的地方"
```C++

std::unique_ptr<Shell> Shell::Create(
    blink::TaskRunners task_runners,
    blink::Settings settings,
    fml::RefPtr<blink::DartSnapshot> isolate_snapshot,
    fml::RefPtr<blink::DartSnapshot> shared_snapshot,
    Shell::CreateCallback<PlatformView> on_create_platform_view,
    Shell::CreateCallback<Rasterizer> on_create_rasterizer) {
  PerformInitializationTasks(settings);

  if (!task_runners.IsValid() || !on_create_platform_view ||
      !on_create_rasterizer) {
    return nullptr;
  }

  fml::AutoResetWaitableEvent latch;
  std::unique_ptr<Shell> shell;
  fml::TaskRunner::RunNowOrPostTask(//提交任务到Platform线程运行
      task_runners.GetPlatformTaskRunner(),
      [&latch,                                          //
       &shell,                                          //
       task_runners = std::move(task_runners),          //
       settings,                                        //
       isolate_snapshot = std::move(isolate_snapshot),  //
       shared_snapshot = std::move(shared_snapshot),    //
       on_create_platform_view,                         //
       on_create_rasterizer                             //
  ]() {
        shell = CreateShellOnPlatformThread(std::move(task_runners),      //
                                            settings,                     //
                                            std::move(isolate_snapshot),  //
                                            std::move(shared_snapshot),   //
                                            on_create_platform_view,      //
                                            on_create_rasterizer          //
        );
        latch.Signal();
      });
  latch.Wait();
  return shell;
}
```

CreateShellOnPlatformThread`完成Shell分的一下初始化信息

  * 1.创建一个Shell实例对象`auto shell = std::unique_ptr<Shell>(new Shell(task_runners, settings));
  * 2.创建平台View在平台线程`auto platform_view = on_create_platform_view(*shell.get());
  * 3.创建一个Syncwaiter`auto vsync_waiter = platform_view->CreateVSyncWaiter();
  * 4.创建一个IO管理io线程`std::unique_ptr<IOManager> io_manager;
  * 5.在UI线程创建engine：`fml::AutoResetWaitableEvent ui_latch;

```C

std::unique_ptr<Shell> Shell::CreateShellOnPlatformThread(
  blink::TaskRunners task_runners,
  blink::Settings settings,
  fml::RefPtr<blink::DartSnapshot> isolate_snapshot,
  fml::RefPtr<blink::DartSnapshot> shared_snapshot,
  Shell::CreateCallback<PlatformView> on_create_platform_view,
  Shell::CreateCallback<Rasterizer> on_create_rasterizer) {
if (!task_runners.IsValid()) {
  return nullptr;
}

auto shell = std::unique_ptr<Shell>(new Shell(task_runners, settings));

// Create the platform view on the platform thread (this thread).
auto platform_view = on_create_platform_view(*shell.get());
if (!platform_view || !platform_view->GetWeakPtr()) {
  return nullptr;
}

// Ask the platform view for the vsync waiter. This will be used by the engine
// to create the animator.
auto vsync_waiter = platform_view->CreateVSyncWaiter();
if (!vsync_waiter) {
  return nullptr;
}

// Create the IO manager on the IO thread. The IO manager must be initialized
// first because it has state that the other subsystems depend on. It must
// first be booted and the necessary references obtained to initialize the
// other subsystems.
fml::AutoResetWaitableEvent io_latch;
std::unique_ptr<IOManager> io_manager;
auto io_task_runner = shell->GetTaskRunners().GetIOTaskRunner();
fml::TaskRunner::RunNowOrPostTask(
    io_task_runner,
    [&io_latch,       //
     &io_manager,     //
     &platform_view,  //
     io_task_runner   //
]() {
      io_manager = std::make_unique<IOManager>(
          platform_view->CreateResourceContext(), io_task_runner);
      io_latch.Signal();
    });
io_latch.Wait();

// Create the rasterizer on the GPU thread.
fml::AutoResetWaitableEvent gpu_latch;
std::unique_ptr<Rasterizer> rasterizer;
fml::WeakPtr<blink::SnapshotDelegate> snapshot_delegate;
fml::TaskRunner::RunNowOrPostTask(
    task_runners.GetGPUTaskRunner(), [&gpu_latch,            //
                                      &rasterizer,           //
                                      on_create_rasterizer,  //
                                      shell = shell.get(),   //
                                      &snapshot_delegate     //
]() {
      if (auto new_rasterizer = on_create_rasterizer(*shell)) {
        rasterizer = std::move(new_rasterizer);
        snapshot_delegate = rasterizer->GetSnapshotDelegate();
      }
      gpu_latch.Signal();
    });

gpu_latch.Wait();

// Create the engine on the UI thread.
fml::AutoResetWaitableEvent ui_latch;
std::unique_ptr<Engine> engine;
fml::TaskRunner::RunNowOrPostTask(
    shell->GetTaskRunners().GetUITaskRunner(),
    fml::MakeCopyable([&ui_latch,                                         //
                       &engine,                                           //
                       shell = shell.get(),                               //
                       isolate_snapshot = std::move(isolate_snapshot),    //
                       shared_snapshot = std::move(shared_snapshot),      //
                       vsync_waiter = std::move(vsync_waiter),            //
                       snapshot_delegate = std::move(snapshot_delegate),  //
                       io_manager = io_manager->GetWeakPtr()              //
]() mutable {
      const auto& task_runners = shell->GetTaskRunners();

      // The animator is owned by the UI thread but it gets its vsync pulses
      // from the platform.
      auto animator = std::make_unique<Animator>(*shell, task_runners,
                                                 std::move(vsync_waiter));

      engine = std::make_unique<Engine>(*shell,                        //
                                        shell->GetDartVM(),            //
                                        std::move(isolate_snapshot),   //
                                        std::move(shared_snapshot),    //
                                        task_runners,                  //
                                        shell->GetSettings(),          //
                                        std::move(animator),           //
                                        std::move(snapshot_delegate),  //
                                        std::move(io_manager)          //
      );
      ui_latch.Signal();
    }));

ui_latch.Wait();
// We are already on the platform thread. So there is no platform latch to
// wait on.

if (!shell->Setup(std::move(platform_view),  //
                  std::move(engine),         //
                  std::move(rasterizer),     //
                  std::move(io_manager))     //
) {
  return nullptr;
}

return shell;
}

```

设置Shell管理的Platform线程管理的相关资源:`/engine/src/flutter/shell/common/engine.cc`在`/engine/src/flutter/shell/common/shell.cc`中执行`CreateShellOnPlatformThread`方法时调用

* 1.PlatformView:主要管理相关的view事件
* 2.Engine:所有的资源都准备完成，开始调用dart代码和Dart虚拟机，进行代码执行
* 3.Rasterizer:光栅主要是处理GPU相关的事件
* 4.IOManager:对io线程进行管理
* 5.设置 DartVM ServiceProtocol设置处理回调
* 6.PersistentCache::GetCacheForProcess()->AddWorkerTaskRunner(task_runners_.GetIOTaskRunner());对缓存目录的处理

```C
bool Shell::Setup(std::unique_ptr<PlatformView> platform_view,
                  std::unique_ptr<Engine> engine,
                  std::unique_ptr<Rasterizer> rasterizer,
                  std::unique_ptr<IOManager> io_manager) {
  if (is_setup_) {
    return false;
  }

  if (!platform_view || !engine || !rasterizer || !io_manager) {
    return false;
  }

  platform_view_ = std::move(platform_view);
  engine_ = std::move(engine);
  rasterizer_ = std::move(rasterizer);
  io_manager_ = std::move(io_manager);

  is_setup_ = true;

  if (auto vm = blink::DartVM::ForProcessIfInitialized()) {
    vm->GetServiceProtocol().AddHandler(this, GetServiceProtocolDescription());
  }

  PersistentCache::GetCacheForProcess()->AddWorkerTaskRunner(
      task_runners_.GetIOTaskRunner());

  return true;
}
```

#### Create the platform

```C
// Create the platform view on the platform thread (this thread).
auto platform_view = on_create_platform_view(*shell.get());
if (!platform_view || !platform_view->GetWeakPtr()) {
  return nullptr;
}
```
#### CreateVSyncWaiter
```C
// Ask the platform view for the vsync waiter. This will be used by the engine
// to create the animator.
auto vsync_waiter = platform_view->CreateVSyncWaiter();
if (!vsync_waiter) {
  return nullptr;
}
```

#### Create the IO manager on the IO thread

```C
// Create the IO manager on the IO thread. The IO manager must be initialized
// first because it has state that the other subsystems depend on. It must
// first be booted and the necessary references obtained to initialize the
// other subsystems.
fml::AutoResetWaitableEvent io_latch;
std::unique_ptr<IOManager> io_manager;
auto io_task_runner = shell->GetTaskRunners().GetIOTaskRunner();
fml::TaskRunner::RunNowOrPostTask(
    io_task_runner,
    [&io_latch,       //
     &io_manager,     //
     &platform_view,  //
     io_task_runner   //
]() {
      io_manager = std::make_unique<IOManager>(
          platform_view->CreateResourceContext(), io_task_runner);
      io_latch.Signal();
    });
io_latch.Wait();

```
#### Create the rasterizer on the GPU thread

```C
// Create the rasterizer on the GPU thread.
fml::AutoResetWaitableEvent gpu_latch;
std::unique_ptr<Rasterizer> rasterizer;
fml::WeakPtr<blink::SnapshotDelegate> snapshot_delegate;
fml::TaskRunner::RunNowOrPostTask(
    task_runners.GetGPUTaskRunner(), [&gpu_latch,            //
                                      &rasterizer,           //
                                      on_create_rasterizer,  //
                                      shell = shell.get(),   //
                                      &snapshot_delegate     //
]() {
      if (auto new_rasterizer = on_create_rasterizer(*shell)) {
        rasterizer = std::move(new_rasterizer);
        snapshot_delegate = rasterizer->GetSnapshotDelegate();
      }
      gpu_latch.Signal();
    });

gpu_latch.Wait();
```
#### Create the engine on the UI thread
```C
// Create the engine on the UI thread.
fml::AutoResetWaitableEvent ui_latch;
std::unique_ptr<Engine> engine;
fml::TaskRunner::RunNowOrPostTask(
    shell->GetTaskRunners().GetUITaskRunner(),
    fml::MakeCopyable([&ui_latch,                                         //
                       &engine,                                           //
                       shell = shell.get(),                               //
                       isolate_snapshot = std::move(isolate_snapshot),    //
                       shared_snapshot = std::move(shared_snapshot),      //
                       vsync_waiter = std::move(vsync_waiter),            //
                       snapshot_delegate = std::move(snapshot_delegate),  //
                       io_manager = io_manager->GetWeakPtr()              //
]() mutable {
      const auto& task_runners = shell->GetTaskRunners();

      // The animator is owned by the UI thread but it gets its vsync pulses
      // from the platform.
      auto animator = std::make_unique<Animator>(*shell, task_runners,
                                                 std::move(vsync_waiter));

      engine = std::make_unique<Engine>(*shell,                        //
                                        shell->GetDartVM(),            //
                                        std::move(isolate_snapshot),   //
                                        std::move(shared_snapshot),    //
                                        task_runners,                  //
                                        shell->GetSettings(),          //
                                        std::move(animator),           //
                                        std::move(snapshot_delegate),  //
                                        std::move(io_manager)          //
      );
      ui_latch.Signal();
    }));

ui_latch.Wait();
```

### Engine初始化

```C
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
### RuntimeController&WindowClient&Window

```C
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
    std::function<void(int64_t)> p_idle_notification_callback)
    : RuntimeController(p_client,
                        p_vm,
                        std::move(p_isolate_snapshot),
                        std::move(p_shared_snapshot),
                        std::move(p_task_runners),
                        std::move(p_snapshot_delegate),
                        std::move(p_io_manager),
                        std::move(p_advisory_script_uri),
                        std::move(p_advisory_script_entrypoint),
                        p_idle_notification_callback,
                        WindowData{/* default window data */}) {}

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
  当前对象是ClientWidow对象，动过调用DidCreateIsolate，加载dart:UI库
  if (auto* window = GetWindowIfAvailable()) {
    tonic::DartState::Scope scope(root_isolate);
    window->DidCreateIsolate();
    if (!FlushRuntimeStateToIsolate()) {
      FML_DLOG(ERROR) << "Could not setup intial isolate state.";
    }
  } else {
    FML_DCHECK(false) << "RuntimeController created without window binding.";
  }
  FML_DCHECK(Dart_CurrentIsolate() == nul
};

}  // namespace blink

#endif  // FLUTTER_RUNTIME_RUNTIME_CONTROLLER_H_

```

### DartIsolate
调用`shared_embedder_isolate->SetWindow(std::move(window));`对象传递`RuntimeController`到`Window`类中进行绑定
```C

std::weak_ptr<DartIsolate> DartIsolate::CreateRootIsolate(
    DartVM* vm,
    fml::RefPtr<DartSnapshot> isolate_snapshot,
    fml::RefPtr<DartSnapshot> shared_snapshot,
    TaskRunners task_runners,
    std::unique_ptr<Window> window,
    fml::WeakPtr<SnapshotDelegate> snapshot_delegate,
    fml::WeakPtr<IOManager> io_manager,
    std::string advisory_script_uri,
    std::string advisory_script_entrypoint,
    Dart_IsolateFlags* flags) {
  TRACE_EVENT0("flutter", "DartIsolate::CreateRootIsolate");
  Dart_Isolate vm_isolate = nullptr;
  std::weak_ptr<DartIsolate> embedder_isolate;

  char* error = nullptr;

  // Since this is the root isolate, we fake a parent embedder data object. We
  // cannot use unique_ptr here because the destructor is private (since the
  // isolate lifecycle is entirely managed by the VM).
  auto root_embedder_data = std::make_unique<std::shared_ptr<DartIsolate>>(
      std::make_shared<DartIsolate>(
          vm,                            // VM
          std::move(isolate_snapshot),   // isolate snapshot
          std::move(shared_snapshot),    // shared snapshot
          task_runners,                  // task runners
          std::move(snapshot_delegate),  // snapshot delegate
          std::move(io_manager),         // IO manager
          advisory_script_uri,           // advisory URI
          advisory_script_entrypoint,    // advisory entrypoint
          nullptr  // child isolate preparer will be set when this isolate is
                   // prepared to run
          ));

  std::tie(vm_isolate, embedder_isolate) = CreateDartVMAndEmbedderObjectPair(
      advisory_script_uri.c_str(),         // advisory script URI
      advisory_script_entrypoint.c_str(),  // advisory script entrypoint
      nullptr,                             // package root
      nullptr,                             // package config
      flags,                               // flags
      root_embedder_data.get(),            // parent embedder data
      true,                                // is root isolate
      &error                               // error (out)
  );

  if (error != nullptr) {
    free(error);
  }

  if (vm_isolate == nullptr) {
    return {};
  }

  std::shared_ptr<DartIsolate> shared_embedder_isolate =
      embedder_isolate.lock();
  if (shared_embedder_isolate) {
    // Only root isolates can interact with windows.
    shared_embedder_isolate->SetWindow(std::move(window));
  }

  root_embedder_data.release();

  return embedder_isolate;
}
}

```
### Window类初始化过程
CreateRootIsolate 创建 RootIsolate对象

```C
RuntimeController::RuntimeController(.....)
    : client_(p_client),
      .......),
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
  ## Window类初始化过程

  if (auto* window = GetWindowIfAvailable()) {
    tonic::DartState::Scope scope(root_isolate);
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
### Android Native层与libFlutter通信接口:


在分析完成整个初始化过程这回，在跟进下图来分析整个调用过程和以上代码的初始化过程，有助于理解整个运行环境的初始化相关的类和功能及逻辑

![pic](../../assets/images/android/flutter/flutterplugin1.png)

 Android端调用JNI层的代码，使用本地接口和FlutterEngine通信，在Flutter for Android 中通过FlutterJNI中相关的本地方法，platform_view_android_jni在第一次加载so库是进行初始化:

`/io/flutter/embedding/engine/FlutterJNI.class`
`engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`

```java
public class FlutterJNI {
    @UiThread
    public static native boolean nativeGetIsSoftwareRenderingEnabled();
    @UiThread
    public static native String nativeGetObservatoryUri();
    private native void nativeSurfaceCreated(long var1, Surface var3);
    private native void nativeSurfaceChanged(long var1, int var3, int var4);
    private native void nativeSurfaceDestroyed(long var1);
    private native void nativeSetViewportMetrics(long var1, float var3, int var4, int var5, int var6, int var7, int var8, int var9, int var10, int var11, int var12, int var13);
    private native Bitmap nativeGetBitmap(long var1);
    private native void nativeDispatchPointerDataPacket(long var1, ByteBuffer var3, int var4);
    private native void nativeDispatchSemanticsAction(long var1, int var3, int var4, ByteBuffer var5, int var6);
    private native void nativeSetSemanticsEnabled(long var1, boolean var3);
    private native void nativeSetAccessibilityFeatures(long var1, int var3);
    private native void nativeRegisterTexture(long var1, long var3, SurfaceTexture var5);
    private native void nativeMarkTextureFrameAvailable(long var1, long var3);
    private native void nativeUnregisterTexture(long var1, long var3);
    private native long nativeAttach(FlutterJNI var1, boolean var2);
    private native void nativeDetach(long var1);
    private native void nativeDestroy(long var1);
    private native void nativeRunBundleAndSnapshotFromLibrary(long var1, @NonNull String[] var3, @Nullable String var4, @Nullable String var5, @NonNull AssetManager var6);
    private native void nativeDispatchEmptyPlatformMessage(long var1, String var3, int var4);
    private native void nativeDispatchPlatformMessage(long var1, String var3, ByteBuffer var4, int var5, int var6);
    private native void nativeInvokePlatformMessageEmptyResponseCallback(long var1, int var3);
    private native void nativeInvokePlatformMessageResponseCallback(long var1, int var3, ByteBuffer var4, int var5);
}
```


引擎元代码中使用动态JNI的方式注册相关方法:
`engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`

调用Register方法注册本地方法：
```c++
bool RegisterApi(JNIEnv* env) {
static const JNINativeMethod flutter_jni_methods[] = {
  // Start of methods from FlutterNativeView
  {
      .name = "nativeAttach",
      .signature = "(Lio/flutter/embedding/engine/FlutterJNI;Z)J",
      .fnPtr = reinterpret_cast<void*>(&shell::AttachJNI),
  },
  {
      .name = "nativeDestroy",
      .signature = "(J)V",
      .fnPtr = reinterpret_cast<void*>(&shell::DestroyJNI),
  },
  {
      .name = "nativeRunBundleAndSnapshotFromLibrary",
      .signature = "(J[Ljava/lang/String;Ljava/lang/String;"
                   "Ljava/lang/String;Landroid/content/res/AssetManager;)V",
      .fnPtr =
          reinterpret_cast<void*>(&shell::RunBundleAndSnapshotFromLibrary),
  },
};

if (env->RegisterNatives(g_flutter_jni_class->obj(), flutter_jni_methods,
                     arraysize(flutter_jni_methods)) != 0) {
FML_LOG(ERROR) << "Failed to RegisterNatives with FlutterJNI";
return false;
}
```

```


`engine/src/flutter/shell/common/shell.cc`作为一个中枢控制作用，使用弱引用来保存PlatformView，Android，ios保存使用shell中Platform下的Platefrom实现来处理平台相关的View,Shell的初始化是在`engine/src/flutter/shell/platform/android/android_shell_holder.cc`，`FlutterMain::Get().GetSettings()`编译时的配置文件`engine/src/flutter/common/settings.cc`,`flutterJNI`是android层的代码，`is_background_view`是在java层FlutterNativeView，这是Java和JNI的通信，数据传输逻辑处理，FlutterNativeView的构造方法中调用JNI代码，初始化`android_shell_holder`使用这个类来全部`Shell`这个类



### SurfaceView初始化

### Java SurfaceView 初始化

getFlutterJNI 初始化SurfaceView
```Java
this.mSurfaceCallback = new Callback() {
    public void surfaceCreated(SurfaceHolder holder) {
        FlutterView.this.assertAttached();
        FlutterView.this.mNativeView.getFlutterJNI().onSurfaceCreated(holder.getSurface());
    }

    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        FlutterView.this.assertAttached();
        FlutterView.this.mNativeView.getFlutterJNI().onSurfaceChanged(width, height);
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        FlutterView.this.assertAttached();
        FlutterView.this.mNativeView.getFlutterJNI().onSurfaceDestroyed();
    }
};


```

### JNI 初始化SurfaceView

`/Users/cangck/engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`
#### SurfaceCreated
```C
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
#### SurfaceChanged
```C
static void SurfaceChanged(JNIEnv* env,
                           jobject jcaller,
                           jlong shell_holder,
                           jint width,
                           jint height) {
  ANDROID_SHELL_HOLDER->GetPlatformView()->NotifyChanged(
      SkISize::Make(width, height));
}

```
#### SurfaceDestroyed
```C
static void SurfaceDestroyed(JNIEnv* env, jobject jcaller, jlong shell_holder) {
  ANDROID_SHELL_HOLDER->GetPlatformView()->NotifyDestroyed();
}
```

## 总结
通过上面的分析，我们已经大概了解了Android启动，初始化Flutter引擎的过程
