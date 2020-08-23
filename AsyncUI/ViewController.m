//
//  ViewController.m
//  AsyncUI
//
//  Created by gwh on 2020/8/23.
//  Copyright © 2020 gwh. All rights reserved.
//

#import "ViewController.h"
#import "AsyncUI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // exp1:
    // 执行一个异步任务
    asyncTaskRun(^{
        NSLog(@"asyncTaskRun %@",NSThread.currentThread);
        asyncTaskMain(^{
            // 回到主线程
        });
    });

    // exp2:
    // 带优先级的异步任务
    asyncTaskRunPriority(^{
        NSLog(@"NSOperationQueuePriorityVeryLow %@",NSThread.currentThread);
    }, NSOperationQueuePriorityVeryLow);
    asyncTaskRunPriority(^{
        NSLog(@"NSOperationQueuePriorityVeryHigh %@",NSThread.currentThread);
    }, NSOperationQueuePriorityVeryHigh);
    /* result:
        NSOperationQueuePriorityVeryHigh <NSThread: 0x600000d58180>{number = 5, name = (null)}
        NSOperationQueuePriorityVeryLow <NSThread: 0x600000d1d640>{number = 3, name = (null)}
     */

    // exp3:
    // 用断点观察线程数 使app线程数维持在适当水平
    for (int i = 0; i < 1000; i++) {
        // Max Thread 83
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"%d",i);
        });
    }
    for (int i = 0; i < 1000; i++) {
        // Max Thread 16
        asyncTaskRun(^{
            NSLog(@"%d",i);
        });
    }

    // exp4:
    // 异步任务在同一队列q1执行 返回结果到主线程
    for (int i = 0; i < 5; i++) {
        asyncTaskRunPriorityQueue(^{
            NSLog(@"q1%@",NSThread.currentThread);
            NSString *task = [NSString stringWithFormat:@"task%i",i];
            asyncTaskMain(^{
                NSLog(@"q1%@",task);
            });
        }, NSOperationQueuePriorityNormal, "q1");
        
    }
    /* result:
        q1<NSThread: 0x60000157c9c0>{number = 5, name = (null)}
        q1<NSThread: 0x60000157c9c0>{number = 5, name = (null)}
        q1<NSThread: 0x60000157c9c0>{number = 5, name = (null)}
        q1<NSThread: 0x60000157c9c0>{number = 5, name = (null)}
        q1<NSThread: 0x60000157c9c0>{number = 5, name = (null)}
        q1task0
        q1task1
        q1task2
        q1task3
        q1task4
     */

     // exp5:
     // 在子线程创建ui 获取ui控件唯一id
    for (int i = 0; i < 100; i++) {
        asyncTaskRun(^{
            UIView *view1 = AsyncUIView();
            [view1 commit_make:^(__kindof UIView *view) {
              view.frame = CGRectMake(0, 0, 30, 30);
              view.backgroundColor = UIColor.brownColor;
    //              [self.view addSubview:view];
                
              int asyncUniqueTag = view.asyncUniqueTag;
              NSLog(@"asyncUniqueTag%d",asyncUniqueTag);
            }];
        });
    }

    // exp6:
    // 合并图层 减低ui控件数量
    [AsyncUILabel() commit_make:^(UILabel *label) {
        label.frame = CGRectMake(50, 230, 100, 100);
        label.backgroundColor = UIColor.systemPinkColor;
        [self.view addSubview:label];
        
        UILabel *l = UILabel.new;
        l.backgroundColor = UIColor.greenColor;
        l.frame = CGRectMake(0, 0, 50, 50);
        l.text = @"aa";
        [label addSubview:l];
        
        UILabel *l2 = UILabel.new;
        l2.backgroundColor = UIColor.yellowColor;
        l2.frame = CGRectMake(60, 0, 30, 50);
        l2.text = @"bb";
        [label addSubview:l2];
        
        UILabel *l3 = UILabel.new;
        l3.backgroundColor = UIColor.blueColor;
        l3.frame = CGRectMake(00, 0, 30, 10);
        l3.text = @"cc";
        [l2 addSubview:l3];
        
    }];
    [AsyncUILabel() commit_make:^(UILabel *label) {
        label.stateless = YES;
        
        label.frame = CGRectMake(200, 230, 100, 100);
        label.backgroundColor = UIColor.systemPinkColor;
        [self.view addSubview:label];
        
        UILabel *l = UILabel.new;
        l.backgroundColor = UIColor.greenColor;
        l.frame = CGRectMake(0, 0, 50, 50);
        l.text = @"aa";
        [label addSubview:l];
        
        UILabel *l2 = UILabel.new;
        l2.backgroundColor = UIColor.yellowColor;
        l2.frame = CGRectMake(60, 0, 30, 50);
        l2.text = @"bb";
        [label addSubview:l2];
        
        UILabel *l3 = UILabel.new;
        l3.backgroundColor = UIColor.blueColor;
        l3.frame = CGRectMake(00, 0, 30, 10);
        l3.text = @"cc";
        [l2 addSubview:l3];
    }];
    /* result:
        只剩下一个绘制完全部子view的UILabel
     */
}


@end
