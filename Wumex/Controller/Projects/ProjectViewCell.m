//
//  ProjectViewCell.m
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "ProjectViewCell.h"

@implementation ProjectViewCell

- (void)awakeFromNib
{
    // Initialization code
    labelTask.text = NSLocalizedString(@"tasks", @"ProjectViewCell");
    labelNote.text = NSLocalizedString(@"notes", @"ProjectViewCell");
    labelObserver.text = NSLocalizedString(@"observers", @"ProjectViewCell");
    
    labelTaskNumber.layer.borderColor = [UIHelper colorFromHex:PROJECT_COLOR].CGColor;
    labelTaskNumber.layer.borderWidth = 1.0f;
    labelNoteNumber.layer.borderColor = [UIHelper colorFromHex:PROJECT_COLOR].CGColor;
    labelNoteNumber.layer.borderWidth = 1.0f;
    labelObserverNumber.layer.borderColor = [UIHelper colorFromHex:PROJECT_COLOR].CGColor;
    labelObserverNumber.layer.borderWidth = 1.0f;
}

// Functions;
#pragma mark - Shared Funtions
+ (ProjectViewCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ProjectViewCell" owner:nil options:nil];
    ProjectViewCell* cell = array[0];
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self setSelected:NO animated:YES];
    }
}

- (void)setCellColor:(UIColor*)color
{
    labelTaskNumber.layer.borderColor = color.CGColor;
    labelTaskNumber.layer.borderWidth = 1.0f;
    labelNoteNumber.layer.borderColor = color.CGColor;
    labelNoteNumber.layer.borderWidth = 1.0f;
    labelObserverNumber.layer.borderColor = color.CGColor;
    labelObserverNumber.layer.borderWidth = 1.0f;
    
    labelTaskNumber.textColor = color;
    labelNoteNumber.textColor = color;
    labelObserverNumber.textColor = color;
    labelTask.textColor = color;
    labelNote.textColor = color;
    labelObserver.textColor = color;
}

- (void)setTaskNumber:(NSUInteger)number
{
    labelTaskNumber.text = [NSString stringWithFormat:@"%d", number];
}

- (void)setNoteNumber:(NSUInteger)number
{
    labelNoteNumber.text = [NSString stringWithFormat:@"%d", number];
}

- (void)setObserverNumber:(NSUInteger)number
{
    labelObserverNumber.text = [NSString stringWithFormat:@"%d", number];
}

- (void)setTitle:(NSString*)title
{
    labelTitle.text = title;
}

- (void)setDetails:(NSString*)details
{
    labelDescription.text = details;
}

@end
