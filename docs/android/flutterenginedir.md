#Flutter引擎目录
AUTHORS
BUILD.gn
LICENSE
README.md
build
buildtools
flutter
ios_tools
out
third_party
tools

Flutter 目录二级目录:
total 96
-rw-r--r--   1 cuco  staff   525B Feb 28 11:00 AUTHORS
-rw-r--r--   1 cuco  staff   3.8K Feb 28 11:00 BUILD.gn
-rw-r--r--   1 cuco  staff   756B Feb 28 11:00 CONTRIBUTING.md
-rw-r--r--   1 cuco  staff    20K Feb 28 13:17 DEPS
-rw-r--r--   1 cuco  staff   1.5K Feb 28 11:00 LICENSE
-rw-r--r--   1 cuco  staff   1.4K Feb 28 11:00 README.md
-rw-r--r--   1 cuco  staff   6.4K Feb 28 11:00 analysis_options.yaml
drwxr-xr-x  10 cuco  staff   320B Feb 28 11:00 assets
drwxr-xr-x   5 cuco  staff   160B Feb 28 11:00 benchmarking
drwxr-xr-x   5 cuco  staff   160B Feb 28 11:00 build
drwxr-xr-x  11 cuco  staff   352B Feb 28 11:00 ci
drwxr-xr-x  10 cuco  staff   320B Feb 28 11:00 common
drwxr-xr-x   3 cuco  staff    96B Feb 28 11:00 docs
drwxr-xr-x  31 cuco  staff   992B Feb 28 11:00 flow
drwxr-xr-x   6 cuco  staff   192B Feb 28 11:45 flutter_kernel_transformers
drwxr-xr-x  61 cuco  staff   1.9K Feb 28 11:00 fml
drwxr-xr-x  10 cuco  staff   320B Feb 28 11:45 frontend_server
drwxr-xr-x   6 cuco  staff   192B Feb 28 11:00 lib
drwxr-xr-x  29 cuco  staff   928B Feb 28 11:00 runtime
drwxr-xr-x   8 cuco  staff   256B Feb 28 11:00 shell：客户端调用Flutter的文件目录，支持Android，Mac，IOS，嵌入式系统，在客户端开始会导入该目录下的包，在AndroidStudio中显示为FlutterForAndroid
drwxr-xr-x   6 cuco  staff   192B Feb 28 11:00 sky
drwxr-xr-x   8 cuco  staff   256B Feb 28 13:17 synchronization
drwxr-xr-x  15 cuco  staff   480B Feb 28 11:00 testing
drwxr-xr-x   4 cuco  staff   128B Feb 28 11:00 third_party
drwxr-xr-x  11 cuco  staff   352B Mar  4 19:32 tools
drwxr-xr-x  37 cuco  staff   1.2K Feb 28 11:00 vulkan


## Android调用libflutter.so代码/io/flutter/view/FlutterNativeView.java,App调用Flutter本地运行接口，对应Flutter中的相关源码:


FlutterNativeView平台通道数据传输需要进一步分析

make_unique  函数：/Users/cuco/engine/src/flutter/shell/platform/android/android_shell_holder.cc

RefPtr<fml::TaskRunner>：/Users/cuco/engine/src/flutter/common/task_runners.cc

MessageLoop:engine/src/flutter/shell/platform/android/android_shell_holder.cc
MakeRefCounted:/Users/cuco/engine/src/flutter/shell/platform/android/platform_view_android_jni.cc

# Flutter 初始化调用JNI方法完成初始化

## Android初始化默认编译好的Flutter代码的文件

Android代码在初始化完成flutter的文件之后，提供SurfaceView到底层进行Flutter engine 中的Skia 2d图像
同为跨平台技术，Flutter有何优势呢？

Flutter在Rlease模式下直接将Dart编译成本地机器码，避免了代码解释运行的性能消耗。
Dart本身针对高频率循环刷新（如屏幕每秒60帧）在内存层面进行了优化，使得Dart运行时在屏幕绘制实现如鱼得水。
Flutter实现了自己的图形绘制避免了Native桥接。
Flutter在应用层使用Dart进行开发，而支撑它的是用C++开发的引擎。


![pic](../assets/images/android/flutter/flutterPlatfrom.jpeg)

在下图中:
  * 1.初始化Flutter Engine 运行FlutterUI库的环境，初始化AndroidShellHolder：来管理Flutter相关的引环境
  * 2.注册SurfaceView给Flutter Eingine，提供给引擎进行绘制的画布，调用ANative_window类来连接FlutterUI和AndroidUI的桥梁

![pic](../assets/images/android/flutter/fluttersurfaceView.png)

接下来进行分析:AttachJNI中调用`std::make_unique<AndroidShellHolder>`方法创建`AndroidShellHolder`实例
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
# 在Flutter Android侧初始化是调用
AndroidShellHolder：主要是管理flutter engine 相关的入口:

  * 1.Platfrom,UI,IO,GUP线程的管理，配置参数的的加载
  * 2.创建一个线程清理虚拟机退出的清理工作
  * 3.thread_host_负责管理相关的线程
  * 4.PlatformViewAndroid的创建，负责挂历平台侧是事件处理
  * 5.Rasterizer的初始化6.MessageLoop的创建
  * 6.TaskRunners管理添加到不同平台中的线程执行
  * 7.Shell加载第三方库，Java虚拟机的创建

![pic](../assets/images/android/flutter/AndroidShellHolder.png)


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
### 创建一个线程来对Dart vm虚拟机退出后做一起扫尾工作,并且添加到ui_thread,如果is_background_view是在后台工作，也添加到GPU_Thread里面

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

### Flutter Engine要求Embeder提供四个Task Runner，Embeder指的是将引擎移植到平台的中间层代码。这四个主要的Task Runner包括：
![pic](../assets/images/android/flutter/flutterThread.jpeg)

根据当前SurfaceView是在前台还是在后台创建不同的ThreadHost对不同的线程进行统一管理

```c++
if (is_background_view) {
  thread_host_ = {thread_label, ThreadHost::Type::UI};
} else {
  thread_host_ = {thread_label, ThreadHost::Type::UI | ThreadHost::Type::GPU |
                                    ThreadHost::Type::IO};
}
```
ThreadHost类主要是创建唯一的Platform，UI，IO，GPU线程，主要用来对四个线程的宿主对象
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
`Platform Task Runner:`

    Flutter Engine的主Task Runner，类似于Android Main Thread或者iOS的Main Thread。但是需要注意他们还是有区别的。

    一般来说，一个Flutter应用启动的时候会创建一个Engine实例，Engine创建的时候会创建一个线程供Platform Runner使用。

    跟Flutter Engine的所有交互（接口调用）必须在Platform Thread进行，否则可能导致无法预期的异常。这跟iOS UI相关的操作都必须在主线程进行相类似。需要注意的是在Flutter Engine中有很多模块都是非线程安全的。

    规则很简单，对于Flutter Engine的接口调用都需保证在Platform Thread进行。

    阻塞Platform Thread不会直接导致Flutter应用的卡顿（跟iOS android主线程不同）。尽管如此，也不建议在这个Runner执行繁重的操作，长时间卡住Platform Thread应用有可能会被系统Watchdog强杀。

`UI Task Runner Thread（Dart Runner）`

    UI Task Runner用于执行Dart root isolate代码（isolate我们后面会讲到，姑且先简单理解为Dart VM里面的线程）。Root isolate比较特殊，它绑定了不少Flutter需要的函数方法，以便进行渲染相关操作。对于每一帧，引擎要做的事情有：

    Root isolate通知Flutter Engine有帧需要渲染。
    Flutter Engine通知平台，需要在下一个vsync的时候得到通知。
    平台等待下一个vsync
    对创建的对象和Widgets进行Layout并生成一个Layer Tree，这个Tree马上被提交给Flutter Engine。当前阶段没有进行任何光栅化，这个步骤仅是生成了对需要绘制内容的描述。
    创建或者更新Tree，这个Tree包含了用于屏幕上显示Widgets的语义信息。这个东西主要用于平台相关的辅助Accessibility元素的配置和渲染。
    除了渲染相关逻辑之外Root Isolate还是处理来自Native Plugins的消息，Timers，Microtasks和异步IO等操作。Root Isolate负责创建管理的Layer Tree最终决定绘制到屏幕上的内容。因此这个线程的过载会直接导致卡顿掉帧。

`GPU Task Runner`

    GPU Task Runner主要用于执行设备GPU的指令。UI Task Runner创建的Layer Tree是跨平台的，它不关心到底由谁来完成绘制。GPU Task Runner负责将Layer Tree提供的信息转化为平台可执行的GPU指令。GPU Task Runner同时负责绘制所需要的GPU资源的管理。资源主要包括平台Framebuffer，Surface，Texture和Buffers等。

    一般来说UI Runner和GPU Runner跑在不同的线程。GPU Runner会根据目前帧执行的进度去向UI Runner要求下一帧的数据，在任务繁重的时候可能会告诉UI Runner延迟任务。这种调度机制确保GPU Runner不至于过载，同时也避免了UI Runner不必要的消耗。

    建议为每一个Engine实例都新建一个专用的GPU Runner线程。

`IO Task Runner`

    前面讨论的几个Runner对于执行流畅度有比较高的要求。Platform Runner过载可能导致系统WatchDog强杀，UI和GPU Runner过载则可能导致Flutter应用的卡顿。但是GPU线程的一些必要操作，例如IO，放到哪里执行呢？答案正是IO Runner。

    IO Runner的主要功能是从图片存储（比如磁盘）中读取压缩的图片格式，将图片数据进行处理为GPU Runner的渲染做好准备。IO Runner首先要读取压缩的图片二进制数据（比如PNG，JPEG），将其解压转换成GPU能够处理的格式然后将数据上传到GPU。

    获取诸如ui.Image这样的资源只有通过async call去调用，当调用发生的时候Flutter Framework告诉IO Runner进行加载的异步操作。

    IO Runner直接决定了图片和其它一些资源加载的延迟间接影响性能。所以建议为IO Runner创建一个专用的线程。


Shell类的实现:



## 初始化消息队列在AndroidShellHolder
```c++
    // Copyright 2013 The Flutter Authors. All rights reserved.
    // Use of this source code is governed by a BSD-style license that can be
    // found in the LICENSE file.

    #include "flutter/fml/message_loop.h"

    #include <utility>

    #include "flutter/fml/memory/ref_counted.h"
    #include "flutter/fml/memory/ref_ptr.h"
    #include "flutter/fml/message_loop_impl.h"
    #include "flutter/fml/task_runner.h"
    #include "flutter/fml/thread_local.h"

    namespace fml {
    // 使用本地线程对象保存不同ioslate的消息队列信息
    FML_THREAD_LOCAL ThreadLocal tls_message_loop([](intptr_t value) {
      delete reinterpret_cast<MessageLoop*>(value);
    });
    // 获取当前的线程信息
    MessageLoop& MessageLoop::GetCurrent() {
      auto* loop = reinterpret_cast<MessageLoop*>(tls_message_loop.Get());
      FML_CHECK(loop != nullptr)
          << "MessageLoop::EnsureInitializedForCurrentThread was not called on "
             "this thread prior to message loop use.";
      return *loop;
    }

    void MessageLoop::EnsureInitializedForCurrentThread() {
      if (tls_message_loop.Get() != 0) {
        // Already initialized.
        return;
      }
      tls_message_loop.Set(reinterpret_cast<intptr_t>(new MessageLoop()));
    }

    bool MessageLoop::IsInitializedForCurrentThread() {
      return tls_message_loop.Get() != 0;
    }
    // 创建消息队列
    MessageLoop::MessageLoop()
        : loop_(MessageLoopImpl::Create()),
          task_runner_(fml::MakeRefCounted<fml::TaskRunner>(loop_)) {
      FML_CHECK(loop_);
      FML_CHECK(task_runner_);
    }

    MessageLoop::~MessageLoop() = default;

    void MessageLoop::Run() {
      loop_->DoRun();
    }

    void MessageLoop::Terminate() {
      loop_->DoTerminate();
    }

    fml::RefPtr<fml::TaskRunner> MessageLoop::GetTaskRunner() const {
      return task_runner_;
    }

    fml::RefPtr<MessageLoopImpl> MessageLoop::GetLoopImpl() const {
      return loop_;
    }

    void MessageLoop::AddTaskObserver(intptr_t key, fml::closure callback) {
      loop_->AddTaskObserver(key, callback);
    }

    void MessageLoop::RemoveTaskObserver(intptr_t key) {
      loop_->RemoveTaskObserver(key);
    }

    void MessageLoop::RunExpiredTasksNow() {
      loop_->RunExpiredTasksNow();
    }

    }  // namespace fml


```

使用本地线程对象保存不同ioslate的消息队列信息,使用`ThreadLocal`进行消息循环的保存
```c++
  FML_THREAD_LOCAL ThreadLocal tls_message_loop([](intptr_t value) {
    delete reinterpret_cast<MessageLoop*>(value);
  });
```
初始化MessageLoop:
```c++
// 创建消息队列
MessageLoop::MessageLoop()
    : loop_(MessageLoopImpl::Create()),
      task_runner_(fml::MakeRefCounted<fml::TaskRunner>(loop_)) {
  FML_CHECK(loop_);
  FML_CHECK(task_runner_);
}
```

message_loop_impl是MessageLoop的实现类，真正管理消息的类`engine/src/flutter/fml/message_loop_impl.cc`,对不同的平台的具体实现
```c++
// 导入不同平台的具体实现

#if OS_MACOSX
#include "flutter/fml/platform/darwin/message_loop_darwin.h"
#elif OS_ANDROID
#include "flutter/fml/platform/android/message_loop_android.h"
#elif OS_LINUX
#include "flutter/fml/platform/linux/message_loop_linux.h"
#elif OS_WIN
#include "flutter/fml/platform/win/message_loop_win.h"
#endif
// 创建不同平台的具体实现
fml::RefPtr<MessageLoopImpl> MessageLoopImpl::Create() {
#if OS_MACOSX
  return fml::MakeRefCounted<MessageLoopDarwin>();
#elif OS_ANDROID
  return fml::MakeRefCounted<MessageLoopAndroid>();
#elif OS_LINUX
  return fml::MakeRefCounted<MessageLoopLinux>();
#elif OS_WIN
  return fml::MakeRefCounted<MessageLoopWin>();
#else
  return nullptr;
#endif
}
```
```c++
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#define FML_USED_ON_EMBEDDER

#include "flutter/fml/message_loop_impl.h"

#include <algorithm>
#include <vector>

#include "flutter/fml/build_config.h"
#include "flutter/fml/logging.h"
#include "flutter/fml/trace_event.h"

#if OS_MACOSX
#include "flutter/fml/platform/darwin/message_loop_darwin.h"
#elif OS_ANDROID
#include "flutter/fml/platform/android/message_loop_android.h"
#elif OS_LINUX
#include "flutter/fml/platform/linux/message_loop_linux.h"
#elif OS_WIN
#include "flutter/fml/platform/win/message_loop_win.h"
#endif

namespace fml {
// 使用编译命令来标记加载不同平台的消息队列
fml::RefPtr<MessageLoopImpl> MessageLoopImpl::Create() {
#if OS_MACOSX
  return fml::MakeRefCounted<MessageLoopDarwin>();
#elif OS_ANDROID
  return fml::MakeRefCounted<MessageLoopAndroid>();
#elif OS_LINUX
  return fml::MakeRefCounted<MessageLoopLinux>();
#elif OS_WIN
  return fml::MakeRefCounted<MessageLoopWin>();
#else
  return nullptr;
#endif
}

MessageLoopImpl::MessageLoopImpl() : order_(0), terminated_(false) {}

MessageLoopImpl::~MessageLoopImpl() = default;

void MessageLoopImpl::PostTask(fml::closure task, fml::TimePoint target_time) {
  FML_DCHECK(task != nullptr);
  RegisterTask(task, target_time);
}

void MessageLoopImpl::RunExpiredTasksNow() {
  RunExpiredTasks();
}

void MessageLoopImpl::AddTaskObserver(intptr_t key, fml::closure callback) {
  FML_DCHECK(callback != nullptr);
  FML_DCHECK(MessageLoop::GetCurrent().GetLoopImpl().get() == this)
      << "Message loop task observer must be added on the same thread as the "
         "loop.";
  task_observers_[key] = std::move(callback);
}

void MessageLoopImpl::RemoveTaskObserver(intptr_t key) {
  FML_DCHECK(MessageLoop::GetCurrent().GetLoopImpl().get() == this)
      << "Message loop task observer must be removed from the same thread as "
         "the loop.";
  task_observers_.erase(key);
}

void MessageLoopImpl::DoRun() {
  if (terminated_) {
    // Message loops may be run only once.
    return;
  }

  // Allow the implementation to do its thing.
  Run();

  // The loop may have been implicitly terminated. This can happen if the
  // implementation supports termination via platform specific APIs or just
  // error conditions. Set the terminated flag manually.
  terminated_ = true;

  // The message loop is shutting down. Check if there are expired tasks. This
  // is the last chance for expired tasks to be serviced. Make sure the
  // terminated flag is already set so we don't accrue additional tasks now.
  RunExpiredTasksNow();

  // When the message loop is in the process of shutting down, pending tasks
  // should be destructed on the message loop's thread. We have just returned
  // from the implementations |Run| method which we know is on the correct
  // thread. Drop all pending tasks on the floor.
  std::lock_guard<std::mutex> lock(delayed_tasks_mutex_);
  delayed_tasks_ = {};
}

void MessageLoopImpl::DoTerminate() {
  terminated_ = true;
  Terminate();
}

void MessageLoopImpl::RegisterTask(fml::closure task,
                                   fml::TimePoint target_time) {
  FML_DCHECK(task != nullptr);
  if (terminated_) {
    // If the message loop has already been terminated, PostTask should destruct
    // |task| synchronously within this function.
    return;
  }
  std::lock_guard<std::mutex> lock(delayed_tasks_mutex_);
  delayed_tasks_.push({++order_, std::move(task), target_time});
  WakeUp(delayed_tasks_.top().target_time);
}
// 运行期望的任务
void MessageLoopImpl::RunExpiredTasks() {
  TRACE_EVENT0("fml", "MessageLoop::RunExpiredTasks");
  std::vector<fml::closure> invocations;

  {
    std::lock_guard<std::mutex> lock(delayed_tasks_mutex_);

    if (delayed_tasks_.empty()) {
      return;
    }

    auto now = fml::TimePoint::Now();
    // 比较任务的时间
    while (!delayed_tasks_.empty()) {
      const auto& top = delayed_tasks_.top();
      if (top.target_time > now) {
        break;
      }
      // 如果队列中的时间大于当前时间，发到队列尾部
      invocations.emplace_back(std::move(top.task));
      delayed_tasks_.pop();
    }

    WakeUp(delayed_tasks_.empty() ? fml::TimePoint::Max()
                                  : delayed_tasks_.top().target_time);
  }

  for (const auto& invocation : invocations) {
    invocation();
    for (const auto& observer : task_observers_) {
      observer.second();
    }
  }
}

MessageLoopImpl::DelayedTask::DelayedTask(size_t p_order,
                                          fml::closure p_task,
                                          fml::TimePoint p_target_time)
    : order(p_order), task(std::move(p_task)), target_time(p_target_time) {}

MessageLoopImpl::DelayedTask::DelayedTask(const DelayedTask& other) = default;

MessageLoopImpl::DelayedTask::~DelayedTask() = default;

}  // namespace fml

```


`GetPlatformView`：

  fml::WeakPtr<PlatformView> Shell::GetPlatformView() {
  FML_DCHECK(is_setup_);
  return platform_view_->GetWeakPtr();
  }

`engine/src/flutter/shell/platform/android/platform_view_android.cc`处理Android中View事件的类
`fml::MessageLoop::EnsureInitializedForCurrentThread();`engine/src/flutter/shell/platform/android/android_shell_holder.cc构造函数中初始化消息队列

2.创建一个线程清理虚拟机退出的清理工作

    // 创建一个线程清理虚拟机退出的清理工作
    FML_CHECK(pthread_key_create(&thread_destruct_key_, ThreadDestructCallback) ==
            0);
    .....

    // Detach from JNI when the UI and GPU threads exit.
    auto jni_exit_task([key = thread_destruct_key_]() {
    FML_CHECK(pthread_setspecific(key, reinterpret_cast<void*>(1)) == 0);
    });
    thread_host_.ui_thread->GetTaskRunner()->PostTask(jni_exit_task);
    if (!is_background_view) {
    thread_host_.gpu_thread->GetTaskRunner()->PostTask(jni_exit_task);
    }

3.ThreadHost类来管理Flutter engine的Platform，io，GPU，UI线程

  `engine/src/flutter/shell/platform/android/android_shell_holder.cc`

    if (is_background_view) {
    thread_host_ = {thread_label, ThreadHost::Type::UI};
    } else {
    thread_host_ = {thread_label, ThreadHost::Type::UI | ThreadHost::Type::GPU |
                                    ThreadHost::Type::IO};
    }

`/engine/src/flutter/shell/common/thread_host.cc`

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

4.初始化消息队列：fml::MessageLoop::EnsureInitializedForCurrentThread();消息队列初始化完成，使用TaskRunners类来管理相关的Platform，UI，IO，GPU相关的任务相关引用`RefPtr<fml::TaskRunner>`

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

## Shell 类的初始化，主要负责管理客户端相关的资源`/engine/src/flutter/shell/platform/android/android_shell_holder.cc`,创建的地方

  shell_ =
      Shell::Create(task_runners,             // task runners
                    settings_,                // settings
                    on_create_platform_view,  // platform view create callback
                    on_create_rasterizer      // rasterizer create callback
      );
在Shell创建时

    std::unique_ptr<Shell> Shell::Create(
        blink::TaskRunners task_runners,
        blink::Settings settings,
        Shell::CreateCallback<PlatformView> on_create_platform_view,
        Shell::CreateCallback<Rasterizer> on_create_rasterizer) {
      //初始化第三方库
      PerformInitializationTasks(settings);

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


Shell创建时第三方库初始化位置`PerformInitializationTasks`,`/engine/src/flutter/shell/common/shell.cc`

    `RecordStartupTimestamp();` 记录时间戳
    `fml::SetLogSettings(log_settings);`  设置日志信息
    `InitSkiaEventTracer(settings.trace_skia);` 初始化Skia2d图像引擎库跟踪器
    `SkGraphics::Init();`   初始化2d图形引擎库
    `fml::icu::InitializeICU(settings.icu_data_path);` 初始化国际化处理ICU


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

Dart VM 虚拟机在Shell创建的时候初始化：`auto vm = blink::DartVM::ForProcess(settings);`,`/engine/src/flutter/shell/common/shell.cc`,Shell::Create，Dart虚拟机的分析，在后续在进行扩展


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

# Shell创建所需要的在这个类里面进行初始化`CreateShellOnPlatformThread`对Shell对应的platefrom,IO,GPU,UI,`/engine/src/flutter/shell/common/shell.cc`

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
      fml::TaskRunner::RunNowOrPostTask(
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

`CreateShellOnPlatformThread`完成Shell分割的一下初始化信息

  1.创建一个Shell实例对象`auto shell = std::unique_ptr<Shell>(new Shell(task_runners, settings));`
  2.创建平台View在平台线程`auto platform_view = on_create_platform_view(*shell.get());`
  3.创建一个Syncwaiter`auto vsync_waiter = platform_view->CreateVSyncWaiter();`
  4.创建一个IO管理io线程`std::unique_ptr<IOManager> io_manager;`
  5.在UI线程创建engine：`fml::AutoResetWaitableEvent ui_latch;`

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


设置Shell管理的Platform线程管理的相关资源:`/engine/src/flutter/shell/common/engine.cc`在`/engine/src/flutter/shell/common/shell.cc`中执行`CreateShellOnPlatformThread`方法时调用

    1.PlatformView:主要管理相关的view事件
    2.Engine:所有的资源都准备完成，开始调用dart代码和Dart虚拟机，进行代码执行
    3.Rasterizer:光栅主要是处理GPU相关的事件
    4.IOManager:对io线程进行管理
    5.shez DartVM ServiceProtocol设置处理回调
    6.PersistentCache::GetCacheForProcess()->AddWorkerTaskRunner(task_runners_.GetIOTaskRunner());对缓存目录的处理

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


### Android Native层与libFlutter通信接口:
`engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`

    private static native long nativeAttach(FlutterNativeView var0, boolean var1);

    private static native void nativeDestroy(long var0);

    private static native void nativeDetach(long var0);

    private static native void nativeRunBundleAndSnapshotFromLibrary(long var0, String var2, String var3, String var4, String var5, AssetManager var6);

    private static native String nativeGetObservatoryUri();

    private static native void nativeDispatchEmptyPlatformMessage(long var0, String var2, int var3);

    private static native void nativeDispatchPlatformMessage(long var0, String var2, ByteBuffer var3, int var4, int var5);

    private static native void nativeInvokePlatformMessageEmptyResponseCallback(long var0, int var2);

    private static native void nativeInvokePlatformMessageResponseCallback(long var0, int var2, ByteBuffer var3, int var4);

引擎元代码中使用动态JNI的方式注册相关方法:
`engine/src/flutter/shell/platform/android/platform_view_android_jni.cc`

调用Register方法注册本地方法：

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









### Flutter 层调用JIN方法
### 调用本地方法传输数据
`flutter/bin/cache/pkg/sky_engine/lib/ui/window.dart`

    String _sendPlatformMessage(String name,
    PlatformMessageResponseCallback callback,
    ByteData data) native 'Window_sendPlatformMessage';

    /// Called whenever this window receives a message from a platform-specific
    /// plugin.
    ///
    /// The `name` parameter determines which plugin sent the message. The `data`
    /// parameter is the payload and is typically UTF-8 encoded JSON but can be
    /// arbitrary data.
    ///
    /// Message handlers must call the function given in the `callback` parameter.
    /// If the handler does not need to respond, the handler should pass null to
    /// the callback.
    ///
    /// The framework invokes this callback in the same zone in which the
    /// callback was set.
    PlatformMessageCallback get onPlatformMessage => _onPlatformMessage;
    PlatformMessageCallback _onPlatformMessage;
    Zone _onPlatformMessageZone;
    set onPlatformMessage(PlatformMessageCallback callback) {
    _onPlatformMessage = callback;
    _onPlatformMessageZone = Zone.current;
    }

    /// Called by [_dispatchPlatformMessage].
    void _respondToPlatformMessage(int responseId, ByteData data)
    native 'Window_respondToPlatformMessage';



`engine/src/flutter/lib/ui/window/window.cc`

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

    }  // namespace blink
