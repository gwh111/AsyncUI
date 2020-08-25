//
//  AsyncTask.m
//  AsyncUI
//
//  Created by gwh on 2020/8/10.
//  Copyright © 2020 gwh. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AsyncTask.h"
#include <stdatomic.h>

#import <os/lock.h>
os_unfair_lock queueLock;
static NSMapTable *queueKey;

#define MAX_QUEUE_COUNT 32
atomic_int acnt;

//#import "QiStackFrameLogger.h"

static inline qos_class_t NSQualityOfServiceToQOSClass(NSOperationQueuePriority qos) {
    switch (qos) {
        case NSOperationQueuePriorityVeryHigh: return QOS_CLASS_USER_INTERACTIVE;
        case NSOperationQueuePriorityHigh: return QOS_CLASS_USER_INITIATED;
        case NSOperationQueuePriorityNormal: return QOS_CLASS_DEFAULT;
        case NSOperationQueuePriorityLow: return QOS_CLASS_UTILITY;
        case NSOperationQueuePriorityVeryLow: return QOS_CLASS_BACKGROUND;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

typedef struct {
    const char *name;
    void **queues;
    uint32_t queueCount;
} AsyncTaskDispatchContext;

static AsyncTaskDispatchContext *AsyncTaskDispatchContextCreate(const char *name,
                                                 uint32_t queueCount,
                                                 NSOperationQueuePriority qos) {
    AsyncTaskDispatchContext *context = (AsyncTaskDispatchContext *)calloc(1, sizeof(AsyncTaskDispatchContext));
    if (!context) return NULL;
    context->queues = (void **)calloc(queueCount, sizeof(void *));
    if (!context->queues) {
        free(context);
        return NULL;
    }
    dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);
    for (NSUInteger i = 0; i < queueCount; i++) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
        dispatch_queue_t queue = dispatch_queue_create(name, attr);
        context->queues[i] = (__bridge_retained void *)(queue);
    }
    context->queueCount = queueCount;
    if (name) {
         context->name = strdup(name);
    }
    return context;
}

static dispatch_queue_t AsyncTaskDispatchContextGetQueue(AsyncTaskDispatchContext *context) {
    atomic_fetch_add_explicit(&acnt, 1, memory_order_relaxed);
    void *queue = context->queues[acnt % context->queueCount];
    return (__bridge dispatch_queue_t)(queue);
}

static AsyncTaskDispatchContext *AsyncTaskDispatchContextGetForPriority(NSOperationQueuePriority priority) {
    static AsyncTaskDispatchContext *context[5] = {0};
    switch (priority) {
        case NSOperationQueuePriorityVeryLow: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = AsyncTaskDispatchContextCreate("verylow", count, priority);
            });
            return context[0];
        } break;
        case NSOperationQueuePriorityLow: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = AsyncTaskDispatchContextCreate("low", count, priority);
            });
            return context[1];
        } break;
        case NSOperationQueuePriorityNormal: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = AsyncTaskDispatchContextCreate("normal", count, priority);
            });
            return context[2];
        } break;
        case NSOperationQueuePriorityHigh: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = AsyncTaskDispatchContextCreate("hight", count, priority);
            });
            return context[3];
        } break;
        case NSOperationQueuePriorityVeryHigh:
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = AsyncTaskDispatchContextCreate("veryhigh", count, priority);
            });
            return context[4];
        } break;
    }
}



@interface AsyncTask () {
    CFRunLoopRef _runLoop;
    CFRunLoopSourceRef _runLoopSource;
    CFRunLoopObserverRef _runLoopObserver;
    NSPointerArray *_internalQueue;
}

@property(nonatomic, retain) CADisplayLink *displayLink;

@end

@implementation AsyncTask

static dispatch_once_t once;
static AsyncTask *userManger = nil;

+ (instancetype)shared {
    dispatch_once(&once, ^{
        userManger = [[AsyncTask alloc]init];
        [userManger setup];
    });
    return userManger;
}

+ (void)load {
    #if DEBUG
    [AsyncTask shared];
    #endif
}

- (void)screenRenderCall {
    __block BOOL flag = YES;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block int count = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        flag = NO;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 33.3*NSEC_PER_MSEC));
    if (flag) {
        count++;
        flag = NO;
        id class = NSClassFromString(@"QiStackFrameLogger");
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        id result = [class performSelector:@selector(qi_backtraceOfMainThread)];
        #pragma clang diagnostic pop
        CCLOG(@"\n------   Main Thread Stuck   ------%fms\n%@\n\n", count * 33.3, result);
        sleep(1);
    } else {
        count = 0;
    }
}

- (void)setup {
    
    if (!NSThread.isMainThread) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setup];
        });
        return;
    }
    
    _maxTaskInOneRunloop = 12;
    
    NSPointerFunctionsOptions options = NSPointerFunctionsStrongMemory;
    _internalQueue = [[NSPointerArray alloc] initWithOptions:options];
    
    _runLoop = CFRunLoopGetMain();
    
    #if DEBUG
    _FPSMonitorOn = YES;
    #endif
    
    if (_FPSMonitorOn) {
        asyncTaskRunPriority(^{
            CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector: @selector(screenRenderCall)];
            [self.displayLink invalidate];
            self.displayLink = displayLink;

            [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, CGFLOAT_MAX, NO);
        }, NSOperationQueuePriorityLow);
    }
    
    // Self is guaranteed to outlive the observer.  Without the high cost of a weak pointer,
    // unowned(__unsafe_unretained) allows us to avoid flagging the memory cycle detector.
    __unsafe_unretained __typeof__(self) weakSelf = self;
    void (^handlerBlock) (CFRunLoopObserverRef observer, CFRunLoopActivity activity) = ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        [weakSelf processQueue];
    };
    _runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, true, 0, handlerBlock);
    CFRunLoopAddObserver(_runLoop, _runLoopObserver,  kCFRunLoopCommonModes);
    
    // It is not guaranteed that the runloop will turn if it has no scheduled work, and this causes processing of
    // the queue to stop. Attaching a custom loop source to the run loop and signal it if new work needs to be done
    CFRunLoopSourceContext sourceContext = {};
    sourceContext.perform = runLoopSourceCallback;
#if ASRunLoopQueueLoggingEnabled
    sourceContext.info = (__bridge void *)self;
#endif
    _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &sourceContext);
    CFRunLoopAddSource(CFRunLoopGetMain(), _runLoopSource, kCFRunLoopCommonModes);
    
}

- (void)processQueue {
    
    NSInteger maxCountToProcess = MIN(_internalQueue.count, self.maxTaskInOneRunloop);
    for (int i = 0; i < maxCountToProcess; i++) {
        /**
         * It is safe to use unsafe_unretained here. If the queue is weak, the
         * object will be added to the autorelease pool. If the queue is strong,
         * it will retain the object until we transfer it (retain it) in itemsToProcess.
         */
        
        id ptr = (__bridge id)[_internalQueue pointerAtIndex:i];
        
        void(^tempBlock)(void) = ptr;
        if (ptr) {
            tempBlock();
            [_internalQueue replacePointerAtIndex:i withPointer:NULL];
         }
        
    }
    [_internalQueue compact];
    
    if (_internalQueue.count > 0) {
        CFRunLoopSourceSignal(_runLoopSource);
        CFRunLoopWakeUp(_runLoop);
    }

}

static void runLoopSourceCallback(void *info) {
  // No-op
#if ASRunLoopQueueVerboseLoggingEnabled
  NSLog(@"<%@> - Called runLoopSourceCallback", info);
#endif
}

- (void)mainRunloopBeforeWaitingRun:(void(^)(void))block {

    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mainRunloopBeforeWaitingRun:block];
        });
        return;
    }
    
    /* As the 'dispatch_block_t' demonstrates, the address of a stack variable is escaping the
    * scope in which it is allocated. That is a classic C bug.
    *
    * Instead, the block literal must be copied to the heap with the Block_copy()
    * function or by sending it a -[copy] message.
    */
    // keep block to copy block from stack to malloc
    id bbb = block;
    _Block_copy((__bridge const void *)(bbb));
    [_internalQueue addPointer:(__bridge void * _Nullable)bbb];
    _Block_release((__bridge const void *)(bbb));
    
    //We have source in main runloop，no need to add new source.
    // CFArrayRef arr = CFRunLoopCopyAllModes(_runLoop);
    CFRunLoopWakeUp(_runLoop);
    
}

@end

void asyncTaskMain(asyncTask_block_t block) {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

void asyncTaskRun(asyncTask_block_t block) {
    dispatch_queue_t q = AsyncTaskDispatchQueueGetForPriority(NSOperationQueuePriorityNormal, nil);
    dispatch_async(q, ^{
        block();
    });
}

void asyncTaskRunPriority(asyncTask_block_t block, NSOperationQueuePriority priority) {
    dispatch_queue_t q = AsyncTaskDispatchQueueGetForPriority(priority, nil);
    dispatch_async(q, ^{
        block();
    });
}

void asyncTaskRunPriorityQueue(asyncTask_block_t block, NSOperationQueuePriority priority, const char *queueName) {
    dispatch_queue_t q = AsyncTaskDispatchQueueGetForPriority(priority, [NSString stringWithUTF8String:queueName]);
    dispatch_async(q, ^{
        block();
    });
}

void asyncTaskMainRunloopBeforeWaitingRun(asyncTask_block_t block) {
    [AsyncTask.shared mainRunloopBeforeWaitingRun:block];
}

typedef struct {
    uint32_t index;
    bool occupied;
} AsyncTaskQueueContext;

dispatch_queue_t AsyncTaskDispatchQueueGetForPriority(NSOperationQueuePriority priority, NSString * _Nullable name) {

    if (name.length <= 0) {
        return AsyncTaskDispatchContextGetQueue(AsyncTaskDispatchContextGetForPriority(priority));
    }
    if (!queueKey) {
        queueKey = NSMapTable.alloc.init;
    }
    AsyncTaskDispatchContext *context = AsyncTaskDispatchContextGetForPriority(priority);
    NSNumber *index;
    os_unfair_lock_lock(&queueLock);
    if (![queueKey objectForKey:name]) {
//        AsyncTaskQueueContext *queue = (AsyncTaskQueueContext *)calloc(1, sizeof(AsyncTaskQueueContext));
//        queue->index = context->queueCount;
//        queue->occupied = true;
        index = [NSNumber numberWithInteger:arc4random()%context->queueCount];
        [queueKey setObject:index forKey:name];
    } else {
        index = [queueKey objectForKey:name];
    }
    os_unfair_lock_unlock(&queueLock);
    return (__bridge dispatch_queue_t)context->queues[index.intValue];
}
