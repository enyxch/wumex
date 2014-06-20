//
//  TaskViewCell.m
//  Wumex
//
//  Created by Nicolas Bonnet on 13.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "TaskViewCell.h"

#import "SWLongPressGestureRecognizer.h"

@implementation TaskViewCell

- (void)awakeFromNib
{
    
    UIView *backgroundSelected = [[UIView alloc] initWithFrame:self.bounds];
    const CGFloat* ft = CGColorGetComponents([[UIHelper colorFromHex:TASK_COLOR] CGColor]);
    UIColor *backgroundColor = [UIColor colorWithRed:ft[0]*1.4 green:ft[1]*1.4 blue:ft[2]*1.4 alpha:1];
    backgroundSelected.backgroundColor = backgroundColor;
    self.selectedBackgroundView = backgroundSelected;
    
    // Initialization code
    viewState.layer.cornerRadius = viewState.bounds.size.width / 2 ;
    viewState.layer.masksToBounds = YES;
    imageViewPerson.layer.cornerRadius = imageViewPerson.bounds.size.width / 2 ;
    imageViewPerson.layer.masksToBounds = YES;
    
    innerShadowlayer = [[SKInnerShadowLayer alloc] init];
    innerShadowlayer.frame = CGRectMake(-10, -20, 340, 87);
    innerShadowlayer.innerShadowOpacity = 1.0f;
    innerShadowlayer.innerShadowOffset = CGSizeMake(0, -3);
    innerShadowlayer.innerShadowColor = [UIColor blackColor].CGColor;
    
    [self.layer addSublayer:innerShadowlayer];
    
    self.layer.masksToBounds = YES;
    
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    SWLongPressGestureRecognizer* longPressGestureRecognizer = [[SWLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPressed:)];
    longPressGestureRecognizer.cancelsTouchesInView = NO;
    longPressGestureRecognizer.minimumPressDuration = 0.16f;
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    [self performSelector:@selector(initContentOffset) withObject:nil afterDelay:0.01];
    
}

- (void)initContentOffset
{
    [self.scrollView setContentOffset:CGPointMake(60, 0)];
}
- (BOOL)shouldHighlight
{
    BOOL shouldHighlight = YES;
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)])
    {
        NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
        
        shouldHighlight = [self.containingTableView.delegate tableView:self.containingTableView shouldHighlightRowAtIndexPath:cellIndexPath];
    }
    
    return shouldHighlight;
}

- (void)scrollViewPressed:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && !self.isHighlighted && self.shouldHighlight)
    {
        [self setHighlighted:YES animated:YES];
    }
    
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // Cell is already highlighted; clearing it temporarily seems to address visual anomaly.
        [self setHighlighted:NO animated:YES];
        [self scrollViewTapped:gestureRecognizer];
    }
    
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self setHighlighted:NO animated:YES];
    }
}

- (void)scrollViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.isSelected)
    {
        [self deselectCell];
    }
    else if (self.shouldHighlight)
    {
        [self selectCell];
    }
}

- (void)selectCell
{
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
    {
        cellIndexPath = [self.containingTableView.delegate tableView:self.containingTableView willSelectRowAtIndexPath:cellIndexPath];
    }
    
    if (cellIndexPath)
    {
        
        [self.containingTableView selectRowAtIndexPath:cellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            [self.containingTableView.delegate tableView:self.containingTableView didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (void)deselectCell
{
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)])
    {
        cellIndexPath = [self.containingTableView.delegate tableView:self.containingTableView willDeselectRowAtIndexPath:cellIndexPath];
    }
    
    if (cellIndexPath)
    {
        [self.containingTableView deselectRowAtIndexPath:cellIndexPath animated:NO];
        
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
        {
            [self.containingTableView.delegate tableView:self.containingTableView didDeselectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    UIColor *backgroundColor;
    if (highlighted) {
        const CGFloat* ft = CGColorGetComponents([[UIHelper colorFromHex:TASK_COLOR] CGColor]);
        backgroundColor = [UIColor colorWithRed:ft[0]*1.4 green:ft[1]*1.4 blue:ft[2]*1.4 alpha:1];
    } else {
        backgroundColor = [UIHelper colorFromHex:TASK_COLOR];
    }
    
    [UIView animateWithDuration:animated?0.3f:0.0f animations:^{
        self.contentView.backgroundColor = backgroundColor;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIColor *backgroundColor;
    if (selected) {
        const CGFloat* ft = CGColorGetComponents([[UIHelper colorFromHex:TASK_COLOR] CGColor]);
        backgroundColor = [UIColor colorWithRed:ft[0]*1.4 green:ft[1]*1.4 blue:ft[2]*1.4 alpha:1];
    } else {
        backgroundColor = [UIHelper colorFromHex:TASK_COLOR];
    }
    
    [UIView animateWithDuration:animated?0.3f:0.0f animations:^{
        self.contentView.backgroundColor = backgroundColor;
    }];
    
}

// Functions;
#pragma mark - Shared Funtions
+ (TaskViewCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"TaskViewCell" owner:nil options:nil];
    TaskViewCell* cell = array[0];
    return cell;
}

- (void)setTitle:(NSString*)title
{
    labelTitle.text = title;
}

- (void)setDetails:(NSString*)details
{
    labelDescription.text = details;
}

- (void)setupWithTask:(WUTask *)task
{
    labelTitle.text = task.title;
    labelDescription.text = task.detail;
    labelEstimatedTime.text = [UIHelper timeIntervalToString:task.estimatedTime];
    labelEndDate.text = [UIHelper dateToString:task.endDate];
    
    if ([task.state isEqualToString:@"BUG"]) {
        viewState.backgroundColor = [UIColor redColor];
    } else if ([task.state isEqualToString:@"IN_PROGRESS"]) {
        viewState.backgroundColor = [UIHelper colorFromHex:PROJECT_COLOR];
    } else {
        viewState.backgroundColor = [UIColor whiteColor];
    }
}

- (void)showBottomShadow:(BOOL)show
{
    innerShadowlayer.opacity = show ? 1.0f : 0.0f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 60) {
        [scrollView setContentOffset:CGPointMake(60, 0) animated:NO];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x < - 0.4) {
        *targetContentOffset = CGPointMake(0, 0);
    } else if (velocity.x > 0.4) {
        *targetContentOffset = CGPointMake(60, 0);
    } else if (scrollView.contentOffset.x <= 30 ) {
        *targetContentOffset = CGPointMake(0, 0);
    } else {
        *targetContentOffset = CGPointMake(60, 0);
    }
}

@end

