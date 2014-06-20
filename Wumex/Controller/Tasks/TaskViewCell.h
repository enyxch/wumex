//
//  TaskViewCell.h
//  Wumex
//
//  Created by Nicolas Bonnet on 13.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUTask.h"
#import "SKInnerShadowLayer.h"

@interface TaskViewCell : UITableViewCell <UIScrollViewDelegate>
{
@private
    
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelDescription;
    __weak IBOutlet UILabel *labelEstimatedTime;
    __weak IBOutlet UILabel *labelEndDate;
    __weak IBOutlet UIImageView *imageViewPerson;
    __weak IBOutlet UIImageView *imageViewArrow;
    __weak IBOutlet UIView *viewState;
    SKInnerShadowLayer *innerShadowlayer;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITableView *containingTableView;

+ (TaskViewCell*)sharedCell;

- (void)setTitle:(NSString*)title;
- (void)setDetails:(NSString*)details;
- (void)setupWithTask:(WUTask*)task;
- (void)showBottomShadow:(BOOL)show;

@end

