//
//  UIView+Async.m
//  testdemo
//
//  Created by dhmac on 2020/8/18.
//  Copyright © 2020 dhmac. All rights reserved.
//

#import "UIView+Async.h"
#import "AsyncTask.h"
#import <objc/runtime.h>

@interface UIView()

@property(nonatomic, assign) BOOL alreadyMake;

@end

@implementation UIView (Async)

- (void)setAsyncUniqueTag:(int)asyncUniqueTag {
    objc_setAssociatedObject(self, @selector(asyncUniqueTag), @(asyncUniqueTag), OBJC_ASSOCIATION_RETAIN);
}

- (int)asyncUniqueTag {
    return [objc_getAssociatedObject(self, @selector(asyncUniqueTag)) intValue];
}

- (void)setAsyncName:(NSString *)asyncName {
    objc_setAssociatedObject(self, @selector(asyncName), asyncName, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)asyncName {
    return objc_getAssociatedObject(self, @selector(asyncName));
}

- (void)setAlreadyMake:(BOOL)alreadyMake {
    objc_setAssociatedObject(self, @selector(alreadyMake), @(alreadyMake), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)alreadyMake {
    return [objc_getAssociatedObject(self, @selector(alreadyMake)) boolValue];
}

- (void)setStateless:(BOOL)stateless {
    objc_setAssociatedObject(self, @selector(stateless), @(stateless), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)stateless {
    return [objc_getAssociatedObject(self, @selector(stateless)) boolValue];
}

- (__kindof UIView *)commit_make:(void(^)(__kindof UIView *view))block {
    
    if (self.alreadyMake) {
        return self;
    }
    self.alreadyMake = YES;
    
    __block UIView *view = self;
    
    AsyncTask *task = AsyncTask.shared;
    [task mainRunloopBeforeWaitingRun:^{
        
        view = view.init;
        block(view);

        if (view.stateless) {
            [self _updateStatelessView:view];
        }
        
    }];
    return view;
}

- (__kindof UIView *)commit_update:(void(^)(__kindof UIView *view))block {
    
    NSAssert(!self.stateless, @"can not commit_update to stateless view.");

    __block UIView *view = self;
    
    AsyncTask *task = AsyncTask.shared;
    [task mainRunloopBeforeWaitingRun:^{
        
        block(view);
    }];
    return view;
}

- (__kindof UIView *)commit_remake:(void(^)(__kindof UIView *view))block {

    __block UIView *view = self;
    
    AsyncTask *task = AsyncTask.shared;
    [task mainRunloopBeforeWaitingRun:^{
        
        view = view.init;
        block(view);
        
        if (view.stateless) {
            [self _updateStatelessView:view];
        }
    }];
    return view;
}

- (void)_updateStatelessView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, UIScreen.mainScreen.scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    view.layer.contents = (__bridge id _Nullable)(img.CGImage);
    view.backgroundColor = nil;
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
