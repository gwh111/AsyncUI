//
//  AsyncUI.m
//  testdemo
//
//  Created by dhmac on 2020/8/18.
//  Copyright © 2020 dhmac. All rights reserved.
//

#import "AsyncUI.h"
#import "UIView+Async.h"
#import <objc/runtime.h>
#include <stdatomic.h>
atomic_int asyncUniqueTag;

@implementation AsyncUI

+ (id)initUI {
    Class class = NSClassFromString(NSStringFromSelector(_cmd));
    atomic_fetch_add_explicit(&asyncUniqueTag, 1, memory_order_relaxed);
    UIView *view = class.alloc;
    view.asyncUniqueTag = asyncUniqueTag;
    return view;
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    
    SEL aSel = NSSelectorFromString(@"initUI");
    Method aMethod = class_getClassMethod(self, aSel);
    class_addMethod(object_getClass(self), sel, method_getImplementation(aMethod), "v@:");
    return YES;
}

@end
