//
//  UIImageView+Async.m
//  AsyncUI
//
//  Created by dhmac on 2020/9/8.
//  Copyright © 2020 gwh. All rights reserved.
//

#import "UIImageView+Async.h"

@implementation UIImageView (Async)

- (void)setScaleToFillImage:(UIImage *)image {
    
    self.contentMode = UIViewContentModeScaleToFill;
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGSize newSize = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = newImage;
}

- (void)setAspectFillImage:(UIImage *)image {
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    CGImageRef imageRef = nil;
    CGSize imgSize = image.size;
    CGSize selfSize = self.frame.size;
    CGFloat rate = 0.5;
    CGFloat widthRate = imgSize.width/selfSize.width;
    CGFloat heightRate = imgSize.height/selfSize.height;
    
    if (heightRate > widthRate) {
        rate = widthRate;
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, imgSize.height/2-selfSize.height*rate/2, imgSize.width, selfSize.height*rate));
    } else {
        rate = heightRate;
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(imgSize.width/2-selfSize.width*rate/2, 0, selfSize.width*rate, imgSize.height));
    }
    
    UIGraphicsBeginImageContext(selfSize);
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(con, 0.0, selfSize.height);
    CGContextScaleCTM(con, 1.0, -1.0);
    CGContextDrawImage(con, CGRectMake(0, 0, selfSize.width, selfSize.height), imageRef);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    
    self.image = newImage;
}

@end
