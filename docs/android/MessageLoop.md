[MessageLoop](https://segmentfault.com/a/1190000008800122)

初始化消息队列在ThreadHost初始化是线程关联到`MessageLoop`时进行初始化
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

```
