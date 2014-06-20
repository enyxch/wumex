//
//  LabelViewCell.h
//  Wumex
//
//  Created by Nicolas Bonnet on 17.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WULabel.h"

@class LabelViewCell;

@protocol LabelViewCellDelegate

- (void)labelViewCell:(LabelViewCell*)cell didUpdateLabel:(WULabel*)label;

@end

@interface LabelViewCell : UITableViewCell <UITextFieldDelegate>
{
@private
    
    __weak IBOutlet UILabel *labelText;
    __weak IBOutlet UILabel *labelEstimatedTime;
    UIView *separatorViewTop;
    UIView *separatorViewBottom;
    __weak IBOutlet UIImageView *accessoryImageView;
    __weak IBOutlet UITextField *textField;
    
    NSString *previousText;
    WULabel* label;
}

@property (nonatomic, retain) NSObject<LabelViewCellDelegate> *delegate;

- (void)setText:(NSString *)text;
- (void)setupWithLabel:(WULabel*)aLabel;

+ (LabelViewCell*)sharedCell;

@end
