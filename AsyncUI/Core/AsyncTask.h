//
//  AsyncTask.h
//  testdemo
//
//  Created by dhmac on 2020/8/10.
//  Copyright © 2020 dhmac. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AsyncTask_h
#define AsyncTask_h

NS_ASSUME_NONNULL_BEGIN

typedef void (^asyncTask_block_t)(void);

/**
* I'd like to manage concurrent queue myself, I don't use 'DISPATCH_QUEUE_CONCURRENT' because it will make multy-thread in a 'for' loop, that's terriable. So we make several serial queue and let them work in alternate. So we can limit thread count and not exponential explosion in a second.
*
*/

void asyncTaskRun(asyncTask_block_t block);

// Back to main queue with 'dispatch_async'
void asyncTaskMain(asyncTask_block_t block);

// We do not want to make a copy of Priority level so we use 'NSOperationQueuePriority' as standard.
void asyncTaskRunPriority(asyncTask_block_t block, NSOperationQueuePriority priority);

// Use a serial queue with percific queueName to run task.
void asyncTaskRunPriorityQueue(asyncTask_block_t block, NSOperationQueuePriority priority, const char *queueName);

// Make task run in next main runloop.
void asyncTaskMainRunloopBeforeWaitingRun(asyncTask_block_t block);

/// Get a serial queue from global queue pool with a specified priority.
extern dispatch_queue_t AsyncTaskDispatchQueueGetForPriority(NSOperationQueuePriority priority, NSString * _Nullable name);

@interface AsyncTask : NSObject

+ (instancetype)shared;

// As call 'asyncTaskMainRunloopBeforeWaitingRun', task will be commited in runloop and execute in 'beforewaiting', set max task commited in one runloop, if still tasks, will be commit in next runloop.
@property (nonatomic, assign) NSUInteger maxTaskInOneRunloop;//default is 12

- (void)mainRunloopBeforeWaitingRun:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END

#endif
