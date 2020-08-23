//
//  UILabel+Async.h
//  AsyncUI
//
//  Created by gwh on 2020/8/19.
//  Copyright © 2020 gwh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Async.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  'commit_make' can be execute only once, the second 'commit_make' will do nothing.
 *  'commit_update' is used to update commit, after 'commit_make'.
 *  'commit_remake' is used to remake view, it will remove all the set before.
 */
 
@interface UILabel (Async)

- (UILabel *)commit_make:(void(^)(UILabel *label))block;
- (UILabel *)commit_update:(void(^)(UILabel *label))block;
- (UILabel *)commit_remake:(void(^)(UILabel *label))block;

@end

@interface UIButton (Async)

- (UIButton *)commit_make:(void(^)(UIButton *button))block;
- (UIButton *)commit_update:(void(^)(UIButton *button))block;
- (UIButton *)commit_remake:(void(^)(UIButton *button))block;

@end

@interface UITextView (Async)

- (UITextView *)commit_make:(void(^)(UITextView *textView))block;
- (UITextView *)commit_update:(void(^)(UITextView *textView))block;
- (UITextView *)commit_remake:(void(^)(UITextView *textView))block;

@end

@interface UITextField (Async)

- (UITextField *)commit_make:(void(^)(UITextField *textField))block;
- (UITextField *)commit_update:(void(^)(UITextField *textField))block;
- (UITextField *)commit_remake:(void(^)(UITextField *textField))block;

@end

@interface UIImageView (Async)

- (UIImageView *)commit_make:(void(^)(UIImageView *imageView))block;
- (UIImageView *)commit_update:(void(^)(UIImageView *imageView))block;
- (UIImageView *)commit_remake:(void(^)(UIImageView *imageView))block;

@end

@interface UITableView (Async)

- (UITableView *)commit_make:(void(^)(UITableView *tableView))block;
- (UITableView *)commit_update:(void(^)(UITableView *tableView))block;
- (UITableView *)commit_remake:(void(^)(UITableView *tableView))block;

@end

@interface UITableViewCell (Async)

- (UITableViewCell *)commit_make:(void(^)(UITableViewCell *tableViewCell))block;
- (UITableViewCell *)commit_update:(void(^)(UITableViewCell *tableViewCell))block;
- (UITableViewCell *)commit_remake:(void(^)(UITableViewCell *tableViewCell))block;

@end

@interface UICollectionView (Async)

- (UICollectionView *)commit_make:(void(^)(UICollectionView *collectionView))block;
- (UICollectionView *)commit_update:(void(^)(UICollectionView *collectionView))block;
- (UICollectionView *)commit_remake:(void(^)(UICollectionView *collectionView))block;

@end

@interface UICollectionViewCell (Async)

- (UICollectionViewCell *)commit_make:(void(^)(UICollectionViewCell *collectionViewCell))block;
- (UICollectionViewCell *)commit_update:(void(^)(UICollectionViewCell *collectionViewCell))block;
- (UICollectionViewCell *)commit_remake:(void(^)(UICollectionViewCell *collectionViewCell))block;

@end

@interface UISwitch (Async)

- (UISwitch *)commit_make:(void(^)(UISwitch *aswitch))block;
- (UISwitch *)commit_update:(void(^)(UISwitch *aswitch))block;
- (UISwitch *)commit_remake:(void(^)(UISwitch *aswitch))block;

@end

@interface UISlider (Async)

- (UISlider *)commit_make:(void(^)(UISlider *slider))block;
- (UISlider *)commit_update:(void(^)(UISlider *slider))block;
- (UISlider *)commit_remake:(void(^)(UISlider *slider))block;

@end

@interface UIDatePicker (Async)

- (UIDatePicker *)commit_make:(void(^)(UIDatePicker *datePicker))block;
- (UIDatePicker *)commit_update:(void(^)(UIDatePicker *datePicker))block;
- (UIDatePicker *)commit_remake:(void(^)(UIDatePicker *datePicker))block;

@end

NS_ASSUME_NONNULL_END
