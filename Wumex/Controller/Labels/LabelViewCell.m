//
//  LabelViewCell.m
//  Wumex
//
//  Created by Nicolas Bonnet on 17.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "LabelViewCell.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "OLGhostAlertView.h"

@implementation LabelViewCell

- (void)awakeFromNib
{
    UIView *backgroundSelected = [[UIView alloc] initWithFrame:self.bounds];
    backgroundSelected.backgroundColor = [UIColor whiteColor];
    UIView *dupSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+1, 320, 1)];
    dupSeparatorView.backgroundColor = [UIHelper colorFromHex:TASK_COLOR];
    [backgroundSelected addSubview:dupSeparatorView];
    UIView *dupSeparatorView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    dupSeparatorView2.backgroundColor = [UIHelper colorFromHex:TASK_COLOR];
    [backgroundSelected addSubview:dupSeparatorView2];
    self.selectedBackgroundView = backgroundSelected;
    
    labelText.textColor = [UIHelper colorFromHex:TEXT_COLOR];
    labelEstimatedTime.textColor = [UIHelper colorFromHex:TEXT_COLOR];
    separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separatorViewTop.backgroundColor = [UIHelper colorFromHex:TEXT_COLOR];
    [self addSubview:separatorViewTop];
    separatorViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, 320, 1)];
    separatorViewBottom.backgroundColor = [UIHelper colorFromHex:TEXT_COLOR];
    [self addSubview:separatorViewBottom];
    accessoryImageView.image = [[UIImage imageNamed:@"arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    accessoryImageView.tintColor = [UIColor lightGrayColor];
    
    textField.tintColor = [UIHelper colorFromHex:TEXT_COLOR];
    textField.placeholder = NSLocalizedString(@"Title", nil);
    [textField setHidden:YES];
    textField.delegate = self;
    [textField addCancelDoneOnKeyboardWithTarget:self cancelAction:@selector(cancel) doneAction:@selector(done) shouldShowPlaceholder:YES];
    
}

- (void)cancel
{
    [textField resignFirstResponder];
    textField.text = previousText;
}

- (void)done
{
    if (textField.text.length > 0) {
        label.title = textField.text;
        if ([self.delegate respondsToSelector:@selector(labelViewCell:didUpdateLabel:)]) {
            [self.delegate labelViewCell:self didUpdateLabel:label];
        }
        [textField resignFirstResponder];
    } else {
        
        if ([textField isEditing]) {
            OLGhostAlertView *advice = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"I think you forgot to give a title !", @"Message of a messageBox. The title : Oops") timeout:3 dismissible:YES];
            advice.style = OLGhostAlertViewStyleDark;
            advice.position = OLGhostAlertViewPositionTop;
            [advice show];
        } else {
            [textField resignFirstResponder];
            [self setSelected:NO animated:YES];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        textField.text = labelText.text;
    } else {
        if (![textField.text isEqualToString:@""]) {
            labelText.text = textField.text;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [textField setHidden:!editing];
        [labelText setHidden:editing];
        [labelEstimatedTime setHidden:editing];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        labelText.textColor = [UIHelper colorFromHex:TASK_COLOR];
        labelEstimatedTime.textColor = [UIHelper colorFromHex:TASK_COLOR];
        accessoryImageView.tintColor = [UIHelper colorFromHex:TASK_COLOR];
    } else {
        labelText.textColor = [UIHelper colorFromHex:TEXT_COLOR];
        labelEstimatedTime.textColor = [UIHelper colorFromHex:TEXT_COLOR];
        accessoryImageView.tintColor = [UIColor lightGrayColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

// Functions;
#pragma mark - Shared Funtions
+ (LabelViewCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"LabelViewCell" owner:nil options:nil];
    LabelViewCell* cell = array[0];
    return cell;
}

- (void)setText:(NSString *)text
{
    labelText.text = text;
}

- (void)setupWithLabel:(WULabel*)aLabel
{
    label = aLabel;
    labelText.text = aLabel.title;
    labelEstimatedTime.text = [UIHelper timeIntervalToString:aLabel.estimatedTime];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)myTextField
{
    previousText = myTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)myTextField
{
    [myTextField resignFirstResponder];
    if ([myTextField.text isEqualToString:@""]) {
        [self setSelected:NO animated:YES];
    }
    return NO;
}

@end
