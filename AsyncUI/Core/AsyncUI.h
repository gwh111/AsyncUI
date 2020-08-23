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

+ (UIView *)UIView;
+ (UILabel *)UILabel;
+ (UIButton *)UIButton;
+ (UITextView *)UITextView;
+ (UITextField *)UITextField;
+ (UIImageView *)UIImageView;
+ (UITableView *)UITableView;
+ (UITableViewCell *)UITableViewCell;
+ (UICollectionView *)UICollectionView;
+ (UICollectionViewCell *)UICollectionViewCell;
+ (UISwitch *)UISwitch;
+ (UISlider *)UISlider;
+ (UIDatePicker *)UIDatePicker;

@end

static inline UIView* AsyncUIView(void) { return AsyncUI.UIView; }
static inline UILabel* AsyncUILabel(void) { return AsyncUI.UILabel; }
static inline UIButton* AsyncUIButton(void) { return AsyncUI.UIButton; }
static inline UITextView* AsyncUITextView(void) { return AsyncUI.UITextView; }
static inline UITextField* AsyncUITextField(void) { return AsyncUI.UITextField; }
static inline UIImageView* AsyncUIImageView(void) { return AsyncUI.UIImageView; }
static inline UITableView* AsyncUITableView(void) { return AsyncUI.UITableView; }
static inline UITableViewCell* AsyncUITableViewCell(void) { return AsyncUI.UITableViewCell; }
static inline UICollectionView* AsyncUICollectionView(void) { return AsyncUI.UICollectionView; }
static inline UICollectionViewCell* AsyncUICollectionViewCell(void) { return AsyncUI.UICollectionViewCell; }
static inline UISwitch* AsyncUISwitch(void) { return AsyncUI.UISwitch; }
static inline UISlider* AsyncUISlider(void) { return AsyncUI.UISlider; }
static inline UIDatePicker* AsyncUIDatePicker(void) { return AsyncUI.UIDatePicker; }

NS_ASSUME_NONNULL_END
