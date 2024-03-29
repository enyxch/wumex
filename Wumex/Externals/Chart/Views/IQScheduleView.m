//
//  IQScheduleView.m
//  IQWidgets for iOS
//
//  Copyright 2011 EvolvIQ
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IQScheduleView.h"
#import "IQCalendarDataSource.h"
#import "IQCalendarHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#import "PopoverViewController.h"

const CGFloat kDayViewPadding = 0.0;


@interface IQScheduleView () {
    id<IQCalendarDataSource> dataSource;
    NSDate* startDate;
    int numDays;
    NSMutableArray* days;
    UILabel* hours[24];
    UIView* nowTimeIndicator;
    NSCalendar* calendar;
    BOOL dirty;
    NSDateFormatter* cornerFormatter, *headerFormatter, *tightHeaderFormatter;
    NSSet* items;
    UIColor* tintColor, *headerTextColor;
}

- (void) reloadAnimated:(BOOL)animated;
- (void) setupCalendarView;
- (void) ensureCapacity:(int)capacity;
@end

@interface IQScheduleViewDay : NSObject {
    int timeIndex;
    NSTimeInterval dayOffset;
    NSTimeInterval dayLength;
    UILabel* headerView;
    NSMutableSet* blocks;
    IQScheduleDayView* contentView;
}
- (id) initWithHeaderView:(UILabel*)headerView contentView:(UIView*)contentView;
- (void) setTimeIndex:(int)ti left:(CGFloat)left width:(CGFloat)width;
- (void) reloadDataWithSource:(IQScheduleView*)dataSource;
@property (nonatomic, readonly) int timeIndex;
@property (nonatomic, readonly) UILabel* headerView;
@property (nonatomic, readonly) IQScheduleDayView* contentView;
@property (nonatomic, retain) NSString* title;
@property (nonatomic) NSTimeInterval dayOffset, dayLength;
@end

@implementation IQScheduleView

@synthesize dataSource;
@synthesize calendar;
@synthesize numberOfDays = numDays;
@synthesize tintColor;
@synthesize darkLineColor;
@synthesize lightLineColor;

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCalendarView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupCalendarView];
    }
    return self;
}

#pragma mark IQScrollView overrides


#pragma mark Properties


- (void)setTintColor:(UIColor *)tc
{
    if([self.columnHeaderView respondsToSelector:@selector(setTintColor:)]) {
        [(id)self.columnHeaderView setTintColor:tc];
    }
    tintColor = tc;
}

- (UIColor*)tintColor
{
    return tintColor;
}

- (void)setHeaderTextColor:(UIColor *)htc
{
    if([self.columnHeaderView respondsToSelector:@selector(setTextColor:)]) {
        [(id)self.columnHeaderView setTintColor:htc];
    }
    headerTextColor = htc;
}

- (UIColor*)headerTextColor
{
    return headerTextColor;
}

#pragma mark Horizontal time scaling

- (NSDate*) startDate
{
    return startDate;
}

- (NSDate*) endDate
{
    NSDateComponents* cmpnts = [NSDateComponents new];
    [cmpnts setDay:numDays-1];
    return [calendar dateByAddingComponents:cmpnts toDate:startDate options:0];
}

- (void) setStartDate:(NSDate*)s numberOfDays:(int)n animated:(BOOL)animated
{
    if(s == nil) s = [NSDate date];
    NSDateComponents* dc = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:s];
    startDate = [calendar dateFromComponents:dc];
    
    if(n<1) n = 1;
    if(n>7) n = 7;
    numDays = n;
    [self reloadAnimated:animated];
}
- (void) setStartDate:(NSDate*)s endDate:(NSDate*)e animated:(BOOL)animated
{
    if(s == nil || e == nil) {
        [NSException raise:@"InvalidArgument" format:@"setStartDate:endDate: cannot take nil arguments"];
    }
    NSDateComponents* dc = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit fromDate:s toDate:e options:0];
    if(dc.day <= 0) {
        [self setStartDate:s numberOfDays:1 animated:animated];
    } else {
        int d = dc.day;
        if(dc.hour > 0 || dc.minute > 0 || dc.second > 0) d++;
        [self setStartDate:s numberOfDays:d animated:animated];
    }
}

- (void) setWeekWithDate:(NSDate*)s workdays:(BOOL)workdays animated:(BOOL)animated
{
    if(s == nil) s = [NSDate date];
    NSDateComponents* dc = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:s];
    int diff, num;
    if(workdays) {
        diff = 2;
        num = 5;
    } else {
        diff = calendar.firstWeekday;
        num = 7;
    }
    dc.day -= dc.weekday-diff;
    dc.weekday = diff;
    [self setStartDate:[calendar dateFromComponents:dc] numberOfDays:num animated:animated];
}

#pragma mark Vertical time zooming

- (void) setZoom:(NSRange)zoom
{
    
}

- (NSRange) zoom
{
    // TODO: Implement zooming
    //CGPoint o = [calendarArea contentOffset];
    //CGSize s = [calendarArea contentSize];
    return NSMakeRange(0, 0);
}

#pragma mark Notifications

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect bnds = self.bounds;
    // Make sure an hour has an integral height
    CGFloat height = bnds.size.height * 2;
    height = (height - 2 * kDayViewPadding) / 24.0f;
    height = round(height) * 24 + 2 * kDayViewPadding;
    self.contentSize = CGSizeMake(bnds.size.width, height);
    
    CGFloat ht = self.contentSize.height - 2 * kDayViewPadding;
    for(int i=1; i<= 23; i++) {
        hours[i].frame = CGRectMake(0, 12+kDayViewPadding+i*ht/24.0f, 50, 20);
    }
    for(IQScheduleViewDay* day in days) {
        CGRect r = day.contentView.frame;
        if(r.size.height != height) {
            r.size.height = height;
            day.contentView.frame = r;
        }
    }
}

- (void)didMoveToSuperview
{
    [self layoutSubviews];
    if(dirty) [self reloadAnimated:NO];
    self.contentOffset = CGPointMake(0, self.bounds.size.height * .5);
    [self flashScrollbarIndicators];
}

#pragma mark Layouting (private)

- (void) recreateFromScratch
{
    dirty = TRUE;
    for(IQScheduleViewDay* day in days) {
        [day.contentView removeFromSuperview];
    }
}

- (void) ensureCapacity:(int)capacity
{
    if(days == nil) return;
    while([days count] < capacity) {
        UILabel* hdr = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 24)];
        hdr.font = [UIFont systemFontOfSize:14];
        hdr.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        hdr.textAlignment = UITextAlignmentCenter;
        hdr.contentMode = UIViewContentModeCenter;
        hdr.backgroundColor = [UIColor clearColor];
//        hdr.shadowColor = [UIColor whiteColor];
//        hdr.shadowOffset = CGSizeMake(0, 1);
        hdr.hidden = YES;
        [self.columnHeaderView addSubview:hdr];
        IQScheduleDayView* dayContent = [[IQScheduleDayView alloc] initWithFrame:CGRectMake(0, 0, 120, 100)];
        dayContent.opaque = YES;
        dayContent.clipsToBounds = YES;
        dayContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        dayContent.backgroundColor = self.backgroundColor;
        dayContent.darkLineColor = self.darkLineColor;
        dayContent.lightLineColor = self.lightLineColor;
        dayContent.tintColor = self.tintColor;
        IQScheduleViewDay* day = [[IQScheduleViewDay alloc] initWithHeaderView:hdr contentView:dayContent];
        [self addSubview:dayContent];
        [days addObject:day];
    }
}

- (void) reloadData
{
    for(IQScheduleViewDay* day in days) {
        if([day timeIndex] != 0) {
            [day reloadDataWithSource:self];
        }
    }
}

- (void) reloadAnimated:(BOOL)animated
{
    if(self.superview == nil) {
        dirty = YES;
        return;
    }
    dirty = NO;
    ((UILabel*)self.cornerView).text = [cornerFormatter stringFromDate:startDate];
    [self ensureCapacity:numDays];
    
    NSDateComponents* dc = [NSDateComponents new];
    
    int tMin = 0;
    int pivotPoint = -1;
    
    for(int i=0; i<numDays; i++) {
        dc.day = i;
        int t = (int)[[calendar dateByAddingComponents:dc toDate:startDate options:0] timeIntervalSinceReferenceDate];
        if(i == 0) tMin = t;
        int j = 0;
        for(IQScheduleViewDay* day in days) {
            if([day timeIndex] == t) {
                pivotPoint = i;
                break;
            }
            j++;
        }
        if(pivotPoint >= 0) {
            while(j > pivotPoint) {
                IQScheduleViewDay* day = days[0];
                [days addObject:day];
                [days removeObjectAtIndex:0];
                j--;
            }
            while(j < pivotPoint) {
                IQScheduleViewDay* day = [days lastObject];
                [days insertObject:day atIndex:0];
                [days removeLastObject];
                j++;
            }
        }
    }
    if(tMin == 0) return;
    CGRect bnds = self.bounds;
    CGFloat left = 60;
    CGFloat width = (bnds.size.width - left) / numDays;
    NSLog(@"Pivot point: %d", pivotPoint);
    if(pivotPoint < 0||YES) {
        // We have no view in common, just swap the views
        int i = 0;
        if(animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self cache:YES];
            [UIView setAnimationsEnabled:NO]; 
            [UIView setAnimationDuration:0.5];
        }
        for(IQScheduleViewDay* day in days) {
            dc.day = i;
            int t = 0;
            if(i < numDays) {
                NSDate* d = [calendar dateByAddingComponents:dc toDate:startDate options:0];
                NSTimeInterval tt = [d timeIntervalSinceReferenceDate];
                dc.day = i+1;
                NSTimeInterval t2 = [[calendar dateByAddingComponents:dc toDate:startDate options:0] timeIntervalSinceReferenceDate];
                t = (int)tt;
                day.title = [((width < 100)?tightHeaderFormatter:headerFormatter) stringFromDate:d];
                day.dayOffset = tt - t;
                day.dayLength = t2 - tt;
            }
            [day setTimeIndex:t left:left width:width];
            left += width;
            i++;
        }
        [self layoutSubviews];
        if(animated) {
            [UIView commitAnimations];
        }
        for(IQScheduleViewDay* day in days) {
            [day reloadDataWithSource:self];
        }
    } else {
        
    }
}

#pragma mark - Overridable methods

- (UIView*) createViewForActivityWithFrame:(CGRect)frame text:(NSString*)text
{
    IQScheduleBlockView* view = [[IQScheduleBlockView alloc] initWithFrame:frame];
    if(text) {
        view.text = text;
    }
    return view;
}

+ (Class) headerViewClass
{
    return [IQCalendarHeaderView class];
}

- (void) setupCalendarView
{
    self.alwaysBounceHorizontal = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.darkLineColor = [UIColor lightGrayColor];
    self.lightLineColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.tintColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:209/255.0 alpha:1];
    self.headerTextColor = [UIColor colorWithRed:.15 green:.1 blue:0 alpha:1];
    days = [[NSMutableArray alloc] initWithCapacity:7];
    self.calendar = [NSCalendar currentCalendar];
    [self setWeekWithDate:nil workdays:YES animated:NO];
    cornerFormatter = [[NSDateFormatter alloc] init];
    [cornerFormatter setDateFormat:@"YYYY"];
    headerFormatter = [[NSDateFormatter alloc] init];
    //[headerFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[headerFormatter setTimeStyle:NSDateFormatterNoStyle];
    [headerFormatter setDateFormat:@"EEE MMM dd"];
    tightHeaderFormatter = [[NSDateFormatter alloc] init];
    //[headerFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[headerFormatter setTimeStyle:NSDateFormatterNoStyle];
    [tightHeaderFormatter setDateFormat:@"EEE"];
    
    UIView* hdr = (UIView*)[[[[self class] headerViewClass] alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    if([hdr respondsToSelector:@selector(setTintColor:)]) {
        [(id)hdr setTintColor:tintColor];
    }
    self.columnHeaderView = hdr;
    
    
    for(int i=1; i<= 23; i++) {
        hours[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 46, 20)];
        hours[i].text = [NSString stringWithFormat:@"%02d.00", i];
        hours[i].textAlignment = UITextAlignmentRight;
        hours[i].font = [UIFont systemFontOfSize:12];
        hours[i].textColor = [UIColor grayColor];
        hours[i].contentMode = UIViewContentModeCenter;
        hours[i].autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        hours[i].backgroundColor = self.backgroundColor;
        [self addSubview:hours[i]];
    }
}

@end

@implementation IQScheduleViewDay
@synthesize timeIndex;
@synthesize headerView;
@synthesize contentView;
@synthesize dayOffset, dayLength;

- (id) initWithHeaderView:(UILabel*)h contentView:(UIView*)c
{
    if((self = [super init])) {
        headerView = h;
        contentView = c;
        blocks = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void) setTitle:(NSString *)title
{
    headerView.text = title;
}

- (NSString*) title
{
    return headerView.text;
}

- (void) setTimeIndex:(int)ti left:(CGFloat)left width:(CGFloat)width
{
    CGRect r = headerView.frame;
    left = floor(left);
    width = ceil(width);
    r.origin.x = left;
    r.size.width = ceil(width);
    headerView.frame = r;
    r = contentView.frame;
    r.origin.x = left;
    if(r.size.width != ceil(width)) {
        r.size.width = ceil(width);
        [contentView setNeedsDisplay];
    }
    //NSLog(@"Setting frm %d to %f", ti, r.size.height);
    contentView.frame = r;
    if(ti <= 0) {
        headerView.hidden = YES;
        contentView.hidden = YES;
    } else {
        headerView.hidden = NO;
        contentView.hidden = NO;
    }
    timeIndex = ti;
}

- (void) reloadDataWithSource:(IQScheduleView*)dataSource
{
    for(UIView* view in blocks) {
        [view removeFromSuperview];
    }
    [blocks removeAllObjects];
    
    if(dataSource == nil) return;
    CGRect bounds = contentView.bounds;
    CGFloat ht = bounds.size.height - 2 * kDayViewPadding;
    [[dataSource dataSource] enumerateEntriesUsing:^(NSTimeInterval startDate, NSTimeInterval endDate, NSObject<IQCalendarActivity>* value, NSDictionary *info) {
        CGFloat y1 = kDayViewPadding - 1 + bounds.origin.y + round(ht * (startDate - timeIndex) / dayLength);
        CGFloat y2 = kDayViewPadding + bounds.origin.y + round(ht * (endDate - timeIndex) / dayLength);
        CGRect frame = CGRectMake(bounds.origin.x, y1, bounds.size.width, y2 - y1);
        if(frame.size.height < 10) frame.size.height = 10;
        
        NSString* text = nil;
        if([value respondsToSelector:@selector(characterAtIndex:)]) {
            text = (NSString*)value;
        }
        UIView* view = [dataSource createViewForActivityWithFrame:frame text:text];
        if(view != nil) {
            [blocks addObject:view];
            [contentView addSubview:view];
            NSUInteger red, green, blue;
            sscanf([info[@"color"] UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
            view.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        }
    } from:timeIndex+dayOffset to:timeIndex+dayOffset+dayLength];
}

@end

@implementation IQScheduleDayView
@synthesize darkLineColor, lightLineColor, tintColor;

- (void) dealloc
{
    self.darkLineColor = nil;
    self.lightLineColor = nil;
    self.tintColor = nil;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bnds = self.bounds;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetShouldAntialias(ctx, NO);
    CGContextSetFillColorWithColor(ctx, [self.backgroundColor CGColor]);
    CGContextFillRect(ctx, rect);
    CGFloat hourSize = (bnds.size.height - 2 * kDayViewPadding) / 24.0f;
    CGContextAddLines(ctx, (CGPoint[]){CGPointMake(0, kDayViewPadding), CGPointMake(0, (int)bnds.size.height-kDayViewPadding)}, 2);
    for(int i=0; i<=24; i++) {
        int y = (int)(i * hourSize + kDayViewPadding);
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, bnds.size.width, y);
        
    }
    CGContextSetStrokeColorWithColor(ctx, [self.lightLineColor CGColor]);
    CGContextStrokePath(ctx);
    for(int i=0; i<24; i++) {
        int y = (int)((i+.5f) * hourSize + kDayViewPadding);
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, bnds.size.width, y);
        
    }
    CGContextSetStrokeColorWithColor(ctx, [self.lightLineColor CGColor]);
    CGContextSaveGState(ctx);
    CGContextSetLineDash(ctx, 0, (CGFloat[]){1,1}, 2);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    //CGContextMoveToPoint(ctx, 0, 20);
    //CGContextAddLineToPoint(ctx, 100, 20);
}

@end

@implementation IQScheduleBlockView
@synthesize textLabel;
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.layer.cornerRadius = 8.0f;
        self.layer.borderWidth = 1.0;
        self.backgroundColor = [UIColor blueColor];
        CGRect b = self.bounds;
        b.origin.x = 5;
        b.origin.y = 5;
        b.size.width -= 2 * b.origin.x;
        b.size.height -= 2 * b.origin.y;
        textLabel = [[UILabel alloc] initWithFrame:b];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.opaque = NO;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:textLabel];
    }
    return self;
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    self.layer.borderColor = [[backgroundColor colorWithAlphaComponent:0.5] CGColor];
    const CGFloat* ft = CGColorGetComponents([backgroundColor CGColor]);
    //textLabel.textColor = backgroundColor;
    [super setBackgroundColor:[UIColor colorWithRed:ft[0]*.5+.5 green:ft[1]*.5+.5 blue:ft[2]*.5+.5 alpha:.75]];
    textLabel.textColor = [UIColor colorWithRed:ft[0]*.75 green:ft[1]*.75 blue:ft[2]*.75 alpha:1];
}

- (void) setText:(NSString *)text
{
    textLabel.text = text;
}

- (NSString*) text
{
    return textLabel.text;
}
@end


@implementation IQTaskView

@synthesize textLabel, originalBackgroundColor;

- (id) initWithFrame:(CGRect)frame subFrames:(NSArray*)frames
{
    self = [super initWithFrame:frame];
    if(self) {
        self.views = @[];
        CGRect b = self.bounds;
        b.origin.x = 5;
        b.origin.y = 5;
        b.size.width = b.size.width - 2 * b.origin.x;
        b.size.height -= 2 * b.origin.y;
        textLabel = [[UILabel alloc] initWithFrame:b];
        textLabel.opaque = NO;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:textLabel];
        [self updateViewsWithFrames:frames];
        [self setBackgroundColor:[UIColor blueColor]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        
        self.isHorizontalDraggable = YES;
        
    }
    return self;
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    originalBackgroundColor = backgroundColor;
    const CGFloat* ft = CGColorGetComponents([backgroundColor CGColor]);
    textLabel.textColor = [UIColor colorWithRed:ft[0]*.75 green:ft[1]*.75 blue:ft[2]*.75 alpha:1];
}

- (void) setText:(NSString *)text
{
    textLabel.text = text;
    
    CGRect firstViewFrame = ((UIView*)[self.views firstObject]).frame;
    
    CGFloat widthText = [textLabel.text sizeWithAttributes:@{NSFontAttributeName:textLabel.font}].width+10;
    
    CGRect frameLabel = self.bounds;
    frameLabel.origin.x = 5 + firstViewFrame.origin.x;
    frameLabel.origin.y = 5 + firstViewFrame.origin.y;
    frameLabel.size.width = MAX(frameLabel.size.width - 2 * frameLabel.origin.x, widthText);
    frameLabel.size.height -= 2 * frameLabel.origin.y;
    
    textLabel.frame = frameLabel;
}

- (NSString*) text
{
    return textLabel.text;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (highlighted){
        [UIView animateWithDuration:0.2 animations:^{
            const CGFloat* ft = CGColorGetComponents([self.originalBackgroundColor CGColor]);
            for (UIView* view in self.views) {
                [view setBackgroundColor:[UIColor colorWithRed:ft[0]*.8+.2 green:ft[1]*.8+.2 blue:ft[2]*.8+.2 alpha:.85]];
                view.layer.borderColor = [[self.originalBackgroundColor colorWithAlphaComponent:1] CGColor];
            }
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            const CGFloat* ft = CGColorGetComponents([self.originalBackgroundColor CGColor]);
            for (UIView* view in self.views) {
                [view setBackgroundColor:[UIColor colorWithRed:ft[0]*.5+.5 green:ft[1]*.5+.5 blue:ft[2]*.5+.5 alpha:.75]];
                view.layer.borderColor = [[self.originalBackgroundColor colorWithAlphaComponent:0.5] CGColor];
            }
        }];
    }
}

- (void)updateViewsWithFrames:(NSArray*)frames
{
    for (UIView* view in self.views) {
        [view removeFromSuperview];
    }
    NSMutableArray* tmpArray = [NSMutableArray array];
    for (NSValue *value in frames) {
        UIView* view = [[UIView alloc] initWithFrame:[value CGRectValue]];
        view.layer.cornerRadius = 8.0f;
        view.layer.borderWidth = 1.0;
        [tmpArray addObject:view];
        [self insertSubview:view belowSubview:textLabel];
    }
    self.views = [NSArray arrayWithArray:tmpArray];
    CGRect lastViewFrame = [[frames lastObject] CGRectValue];
    CGRect frame = self.frame;
    frame.size.width = lastViewFrame.origin.x+lastViewFrame.size.width;
    self.frame = frame;
    CGRect firstViewFrame = [[frames firstObject] CGRectValue];
    
    CGFloat widthText = [textLabel.text sizeWithAttributes:@{NSFontAttributeName:textLabel.font}].width+10;
    
    CGRect frameLabel = self.bounds;
    frameLabel.origin.x = 5 + firstViewFrame.origin.x;
    frameLabel.origin.y = 5 + firstViewFrame.origin.y;
    frameLabel.size.width = MAX(frameLabel.size.width - 2 * frameLabel.origin.x, widthText);
    frameLabel.size.height -= 2 * frameLabel.origin.y;
    
    textLabel.frame = frameLabel;
}

- (void)tapped
{
    if (settingsPopoverController == nil) {
        PopoverViewController *popViewController = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:nil];
        popViewController.blockClose = ^{
            [settingsPopoverController dismissPopoverAnimated:YES completion:^{
                [self popoverControllerDidDismissPopover:settingsPopoverController];
            }];
        };
        
        popViewController.modalInPopover = NO;
        
        settingsPopoverController = [[WYPopoverController alloc] initWithContentViewController:popViewController];
        settingsPopoverController.delegate = self;
        settingsPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        settingsPopoverController.theme = [WYPopoverTheme themeForPopover];
        
        [settingsPopoverController presentPopoverFromRect:self.bounds
                                                   inView:self
                                 permittedArrowDirections:WYPopoverArrowDirectionAny
                                                 animated:YES
                                                  options:WYPopoverAnimationOptionFadeWithScale];
    } else {
        [settingsPopoverController dismissPopoverAnimated:YES completion:^{
            [self popoverControllerDidDismissPopover:settingsPopoverController];
        }];
    }
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
//    NSLog(@"popoverControllerDidPresentPopover");
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == settingsPopoverController)
    {
        settingsPopoverController.delegate = nil;
        settingsPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

@end


@implementation IQLabelView

@synthesize textLabel, originalBackgroundColor;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        
        UIImage *lblBGImg = [UIImage imageNamed:@"chart_group_background"];
        lblBGImg = [lblBGImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, lblBGImg.size.width/2-1, 0, lblBGImg.size.width/2-1) resizingMode:UIImageResizingModeStretch];
        self.viewBackground = [[UIImageView alloc] initWithFrame:self.bounds];
        self.viewBackground.image = lblBGImg;
        [self addSubview:self.viewBackground];
        CGRect b = self.bounds;
        b.origin.x = 5;
        b.origin.y = 0;
        b.size.width -= 2 * b.origin.x;
        b.size.height = self.bounds.size.height * 0.5f;
        textLabel = [[UILabel alloc] initWithFrame:b];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.opaque = NO;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.textColor = [UIColor whiteColor];
        [self addSubview:textLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        
        self.isHorizontalDraggable = YES;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.viewBackground.frame = self.bounds;
    CGRect b = self.bounds;
    b.origin.x = 5;
    b.origin.y = 0;
    b.size.width -= 2 * b.origin.x;
    b.size.height = self.bounds.size.height * 0.5f;
    textLabel.frame = b;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    originalBackgroundColor = backgroundColor;
    const CGFloat* ft = CGColorGetComponents([backgroundColor CGColor]);
}

- (void) setText:(NSString *)text
{
    textLabel.text = text;
}

- (NSString*) text
{
    return textLabel.text;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (highlighted){
        [UIView animateWithDuration:0.2 animations:^{
            
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            
        }];
    }
}

- (void)tapped
{
    if (settingsPopoverController == nil) {
        PopoverViewController *popViewController = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:nil];
        popViewController.blockClose = ^{
            [settingsPopoverController dismissPopoverAnimated:YES completion:^{
                [self popoverControllerDidDismissPopover:settingsPopoverController];
            }];
        };
        
        popViewController.modalInPopover = NO;
        
        settingsPopoverController = [[WYPopoverController alloc] initWithContentViewController:popViewController];
        settingsPopoverController.delegate = self;
        settingsPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        settingsPopoverController.theme = [WYPopoverTheme themeForPopover];
        
        [settingsPopoverController presentPopoverFromRect:self.bounds
                                                   inView:self
                                 permittedArrowDirections:WYPopoverArrowDirectionAny
                                                 animated:YES
                                                  options:WYPopoverAnimationOptionFadeWithScale];
    } else {
        [settingsPopoverController dismissPopoverAnimated:YES completion:^{
            [self popoverControllerDidDismissPopover:settingsPopoverController];
        }];
    }
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    //    NSLog(@"popoverControllerDidPresentPopover");
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == settingsPopoverController)
    {
        settingsPopoverController.delegate = nil;
        settingsPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

@end

