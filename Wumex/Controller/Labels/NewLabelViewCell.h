//
//  NewLabelViewCell.h
//  Wumex
//
//  Created by Nicolas Bonnet on 18.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WULabel.h"

@class NewLabelViewCell;

@protocol NewLabelViewCellDelegate

- (void)newLabelViewCell:(NewLabelViewCell*)cell didCreateNewLabel:(WULabel*)label;

@end


@interface NewLabelViewCell : UITableViewCell <UITextFieldDelegate>
{
@private
    
    __weak IBOutlet UIView *viewNew;
    __weak IBOutlet UILabel *labelText;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet NSLayoutConstraint *constraintTopViewNew;
    
    
    __weak IBOutlet UIView *viewTextField;
    __weak IBOutlet UIButton *buttonAdd;
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet NSLayoutConstraint *constraintBottomViewTextField;
    
    UIView *separatorViewTop;
    
    NSString *previousText;
}

@property (nonatomic, retain) NSObject<NewLabelViewCellDelegate> *delegate;

//- (void)justAppear:(BOOL)appear;

- (void)setText:(NSString *)text;

+ (NewLabelViewCell*)sharedCell;

@end
