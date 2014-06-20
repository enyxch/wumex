//
//  TaskDateViewCell.m
//  Wumex
//
//  Created by Nicolas Bonnet on 17.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "TaskDateViewCell.h"

@implementation TaskDateViewCell

- (void)awakeFromNib
{
    innerShadowlayer = [[SKInnerShadowLayer alloc] init];
    innerShadowlayer.frame = CGRectMake(-10, 0, 340, 70);
    innerShadowlayer.innerShadowOpacity = 1.0f;
    innerShadowlayer.innerShadowOffset = CGSizeMake(0, 2);
    innerShadowlayer.innerShadowColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:innerShadowlayer];
    
    self.layer.masksToBounds = YES;
}

// Functions;
#pragma mark - Shared Funtions
+ (TaskDateViewCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"TaskDateViewCell" owner:nil options:nil];
    TaskDateViewCell* cell = array[0];
    return cell;
}

- (void)setText:(NSString *)text
{
    labelDate.text = text;
}

- (void)showTopShadow:(BOOL)show
{
    innerShadowlayer.opacity = show ? 1.0f : 0.0f;
}

@end
