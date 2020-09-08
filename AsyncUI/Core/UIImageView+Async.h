//
//  UIImageView+Async.h
//  AsyncUI
//
//  Created by dhmac on 2020/9/8.
//  Copyright © 2020 gwh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Async)

@property(nonatomic, weak, getter=image) UIImage *scaleToFillImage;
@property(nonatomic, weak, getter=image) UIImage *aspectFillImage;

//- (void)setScaleToFillImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
