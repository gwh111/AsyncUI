//
//  AsyncUI.h
//  testdemo
//
//  Created by dhmac on 2020/8/18.
//  Copyright © 2020 dhmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncTask.h"
#import "UIView+Async.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AsyncUIProtocol <NSObject>

@end

@interface AsyncUI : NSProxy<AsyncUIProtocol>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

static inline UIView* AsyncUIView(void) { return [AsyncUI performSelector:@selector(UIView)]; }
static inline UILabel* AsyncUILabel(void) { return [AsyncUI performSelector:@selector(UILabel)]; }
static inline UIButton* AsyncUIButton(void) { return [AsyncUI performSelector:@selector(UIButton)]; }
static inline UITextView* AsyncUITextView(void) { return [AsyncUI performSelector:@selector(UITextView)]; }
static inline UITextField* AsyncUITextField(void) { return [AsyncUI performSelector:@selector(UITextField)]; }
static inline UIImageView* AsyncUIImageView(void) { return [AsyncUI performSelector:@selector(UIImageView)]; }
static inline UITableView* AsyncUITableView(void) { return [AsyncUI performSelector:@selector(UITableView)]; }
static inline UITableViewCell* AsyncUITableViewCell(void) { return [AsyncUI performSelector:@selector(UITableViewCell)]; }
static inline UICollectionView* AsyncUICollectionView(void) { return [AsyncUI performSelector:@selector(UICollectionView)]; }
static inline UICollectionViewCell* AsyncUICollectionViewCell(void) { return [AsyncUI performSelector:@selector(UICollectionViewCell)]; }
static inline UISwitch* AsyncUISwitch(void) { return [AsyncUI performSelector:@selector(UISwitch)]; }
static inline UISlider* AsyncUISlider(void) { return [AsyncUI performSelector:@selector(UISlider)]; }
static inline UIDatePicker* AsyncUIDatePicker(void) { return [AsyncUI performSelector:@selector(UIDatePicker)]; }

#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
