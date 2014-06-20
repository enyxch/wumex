//
//  NewLabelViewCell.m
//  Wumex
//
//  Created by Nicolas Bonnet on 18.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "NewLabelViewCell.h"

#import "OLGhostAlertView.h"
#import "IQUIView+IQKeyboardToolbar.h"

@implementation NewLabelViewCell

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    
    separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separatorViewTop.backgroundColor = [UIHelper colorFromHex:TEXT_COLOR];
    [self addSubview:separatorViewTop];
    
    UIView *backgroundSelected = [[UIView alloc] initWithFrame:self.bounds];
    backgroundSelected.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    UIView *dupSeparatorView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    dupSeparatorView2.backgroundColor = [UIHelper colorFromHex:TEXT_COLOR];
    [backgroundSelected addSubview:dupSeparatorView2];
    self.selectedBackgroundView = backgroundSelected;
    
    labelText.textColor = [UIHelper colorFromHex:TEXT_COLOR];
    
    imageView.image = [[UIImage imageNamed:@"add_20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.tintColor = [UIHelper colorFromHex:TEXT_COLOR];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [buttonAdd setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    textField.tintColor = [UIHelper colorFromHex:TEXT_COLOR];
    textField.placeholder = NSLocalizedString(@"Title", nil);
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
    [self buttonClicked:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        constraintBottomViewTextField.constant = 0;
        constraintTopViewNew.constant = 44;
    } else {
        textField.text = @"";
        [buttonAdd setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];

        constraintBottomViewTextField.constant = 44;
        constraintTopViewNew.constant = 0;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
    }];
}

- (IBAction)buttonClicked:(id)sender
{
    if (textField.text.length > 0) {
        WULabel *label = [[WULabel alloc] init];
        label.title = textField.text;
        if ([self.delegate respondsToSelector:@selector(newLabelViewCell:didCreateNewLabel:)]) {
            [self.delegate newLabelViewCell:self didCreateNewLabel:label];
        }
        [self setSelected:NO animated:YES];
    } else {
        
        if ([textField isEditing]) {
            OLGhostAlertView *advice = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"I think you forgot to give a title !", @"Message of a messageBox. The title : Oops") timeout:3 dismissible:YES];
            advice.style = OLGhostAlertViewStyleDark;
            advice.position = OLGhostAlertViewPositionTop;
            [advice show];
        } else {
            [self setSelected:NO animated:YES];
        }
    }
    [textField resignFirstResponder];
}

// Functions;
#pragma mark - Shared Funtions
+ (NewLabelViewCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"NewLabelViewCell" owner:nil options:nil];
    NewLabelViewCell* cell = array[0];
    return cell;
}

- (void)setText:(NSString *)text
{
    labelText.text = text;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)myTextField
{
    previousText = myTextField.text;
    [buttonAdd setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
}

- (void)textFieldDidEndEditing:(UITextField *)myTextField
{
    if (myTextField.text.length == 0) {
        [buttonAdd setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    }
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
