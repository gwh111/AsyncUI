//
//  UIView+Async.h
//  testdemo
//
//  Created by dhmac on 2020/8/18.
//  Copyright © 2020 dhmac. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIView (Async)

/* If stateless, this view's subviews will be merged into one image displayed on this view. And all the subviews will be removed.
 * Can not use 'commit_update' to stateless view.
 *
 * WARNING: currently this method does not implement the full
 * CoreAnimation composition model, use with caution. */
@property(nonatomic, assign) BOOL stateless;

@property(nonatomic, assign) int asyncUniqueTag;
@property(nonatomic, copy) NSString *asyncName;

- (__kindof UIView *)commit_make:(void(^)(__kindof UIView *view))block;
- (__kindof UIView *)commit_update:(void(^)(__kindof UIView *view))block;
- (__kindof UIView *)commit_remake:(void(^)(__kindof UIView *view))block;

//NS_ASSUME_NONNULL_END

@end


