//
//  IQGanttView.m
//  IQWidgets for iOS
//
//  Copyright 2010 EvolvIQ
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

#import "IQGanttView.h"
#import <QuartzCore/QuartzCore.h>
#import "IQCalendarDataSource.h"
#import "IQCalendarHeaderView.h"


@interface IQGanttView ()
- (void) setupGanttView;
- (void) layoutOnRowsChange;
- (UIView*) blockViewForRow:(UIView*)rowView item:(id)item frame:(CGRect)frame;
@end

@implementation IQGanttView
@synthesize defaultRowHeight;

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGanttView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupGanttView];
    }
    return self;
}

- (void)setupGanttView
{
    calendar = [NSCalendar currentCalendar];
    defaultRowHeight = 40;
    displayCalendarUnits = NSWeekdayCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents* cmpnts = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    cmpnts.day -= 3;
    scaleWindow.viewStart = [[[NSCalendar currentCalendar] dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
    cmpnts.day += 5;
    scaleWindow.viewSize = [[[NSCalendar currentCalendar] dateFromComponents:cmpnts] timeIntervalSinceReferenceDate] - scaleWindow.viewStart;
    
    cmpnts.month = 1;
    scaleWindow.windowStart = [[[NSCalendar currentCalendar] dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
    cmpnts.year += 1;
    scaleWindow.windowEnd = [[[NSCalendar currentCalendar] dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
    NSLog(@"Date is %@ - %@", [NSDate dateWithTimeIntervalSinceReferenceDate:scaleWindow.viewStart], [NSDate dateWithTimeIntervalSinceReferenceDate:scaleWindow.viewSize+scaleWindow.viewStart]);
    NSLog(@"Date is %@ - %@", [NSDate dateWithTimeIntervalSinceReferenceDate:scaleWindow.windowStart], [NSDate dateWithTimeIntervalSinceReferenceDate:scaleWindow.windowEnd]);
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    [self addGestureRecognizer:pinch];
}

#pragma mark Layout


- (void) didMoveToWindow
{
    UIView* colHead = [self timeHeaderViewWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    if(colHead != nil) {
        if([colHead respondsToSelector:@selector(ganttView:shouldDisplayCalendarUnits:)]) {
            [(id<IQGanttHeaderDelegate>)colHead ganttView:self shouldDisplayCalendarUnits:displayCalendarUnits];
        }
        if([colHead respondsToSelector:@selector(ganttView:didChangeCalendar:)]) {
            [(id<IQGanttHeaderDelegate>)colHead ganttView:self didChangeCalendar:calendar];
        }
        
        self.columnHeaderView = colHead;
    }
    UIView* rowHead = [self rowHeaderViewWithFrame:CGRectMake(0, 0, 100, self.bounds.size.height)];
    if(rowHead != nil) self.rowHeaderView = rowHead;
    UIView* corner = [self cornerViewWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    if(corner != nil) self.cornerView = corner;
    [self layoutOnPropertyChange:YES];
}

- (void) layoutOnPropertyChange:(BOOL)didChangeZoom
{
    CGRect bds = self.bounds;
    CGFloat rel = (scaleWindow.windowEnd - scaleWindow.windowStart) / (scaleWindow.viewSize);
    
    CGSize csz;
    if(didChangeZoom) {
        self.contentSize = csz = CGSizeMake(rel * bds.size.width, bds.size.height);
    } else {
        csz = self.contentSize;
    }
    self.contentOffset = CGPointMake(self.contentSize.width * (scaleWindow.viewStart-scaleWindow.windowStart) / (scaleWindow.windowEnd - scaleWindow.windowStart), 0);
    
    if(didChangeZoom) {
        [self layoutOnRowsChange];
        if([self.columnHeaderView respondsToSelector:@selector(ganttView:didScaleWindow:)]) {
            [(id<IQGanttHeaderDelegate>)self.columnHeaderView ganttView:self didScaleWindow:scaleWindow];
        }
        for(UIView<IQGanttRowDelegate>* view in rowViews) {
            if([view respondsToSelector:@selector(ganttView:didScaleWindow:)]) {
                [(id<IQGanttRowDelegate>)view ganttView:self didScaleWindow:scaleWindow];
            }
        }
    } else {
        
    }
}

- (void)layoutOnRowsChange
{
    int y = 0;
    int heightContent = 0;
    if(columnHeaderView != nil) {
        y += columnHeaderView.frame.size.height;
    }
    for(int i = 0; i < rows.count; i++) {
        UIView<IQGanttRowDelegate>* view = rowViews[i];
        id<IQCalendarDataSource> data = rows[i];
        NSInteger height = defaultRowHeight;
        if([view respondsToSelector:@selector(ganttViewRowHeight)]) {
            height = [(id<IQGanttRowDelegate>)view ganttViewRowHeight];
        }
        view.frame = CGRectMake(0, y, self.contentSize.width, height);
        y += height;
        heightContent += height;
    }
    [self setContentSize:CGSizeMake(self.contentSize.width, heightContent)];
}

#pragma mark Properties

- (NSCalendarUnit)displayCalendarUnits
{
    return displayCalendarUnits;
}

- (void)setDisplayCalendarUnits:(NSCalendarUnit)dcu
{
    displayCalendarUnits = dcu;
    UIView* view = self.columnHeaderView;
    if(view != nil && [view respondsToSelector:@selector(ganttView:shouldDisplayCalendarUnits:)]) {
        [(id<IQGanttHeaderDelegate>)view ganttView:self shouldDisplayCalendarUnits:displayCalendarUnits];
    }
}

- (IQGanttViewTimeWindow)scaleWindow
{
    return scaleWindow;
}

- (void)setScaleWindow:(IQGanttViewTimeWindow)win
{
    if(win.viewSize < 60) win.viewSize = 60;
    if(win.windowStart > win.viewStart) win.viewStart = win.windowStart;
    if(win.windowEnd < win.viewStart + win.viewSize) win.viewSize = (win.windowEnd - win.windowStart) - (win.viewStart - win.windowStart) ;
    if(win.windowEnd - win.windowStart < 60) win.windowEnd = win.windowStart + 60;
    BOOL didChangeZoom = scaleWindow.windowStart != win.windowStart || scaleWindow.windowEnd != win.windowEnd || scaleWindow.viewSize != win.viewSize;
    scaleWindow = win;
    [self layoutOnPropertyChange:didChangeZoom];
}

- (UIColor*)backgroundColor
{
    return backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)bg
{
    [contentPanel setBackgroundColor:bg];
    backgroundColor = bg;
}

- (NSCalendar*)calendar
{
    return calendar;
}

- (void)setCalendar:(NSCalendar *)cal
{
    calendar = cal;
    
    if([columnHeaderView respondsToSelector:@selector(ganttView:didChangeCalendar:)]) {
        [(id<IQGanttHeaderDelegate>)columnHeaderView ganttView:self didChangeCalendar:calendar];
    }
    for(UIView* view in rowViews) {
        if([view respondsToSelector:@selector(ganttView:didChangeCalendar:)]) {
            [(id<IQGanttRowDelegate>)view ganttView:self didChangeCalendar:calendar];
        }
    }
}
#pragma mark Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    [super scrollViewDidScroll:sv];
    
    CGFloat cw = self.contentSize.width;
    if(cw > 0) {
        UIView* view = self.columnHeaderView;
        if (!isPinching) {
            scaleWindow.viewStart = self.contentOffset.x / cw * (scaleWindow.windowEnd - scaleWindow.windowStart) + scaleWindow.windowStart;
        }
        if(view != nil && [view respondsToSelector:@selector(ganttView:didMoveWindow:)]) {
            [(id<IQGanttHeaderDelegate>)view ganttView:self didMoveWindow:scaleWindow];
        }
    }
}

#pragma mark Data

- (void)removeAllRows
{
    for(UIView* view in rowViews) {
        [view removeFromSuperview];
    }
    [rows removeAllObjects];
    [rowViews removeAllObjects];
    [self layoutOnRowsChange];
}

- (void)addRow:(id<IQCalendarDataSource>)row
{
    UIView<IQGanttRowDelegate>* view = [self viewForRow:row withFrame:CGRectMake(0, 0, self.contentSize.width, self.bounds.size.height * 0.25)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:view];
    if(rows == nil) rows = [NSMutableArray new];
    if(rowViews == nil) rowViews = [NSMutableArray new];
    [rows addObject:row];
    [rowViews addObject:view];
    if([view respondsToSelector:@selector(ganttView:didChangeCalendar:)]) {
        [view ganttView:self didChangeCalendar:calendar];
    }
    if([view respondsToSelector:@selector(ganttView:didScaleWindow:)]) {
        [view ganttView:self didScaleWindow:scaleWindow];
    }
    if([view respondsToSelector:@selector(ganttView:didChangeDataSource:)]) {
        [view ganttView:self didChangeDataSource:row];
    }
    [view setNeedsDisplay];
    [self layoutOnRowsChange];
}

#pragma mark Default implementation of base methods

- (void)pinched:(UIPinchGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        isPinching = YES;
        scaleWindowBeforePinch = scaleWindow;
        lastPinchCenter = [gesture locationInView:self];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint centerOfTouch = [gesture locationInView:self];
        
        IQGanttViewTimeWindow newScaleWindow = scaleWindowBeforePinch;
        newScaleWindow.viewSize = scaleWindowBeforePinch.viewSize * 1/[gesture scale];
        newScaleWindow.viewStart = scaleWindow.viewStart - (newScaleWindow.viewSize - scaleWindow.viewSize) * ((centerOfTouch.x)/self.frame.size.width);
        [self setScaleWindow:newScaleWindow];
        
        lastPinchCenter = centerOfTouch;
    }
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        isPinching = NO;
        scaleWindowBeforePinch = scaleWindow;
    }
}

- (UIView*) cornerViewWithFrame:(CGRect)frame
{
    return nil;
}

- (UIView<IQGanttHeaderDelegate>*) timeHeaderViewWithFrame:(CGRect)frame
{
    return [[IQGanttHeaderView alloc] initWithFrame:frame];
}

- (UIView*) rowHeaderViewWithFrame:(CGRect)frame
{
    return nil;
}

- (UIView<IQGanttRowDelegate>*) viewForRow:(id<IQCalendarDataSource>)row withFrame:(CGRect)frame
{
    if ([row isKindOfClass:[WUTask class]]) {
        IQGanttRowView* result = [[IQGanttRowView alloc] initWithFrame:frame];
        return result;
    }
    if ([row isKindOfClass:[WULabel class]]) {
        IQGanttGroupRowView* result = [[IQGanttGroupRowView alloc] initWithFrame:frame];
        return result;
    }
    
    return nil;
}

@end

#pragma mark -
#pragma mark -

@implementation IQGanttHeaderView
@synthesize tintColor, monthNameFormatter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil) {
        monthNameFormatter = [[NSDateFormatter alloc] init];
        [monthNameFormatter setDateFormat:@"MMMM YYYY"];
        self.tintColor = [UIColor colorWithRed:98./255.0 green:183./255.0 blue:144./255.0 alpha:1];
        firstDayColor = [UIColor colorWithRed:200./255.0 green:80./255.0 blue:80./255.0 alpha:1];
        weekdaysLetters = [[NSCalendar currentCalendar] veryShortWeekdaySymbols];
        weekdaysShort = [[NSCalendar currentCalendar] shortWeekdaySymbols];
        weekdaysLong = [[NSCalendar currentCalendar] weekdaySymbols];
        
//        NSLog([weekdaysLong description]);
    }
    return self;
}

+ (Class) layerClass
{
    return [CATiledLayer class];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
    CGRect r = CGContextGetClipBoundingBox(ctx);
    CGSize size = self.bounds.size;
    CGContextSaveGState(ctx);
    if(grad != nil) {
//        CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
//        CGContextDrawLinearGradient(ctx, grad, CGPointMake(r.origin.x, r.origin.y), CGPointMake(r.origin.x, r.origin.y + r.size.height), 0);
        CGContextSetFillColorWithColor(ctx, [tintColor CGColor]);
        CGContextFillRect(ctx, self.bounds);
    }
    if(border != nil) {
        CGContextSetStrokeColorWithColor(ctx, border);
    }
    CGContextAddLines(ctx, (CGPoint[]){CGPointMake(r.origin.x, r.origin.y+r.size.height),
        CGPointMake(r.origin.x+r.size.width, r.origin.y+r.size.height)}, 2);
    CGContextStrokePath(ctx);
    CGFloat r0 = r.origin.x;
    CGFloat r1 = r.origin.x + r.size.width;
    CGFloat scl = (scaleWindow.windowEnd-scaleWindow.windowStart) / size.width;
    NSTimeInterval t0 = scaleWindow.windowStart + scl * r0;
    NSTimeInterval t1 = scaleWindow.windowStart + scl * r1;
    UIFont* textFont = [UIFont systemFontOfSize:8];
    NSCalendar* calendar = [cal copy];
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        int fwd = [calendar firstWeekday];
        NSDate* d = [NSDate dateWithTimeIntervalSinceReferenceDate:t0];
        // Days
        NSDateComponents* cmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:d];
        NSTimeInterval t = [[calendar dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
        CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
        CGContextSetTextMatrix(ctx, xform);
        CGContextSelectFont(ctx, [textFont.fontName cStringUsingEncoding:NSUTF8StringEncoding], 10, kCGEncodingMacRoman);
        CGContextSetFontSize(ctx, 10);
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
        while (t <= t1) {
            NSDateComponents* c2 = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit fromDate:d];
            int wd = c2.weekday;
            int md = c2.day;
            int wk = c2.week;
            CGFloat scale = 0.6;
            if(border != nil) {
                CGContextSetStrokeColorWithColor(ctx, border);
            }
            if(wd == fwd && displayCalendarUnits & NSWeekCalendarUnit) {
                CGContextSetStrokeColorWithColor(ctx, [textColor CGColor]);
                scale = 0.4;
            }
            if(md == 1) {
                CGContextSetStrokeColorWithColor(ctx, [textColor CGColor]);
                scale = 0;
            }
            
            CGFloat x = round(r0 + (t-t0) / scl)+.5;
            
            CGFloat dayWidth = round((60*60*24)/scl);
            
            CGContextAddLines(ctx, (CGPoint[]){CGPointMake(x, r.origin.y+scale*r.size.height), CGPointMake(x, r.origin.y + r.size.height)}, 2);
            
//            CGContextStrokePath(ctx);
            
            /*[@"Apan" drawAtPoint:CGPointMake(x, r.origin.y + r.size.height - 18) forWidth:30 withFont:textFont minFontSize:6 actualFontSize:nil lineBreakMode:UILineBreakModeClip baselineAdjustment:UIBaselineAdjustmentNone];*/
            //CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
            char str[12] = "";
            if(displayCalendarUnits & NSWeekdayCalendarUnit) {
                if(displayCalendarUnits & NSDayCalendarUnit) {
                    NSString *weekDayString = weekdaysLong[wd-1];
                    CGFloat weekDayStringWidth = [[NSString stringWithFormat:@"%@ %d", weekDayString, md] sizeWithFont:[UIFont systemFontOfSize:10]].width;
                    if (weekDayStringWidth + 5 > dayWidth) {
                        weekDayString = weekdaysShort[wd-1];
                        weekDayStringWidth = [[NSString stringWithFormat:@"%@ %d", weekDayString, md] sizeWithFont:[UIFont systemFontOfSize:10]].width;
                        if (weekDayStringWidth + 5 > dayWidth) {
                            weekDayString = weekdaysLetters[wd-1];
                            weekDayStringWidth = [[NSString stringWithFormat:@"%@ %d", weekDayString, md] sizeWithFont:[UIFont systemFontOfSize:10]].width;
                            if (weekDayStringWidth + 5 > dayWidth) {
                                weekDayString = @"";
                            }
                        }
                    }
                    if ([weekDayString isEqualToString:@""]) {
                        snprintf(str, sizeof(str), "%d", md);
                    } else {
                        snprintf(str, sizeof(str), "%s %d", [weekDayString cStringUsingEncoding:NSUTF8StringEncoding], md);
                    }
                } else {
                    
                    NSString *weekDayString = weekdaysLong[wd-1];
                    CGFloat weekDayStringWidth = [[NSString stringWithFormat:@"%@", weekDayString] sizeWithFont:[UIFont systemFontOfSize:10]].width;
                    if (weekDayStringWidth > dayWidth) {
                        weekDayString = weekdaysShort[wd-1];
                        weekDayStringWidth = [[NSString stringWithFormat:@"%@", weekDayString] sizeWithFont:[UIFont systemFontOfSize:10]].width;
                        if (weekDayStringWidth > dayWidth) {
                            weekDayString = weekdaysLetters[wd-1];
                        }
                    }
                    snprintf(str, sizeof(str), "%s", [weekDayString cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            } else {
                if(displayCalendarUnits & NSDayCalendarUnit) {
                    snprintf(str, sizeof(str), "%d", md);
                }
            }
            if(str[0] != 0) {
                //for white shadow of the text
//                CGContextSetRGBFillColor (ctx, 1, 1, 1, 1);
//                CGContextShowTextAtPoint(ctx, round(x + 3), round(r.origin.y + r.size.height - 3), str, strlen(str));
                
                if(wd == fwd) {
                    CGContextSetFillColorWithColor(ctx, [firstDayColor CGColor]);
                } else {
                    CGContextSetFillColorWithColor(ctx, [textColor CGColor]);
                }
                CGContextShowTextAtPoint(ctx, round(x + 3), round(r.origin.y + r.size.height - 4), str, strlen(str));
            }
            if(wd == fwd && displayCalendarUnits & NSWeekCalendarUnit) {
                CGContextSetFillColorWithColor(ctx, [textColor CGColor]);
                strncpy(str, [IQLocalizationFormatWeekNumber(wk) UTF8String], sizeof(str));
                CGContextShowTextAtPoint(ctx, round(x + 3), round(r.origin.y + 0.4*r.size.height + 10), str, strlen(str));
            }
            
            cmpnts.day += 1;
            d = [calendar dateFromComponents:cmpnts];
            t = [d timeIntervalSinceReferenceDate];
            
            CGContextStrokePath(ctx);
        }
//        CGContextSetShadowWithColor(ctx, CGSizeMake(1, 0), 0, [[UIColor colorWithWhite:1 alpha:.5] CGColor]);
        
        CGContextStrokePath(ctx);
        //NSLog(@"Drawing layer: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:t0]);
    }
    CGContextRestoreGState(ctx);
}

- (UILabel*)floatAtIndex:(int)index
{
    if(floatingLabels == nil) {
        floatingLabels = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    while(index >= floatingLabels.count) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 16)];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:.15 green:.1 blue:0 alpha:1];
//        label.shadowColor = [UIColor whiteColor];
//        label.shadowOffset = CGSizeMake(0, 1);
        //label.lineBreakMode = UILineBreakModeClip;
        [self addSubview:label];
        [floatingLabels addObject:label];
    }
    return floatingLabels[index];
}

- (void)moveLabels
{
    NSTimeInterval t0 = scaleWindow.viewStart;
    NSTimeInterval t1 = scaleWindow.viewStart + scaleWindow.viewSize;
    
    NSCalendar* calendar = [cal copy];
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        NSDate* d = [NSDate dateWithTimeIntervalSinceReferenceDate:t0];
        NSDateComponents* cmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:d];
        cmpnts.day = 1;
        cmpnts.month += 1;
        NSDate* od = d;
        d = [calendar dateFromComponents:cmpnts];
        NSTimeInterval t = [d timeIntervalSinceReferenceDate];
        int i = 0;
        CGFloat scl = self.bounds.size.width / (scaleWindow.windowEnd-scaleWindow.windowStart);
        CGRect bnds = CGRectMake(0, 0, 200, 18);
        while(t0 <= t1) {
            bnds.origin.x = 4 + round((t0-scaleWindow.windowStart) * scl);
            if(offset < 0 && t0 <= scaleWindow.viewStart) {
                bnds.origin.x -= offset;
            }
            CGFloat w = round((t-scaleWindow.windowStart) * scl) - bnds.origin.x;
            if(w > 20) {
                UILabel* lbl = [self floatAtIndex:i++];
                lbl.textColor = [UIColor colorWithWhite:0.3 alpha:1];
                lbl.hidden = NO;
                lbl.frame = bnds;
                lbl.text = [monthNameFormatter stringFromDate:od];
                CGFloat a = (w-20) / 100;
                if(a > 1) a = 1;
                lbl.alpha = a;
            }
            cmpnts.month += 1;
            t0 = t;
            od = d;
            d = [calendar dateFromComponents:cmpnts];
            t = [d timeIntervalSinceReferenceDate];
        }
        for(;i<floatingLabels.count; i++) {
            [[self floatAtIndex:i] setHidden:YES];
        }
    }
    
    /*if(firstLineLabel == nil) {
     }
     firstLineLabel.center = CGPointMake(offset+100, 8);*/
}

- (void)ganttView:(IQGanttView *)view didScaleWindow:(IQGanttViewTimeWindow)win
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    scaleWindow = win;
    offset = view.contentOffset.x;
    [self moveLabels];
    [self setNeedsDisplay];
}

- (void)ganttView:(IQGanttView *)view didMoveWindow:(IQGanttViewTimeWindow)win
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    scaleWindow = win;
    offset = view.contentOffset.x;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.contentSize.width, self.frame.size.height);
    [self moveLabels];
}

- (void)ganttView:(IQGanttView*)view shouldDisplayCalendarUnits:(NSCalendarUnit) dcu
{
    displayCalendarUnits = dcu;
    [self setNeedsDisplay];
}

- (void)ganttView:(IQGanttView *)view didChangeCalendar:(NSCalendar*)calendar
{
    cal = calendar;
    [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tc
{
    tintColor = tc;
    CGColorRef tint = [tc CGColor];
    const CGFloat* cmpnts = CGColorGetComponents(tint);
    CGFloat colors[] = {
        cmpnts[0]+.16, cmpnts[1]+.16, cmpnts[2]+.16, 1,
        cmpnts[0], cmpnts[1], cmpnts[2], 1,
        cmpnts[0]-.12, cmpnts[1]-.12, cmpnts[2]-.12, 1,
    };
    CGGradientRef gd = CGGradientCreateWithColorComponents(CGColorGetColorSpace(tint), colors, (CGFloat[]){0,1}, 2);
    CGColorRef bd = CGColorCreate(CGColorGetColorSpace(tint), colors+8);
    CGColorRef oldBorder = border;
    CGGradientRef oldGrad = grad;
    
    grad = CGGradientRetain(gd);
    border = CGColorRetain(bd);
    
    if(oldGrad != nil) {
        CGGradientRelease(oldGrad);
    }
    if(oldBorder != nil) {
        CGColorRelease(oldBorder);
    }
    border = CGColorRetain([[UIColor colorWithRed:cmpnts[0]*.7 green:cmpnts[1]*.7 blue:cmpnts[2]*.7 alpha:1] CGColor]);
    textColor = [UIColor colorWithRed:cmpnts[0]*.5 green:cmpnts[1]*.5 blue:cmpnts[2]*.5 alpha:1];
    textTitleColor = [UIColor colorWithRed:cmpnts[0]*.2 green:cmpnts[1]*.2 blue:cmpnts[2]*.2 alpha:1];
}

@end

#pragma mark -
#pragma mark -

@implementation IQGanttRowView
@synthesize dataSource, primaryGridColor, secondaryGridColor, tertaryGridColor, primaryGridDash, secondaryGridDash, tertaryGridDash;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        primaryGridColor = [UIColor grayColor];
        secondaryGridColor = [UIColor grayColor];
        tertaryGridColor = [UIColor colorWithWhite:0.8 alpha:1];
        primaryLineUnits = NSMonthCalendarUnit;
        secondaryLineUnits = NSWeekCalendarUnit;
        tertaryLineUnits = NSDayCalendarUnit;
        secondaryGridDash = IQMakeGridDash(5, 5);
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

+ (Class) layerClass
{
    return [CATiledLayer class];
}

- (void) layoutItems:(IQGanttView*)gantt
{
    while(self.subviews.count > 0) {
        [[self.subviews lastObject] removeFromSuperview];
    }
    NSTimeInterval t0 = scaleWindow.windowStart;
    NSTimeInterval t1 = scaleWindow.windowEnd;
    CGSize sz = self.bounds.size;
    CGFloat tscl = sz.width / (t1 - t0);
    
    // change this block parameter for our model -> like that the view-controller can change the model
    NSTimeInterval startTime = [[self.dataSource startDate] timeIntervalSinceReferenceDate];
    
    UIColor* color = [self.dataSource color];
    if (!color) {
        color = [UIHelper colorFromHex:TASK_COLOR];
    }
    NSString *title = [self.dataSource title];
    NSArray *subFrames = [self getSubFrames];
    CGRect lastFrame = [[subFrames lastObject] CGRectValue];
    
    NSTimeInterval estimatedTime =  (lastFrame.origin.x + lastFrame.size.width)/tscl;
    if(startTime > t1 || startTime + estimatedTime < t0) {
        return;
    }
    CGRect frame = CGRectMake((startTime-t0)*tscl, 0, estimatedTime*tscl, sz.height);
    
    IQTaskView* view = [[IQTaskView alloc] initWithFrame:frame subFrames:subFrames];
    view.text = title;
    view.contentMode = UIViewContentModeCenter;
    view.backgroundColor = color;
    [view setHighlighted:NO];
    view.delegate = self;
    
    [self addSubview:view];
}

- (NSArray*)getSubFrames
{
    NSMutableArray* result = [NSMutableArray array];
    NSTimeInterval t0 = scaleWindow.windowStart;
    NSTimeInterval t1 = scaleWindow.windowEnd;
    CGSize sz = self.bounds.size;
    CGFloat tscl = sz.width / (t1 - t0);
    
    NSDate *originalStartDate = [self.dataSource startDate];
    NSTimeInterval originalStartTime = [originalStartDate timeIntervalSinceReferenceDate];
    NSDate *startDate = [self.dataSource startDate];
    NSDate *endDate = [self.dataSource endDate];
    
//    NSTimeInterval estimatedTime = [[self.dataSource estimatedTime] floatValue];
    
    NSDate* unwantedDate = [self getNextUnwantedDayForStartDate:startDate];
    
    while ([endDate timeIntervalSinceReferenceDate] > [startDate timeIntervalSinceReferenceDate]) {
        NSTimeInterval endTime = [unwantedDate timeIntervalSinceReferenceDate];
        NSTimeInterval startTime = [startDate timeIntervalSinceReferenceDate];
        if (endTime > startTime) {
            CGRect frame ;
            if (endTime < [endDate timeIntervalSinceReferenceDate]) {
                frame = CGRectMake((startTime - originalStartTime)*tscl, 0, (endTime-startTime)*tscl, sz.height);
            } else {
                frame = CGRectMake((startTime - originalStartTime)*tscl, 0, ([endDate timeIntervalSinceReferenceDate]-startTime)*tscl, sz.height);
            }
            [result addObject:[NSValue valueWithCGRect:frame]];
        }
        startDate = [unwantedDate dateByAddingTimeInterval:60*60*24];
        unwantedDate = [self getNextUnwantedDayForStartDate:startDate];
    }

    return result;
}

- (NSDate*)getNextUnwantedDayForStartDate:(NSDate*)startDate
{
    NSCalendar* calendar = [cal copy];
    NSDateComponents* cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
    NSDate* result = [calendar dateFromComponents:cmpnts];
    while ( cmpnts.weekday != 1 && cmpnts.weekday != 7 ) {
        cmpnts.day ++;
        result = [calendar dateFromComponents:cmpnts];
        cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:result];
    }
    return result;
}

- (void)ganttView:(IQGanttView *)view didChangeDataSource:(id<IQCalendarDataSource>)ds
{
    self.dataSource = ds;
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        [self layoutItems:view];
    }
}

- (void)ganttView:(IQGanttView *)view didChangeCalendar:(NSCalendar*)calendar
{
    NSCalendar* oldCal = cal;
    cal = calendar;
    [self setNeedsDisplay];
}

#pragma Grid properties

- (void)setPrimaryGridColor:(UIColor *)gcl
{
    primaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setSecondaryGridColor:(UIColor *)gcl
{
    secondaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setTertaryGridColor:(UIColor *)gcl
{
    tertaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setPrimaryGridDash:(IQGridDash)gd
{
    primaryGridDash = gd;
    [self setNeedsDisplay];
}

- (void)setSecondaryGridDash:(IQGridDash)gd
{
    secondaryGridDash = gd;
    [self setNeedsDisplay];
}

- (void)setTertaryGridDash:(IQGridDash)gd
{
    tertaryGridDash = gd;
    [self setNeedsDisplay];
}

#pragma mark Drawing

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
//    NSLog(@"%s, %@", __PRETTY_FUNCTION__, NSStringFromCGRect(self.bounds));
    
    CGRect r = CGContextGetClipBoundingBox(ctx);
    CGContextSetFillColorWithColor(ctx, [[self backgroundColor] CGColor]);
    CGContextFillRect(ctx, r);
    //CGRect r2 = CGRectMake(r.origin.x + 3, r.origin.y + 3, r.size.width-6, r.size.height-6);
    //CGContextStrokeRect(ctx, r2);
    CGSize size = self.bounds.size;
    //if(gridColor != nil) CGContextSetStrokeColorWithColor(ctx, [gridColor CGColor]);
    CGFloat r0 = r.origin.x;
    CGFloat r1 = r.origin.x + r.size.width;
    CGFloat scl = (scaleWindow.windowEnd-scaleWindow.windowStart) / size.width;
    NSTimeInterval t0 = scaleWindow.windowStart + scl * r0;
    NSTimeInterval t1 = scaleWindow.windowStart + scl * r1;
    CGContextSaveGState(ctx);
    
    CGColorRef colorRefDayOff = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chart_background_dayoff2"]].CGColor;
    
    //CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    //CGContextSetTextMatrix(ctx, xform);
    //CGContextSelectFont(ctx, "Helvetica", 10, kCGEncodingMacRoman);
    //CGContextSetFontSize(ctx, 10);
    //CGContextSetTextDrawingMode(ctx, kCGTextFill);
    //CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    NSCalendar* calendar = [cal copy];
    IQGridDash prevGridDash = IQMakeGridDash(0, 0);
    UIColor* prevGridColor = nil;
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        int fwd = [calendar firstWeekday];
        NSDate* d = [NSDate dateWithTimeIntervalSinceReferenceDate:t0];
        // Days
        NSDateComponents* cmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:d];
        cmpnts.hour = cmpnts.minute = cmpnts.second = 0;
        d = [calendar dateFromComponents:cmpnts];
        NSTimeInterval t = [[calendar dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
        CGFloat dayWidth = round((60*60*24)/scl);
        //int text = 0;
        while (t <= t1) {
            NSDateComponents* c2 = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:d];
            int wd = c2.weekday;
            int md = c2.day;
            int hd = c2.hour;
            CGFloat x = round(r0 + (t-t0) / scl)+.5;
            
            BOOL l1 = NO, l2 = NO, l3 = NO;
            
            if(primaryLineUnits & NSDayCalendarUnit) {
                l1 = YES;
            }
            if(secondaryLineUnits & NSDayCalendarUnit) {
                l2 = YES;
            }
            if(tertaryLineUnits & NSDayCalendarUnit) {
                l3 = YES;
            }
            if(wd == fwd && hd == 0) {
                if(primaryLineUnits & NSWeekCalendarUnit) {
                    l1 = YES;
                }
                if(secondaryLineUnits & NSWeekCalendarUnit) {
                    l2 = YES;
                }
                if(tertaryLineUnits & NSWeekCalendarUnit) {
                    l3 = YES;
                }
            }
            if(md == 1 && hd == 0) {
                if(primaryLineUnits & NSMonthCalendarUnit) {
                    l1 = YES;
                }
                if(secondaryLineUnits & NSMonthCalendarUnit) {
                    l2 = YES;
                }
                if(tertaryLineUnits & NSMonthCalendarUnit) {
                    l3 = YES;
                }
            }
            /*if(YES) {
                char buf[1024];
                snprintf(buf, sizeof(buf), "%d %d %c%c%c %f", wd, md, l1?'1':' ', l2?'2':' ', l3?'3':' ', t);
                CGContextShowTextAtPoint(ctx, r.origin.x + 20, r.origin.y+20+text*15, buf, strlen(buf));
                text ++;
                //text = NO;
             }*/
            if ((wd == 1 || wd == 7) && hd == 0) {
                CGContextSetFillColorWithColor(ctx, colorRefDayOff);
                CGContextFillRect(ctx, CGRectMake(x, r.origin.y, dayWidth, r.size.height));
            }
            CGContextAddLines(ctx, (CGPoint[]){CGPointMake(x, r.origin.y), CGPointMake(x, r.size.height + r.origin.y)}, 2);
                        
            IQGridDash gd;
            UIColor* color = nil;
            if(l1) {
                gd = primaryGridDash;
                color = primaryGridColor;
            } else if(l2) {
                gd = secondaryGridDash;
                color = secondaryGridColor;
            } else if(l3) {
                gd = tertaryGridDash;
                color = tertaryGridColor;
            }
            if(color != nil) {
                if(YES || gd.a != prevGridDash.a || gd.b != prevGridDash.b || color != prevGridColor) {
                    prevGridDash = gd;
                    prevGridColor = color;
                    if (hd == 12) {
                        CGContextSetLineWidth(ctx, 0.5);
                        CGContextSetLineDash(ctx, 0, nil, 0);
                    } else if (hd == 6 || hd == 18) {
                        CGContextSetLineWidth(ctx, 0.5);
                        CGContextSetLineDash(ctx, r.origin.y+self.frame.origin.y, (CGFloat[]){3, 3}, 2);
                    } else {
                        CGContextSetLineWidth(ctx, 1);
                        if(gd.a != 0 || gd.b != 0) {
                            CGContextSetLineDash(ctx, r.origin.y+self.frame.origin.y, (CGFloat[]){gd.a, gd.b}, 2);
                        } else {
                            CGContextSetLineDash(ctx, 0, nil, 0);
                        }
                    }
                    CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
                    CGContextStrokePath(ctx);
                }
            }
            
            CGFloat dayWidth = round((60*60*24)/scl);
            
            if (dayWidth > 80) {
                if (hd != 18) {
                    cmpnts.hour += 6;
                } else {
                    cmpnts.hour = 0;
                    cmpnts.day += 1;
                }
            } else if (dayWidth > 40) {
                if (hd == 0) {
                    cmpnts.hour += 12;
                } else {
                    cmpnts.hour = 0;
                    cmpnts.day += 1;
                }
            } else {
                cmpnts.day += 1;
            }
            d = [calendar dateFromComponents:cmpnts];
            t = [d timeIntervalSinceReferenceDate];
        }
    }
    CGContextRestoreGState(ctx);
}

- (void)ganttView:(IQGanttView *)gantt didScaleWindow:(IQGanttViewTimeWindow)win
{
    scaleWindow = win;
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        [self layoutItems:gantt];
    }
    [self setNeedsDisplay];
}

#pragma mark - TKDragViewDelegate

- (void)dragViewDidStartDragging:(TKDragView *)dragView
{
    if ([dragView isKindOfClass:[IQTaskView class]]) {
        IQTaskView *taskView = (IQTaskView*) dragView;
        [taskView setHighlighted:YES];
    }
}

- (void)dragViewDidEndDragging:(TKDragView *)dragView
{
    if ([dragView isKindOfClass:[IQTaskView class]]) {
        IQTaskView *taskView = (IQTaskView*) dragView;
        [taskView setHighlighted:NO];
    }
}

- (void)dragViewDidMove:(TKDragView *)dragView
{
    if ([dragView isKindOfClass:[IQTaskView class]]) {
        IQTaskView *taskView = (IQTaskView*) dragView;
        
        NSTimeInterval t0 = scaleWindow.windowStart;
        NSTimeInterval t1 = scaleWindow.windowEnd;
        CGSize sz = self.bounds.size;
        CGFloat tscl = sz.width / (t1 - t0);
        CGFloat originX = taskView.frame.origin.x;
        
        NSTimeInterval startTime = t0 + originX/tscl;
        
        [self.dataSource setStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:startTime]];
        NSTimeInterval newStartTime = [[self.dataSource startDate] timeIntervalSinceReferenceDate];
        
        NSTimeInterval diff = newStartTime - startTime;
        if (diff != 0) {
            dragView.offsetStartLocation = CGPointMake(dragView.offsetStartLocation.x + diff*tscl, dragView.offsetStartLocation.y);
        }
        
        NSArray *subFrames = [self getSubFrames];
        
        [taskView updateViewsWithFrames:subFrames];
        [taskView setHighlighted:taskView.highlighted];
        
        if ([self.delegate respondsToSelector:@selector(ganttRowView:didChangeDataSource:)]) {
            [self.delegate ganttRowView:self didChangeDataSource:self.dataSource];
        }
    }
}

@end

#pragma mark -
#pragma mark -

@implementation IQGanttGroupRowView
@synthesize dataSource, primaryGridColor, secondaryGridColor, tertaryGridColor, primaryGridDash, secondaryGridDash, tertaryGridDash;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        primaryGridColor = [UIColor grayColor];
        secondaryGridColor = [UIColor grayColor];
        tertaryGridColor = [UIColor colorWithWhite:0.8 alpha:1];
        primaryLineUnits = NSMonthCalendarUnit;
        secondaryLineUnits = NSWeekCalendarUnit;
        tertaryLineUnits = NSDayCalendarUnit;
        secondaryGridDash = IQMakeGridDash(5, 5);
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (Class) layerClass
{
    return [CATiledLayer class];
}

- (void) layoutItems:(IQGanttView*)gantt
{
    while(self.subviews.count > 0) {
        [[self.subviews lastObject] removeFromSuperview];
    }
    
    if(rowViews == nil) rowViews = [NSMutableArray new];
    [rowViews removeAllObjects];
    
    for (id<IQCalendarDataSource> row in self.dataSource.listOfTask) {
        IQGanttRowView* view = (IQGanttRowView*)[gantt viewForRow:row withFrame:CGRectMake(0, 0, gantt.contentSize.width, self.height)];
        view.delegate = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:view];
        [rowViews addObject:view];
        if([view respondsToSelector:@selector(ganttView:didChangeDataSource:)]) {
            [view ganttView:gantt didChangeDataSource:row];
        }
        if([view respondsToSelector:@selector(ganttView:didChangeCalendar:)]) {
            [view ganttView:gantt didChangeCalendar:cal];
        }
    }
    [self layoutOnRowsChange];
    
    NSTimeInterval t0 = scaleWindow.windowStart;
    NSTimeInterval t1 = scaleWindow.windowEnd;
    CGSize sz = self.bounds.size;
    CGFloat tscl = sz.width / (t1 - t0);
    
    // change this block parameter for our model -> like that the view-controller can change the model
    NSTimeInterval startTime = [[self.dataSource startDate] timeIntervalSinceReferenceDate];
    NSTimeInterval endTime = [[self.dataSource endDate] timeIntervalSinceReferenceDate];
    
    NSString *title = [self.dataSource title];
    
    if(startTime > t1 || endTime < t0) {
        return;
    }
    CGRect frame = CGRectMake((startTime-t0)*tscl, 0, (endTime-startTime)*tscl, gantt.defaultRowHeight);
    
    self.highlightedView = [[UIView alloc] initWithFrame:CGRectMake((startTime-t0)*tscl, 0, (endTime-startTime)*tscl, (self.dataSource.listOfTask.count+1)*gantt.defaultRowHeight)];
    self.highlightedView.backgroundColor = [UIColor lightGrayColor];
    self.highlightedView.alpha = 0.5;
    [self.highlightedView setHidden:YES];
    [self addSubview:self.highlightedView];
    
    self.groupView = [[IQLabelView alloc] initWithFrame:frame];
    self.groupView.text = title;
    self.groupView.contentMode = UIViewContentModeCenter;
    [self.groupView setHighlighted:NO];
    self.groupView.delegate = self;
    
    [self addSubview:self.groupView];
}

- (void) updateGroupView
{
    [self.groupView removeFromSuperview];
    
    NSTimeInterval t0 = scaleWindow.windowStart;
    NSTimeInterval t1 = scaleWindow.windowEnd;
    CGSize sz = self.bounds.size;
    CGFloat tscl = sz.width / (t1 - t0);
    
    // change this block parameter for our model -> like that the view-controller can change the model
    NSTimeInterval startTime = [[self.dataSource startDate] timeIntervalSinceReferenceDate];
    NSTimeInterval endTime = [[self.dataSource endDate] timeIntervalSinceReferenceDate];
    
    NSString *title = [self.dataSource title];
    
    if(startTime > t1 || endTime < t0) {
        return;
    }
    CGRect frame = CGRectMake((startTime-t0)*tscl, 0, (endTime-startTime)*tscl, self.height);
    
    self.highlightedView.frame = CGRectMake((startTime-t0)*tscl, 0, (endTime-startTime)*tscl, (self.dataSource.listOfTask.count+1)*self.height);
    
    self.groupView = [[IQLabelView alloc] initWithFrame:frame];
    self.groupView.text = title;
    self.groupView.contentMode = UIViewContentModeCenter;
    [self.groupView setHighlighted:NO];
    self.groupView.delegate = self;
    
    [self addSubview:self.groupView];
}

- (void)layoutOnRowsChange
{
    int y = self.height;
    int heightContent = self.height;
    CGFloat minX = 0, maxX = 0;
    for(int i = 0; i < rowViews.count; i++) {
        UIView<IQGanttRowDelegate>* view = rowViews[i];
        NSInteger height = self.height;
        if([view respondsToSelector:@selector(ganttViewRowHeight:withData:)]) {
            height = [(id<IQGanttRowDelegate>)view ganttViewRowHeight];
        }
        view.frame = CGRectMake(0, y, self.bounds.size.width, height);
        y += height;
        heightContent += height;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, heightContent);
}

- (void)ganttView:(IQGanttView *)view didChangeDataSource:(id<IQCalendarDataSource>)ds
{
    self.height = view.defaultRowHeight;
    self.dataSource = ds;
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        [self layoutItems:view];
    }
}

- (void)ganttView:(IQGanttView *)view didChangeCalendar:(NSCalendar*)calendar
{
    self.height = view.defaultRowHeight;
    NSCalendar* oldCal = cal;
    cal = calendar;
    [self setNeedsDisplay];
}

- (CGFloat)ganttViewRowHeight
{
    return self.height * (rowViews.count + 1);
}

#pragma Grid properties

- (void)setPrimaryGridColor:(UIColor *)gcl
{
    primaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setSecondaryGridColor:(UIColor *)gcl
{
    secondaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setTertaryGridColor:(UIColor *)gcl
{
    tertaryGridColor = gcl;
    [self setNeedsDisplay];
}

- (void)setPrimaryGridDash:(IQGridDash)gd
{
    primaryGridDash = gd;
    [self setNeedsDisplay];
}

- (void)setSecondaryGridDash:(IQGridDash)gd
{
    secondaryGridDash = gd;
    [self setNeedsDisplay];
}

- (void)setTertaryGridDash:(IQGridDash)gd
{
    tertaryGridDash = gd;
    [self setNeedsDisplay];
}

#pragma mark Drawing

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    
    CGRect r = CGContextGetClipBoundingBox(ctx);
    CGContextSetFillColorWithColor(ctx, [[self backgroundColor] CGColor]);
    CGContextFillRect(ctx, r);
    //CGRect r2 = CGRectMake(r.origin.x + 3, r.origin.y + 3, r.size.width-6, r.size.height-6);
    //CGContextStrokeRect(ctx, r2);
    CGSize size = self.bounds.size;
//    size.height = self.height
    
    //if(gridColor != nil) CGContextSetStrokeColorWithColor(ctx, [gridColor CGColor]);
    CGFloat r0 = r.origin.x;
    CGFloat r1 = r.origin.x + r.size.width;
    CGFloat scl = (scaleWindow.windowEnd-scaleWindow.windowStart) / size.width;
    NSTimeInterval t0 = scaleWindow.windowStart + scl * r0;
    NSTimeInterval t1 = scaleWindow.windowStart + scl * r1;
    CGContextSaveGState(ctx);
    CGColorRef colorRefDayOff = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chart_background_dayoff2"]].CGColor;
    
    NSCalendar* calendar = [cal copy];
    IQGridDash prevGridDash = IQMakeGridDash(0, 0);
    UIColor* prevGridColor = nil;
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        int fwd = [calendar firstWeekday];
        NSDate* d = [NSDate dateWithTimeIntervalSinceReferenceDate:t0];
        // Days
        NSDateComponents* cmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:d];
        cmpnts.hour = cmpnts.minute = cmpnts.second = 0;
        d = [calendar dateFromComponents:cmpnts];
        NSTimeInterval t = [[calendar dateFromComponents:cmpnts] timeIntervalSinceReferenceDate];
        
        CGFloat dayWidth = round((60*60*24)/scl);
        //int text = 0;
        while (t <= t1) {
            NSDateComponents* c2 = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:d];
            int wd = c2.weekday;
            int md = c2.day;
            int hd = c2.hour;
            CGFloat x = round(r0 + (t-t0) / scl)+.5;
            
            BOOL l1 = NO, l2 = NO, l3 = NO;
            
            if(primaryLineUnits & NSDayCalendarUnit) {
                l1 = YES;
            }
            if(secondaryLineUnits & NSDayCalendarUnit) {
                l2 = YES;
            }
            if(tertaryLineUnits & NSDayCalendarUnit) {
                l3 = YES;
            }
            if(wd == fwd && hd == 0) {
                if(primaryLineUnits & NSWeekCalendarUnit) {
                    l1 = YES;
                }
                if(secondaryLineUnits & NSWeekCalendarUnit) {
                    l2 = YES;
                }
                if(tertaryLineUnits & NSWeekCalendarUnit) {
                    l3 = YES;
                }
            }
            if(md == 1 && hd == 0) {
                if(primaryLineUnits & NSMonthCalendarUnit) {
                    l1 = YES;
                }
                if(secondaryLineUnits & NSMonthCalendarUnit) {
                    l2 = YES;
                }
                if(tertaryLineUnits & NSMonthCalendarUnit) {
                    l3 = YES;
                }
            }
            /*if(YES) {
             char buf[1024];
             snprintf(buf, sizeof(buf), "%d %d %c%c%c %f", wd, md, l1?'1':' ', l2?'2':' ', l3?'3':' ', t);
             CGContextShowTextAtPoint(ctx, r.origin.x + 20, r.origin.y+20+text*15, buf, strlen(buf));
             text ++;
             //text = NO;
             }*/
            if ((wd == 1 || wd == 7) && hd == 0) {
                CGContextSetFillColorWithColor(ctx, colorRefDayOff);
                CGContextFillRect(ctx, CGRectMake(x, r.origin.y, dayWidth, r.size.height));
            }
            CGContextAddLines(ctx, (CGPoint[]){CGPointMake(x, r.origin.y), CGPointMake(x, r.size.height + r.origin.y)}, 2);
            
            IQGridDash gd;
            UIColor* color = nil;
            if(l1) {
                gd = primaryGridDash;
                color = primaryGridColor;
            } else if(l2) {
                gd = secondaryGridDash;
                color = secondaryGridColor;
            } else if(l3) {
                gd = tertaryGridDash;
                color = tertaryGridColor;
            }
            if(color != nil) {
                if(YES || gd.a != prevGridDash.a || gd.b != prevGridDash.b || color != prevGridColor) {
                    prevGridDash = gd;
                    prevGridColor = color;
                    if (hd == 12) {
                        CGContextSetLineWidth(ctx, 0.5);
                        CGContextSetLineDash(ctx, 0, nil, 0);
                    } else if (hd == 6 || hd == 18) {
                        CGContextSetLineWidth(ctx, 0.5);
                        CGContextSetLineDash(ctx, r.origin.y+self.frame.origin.y, (CGFloat[]){3, 3}, 2);
                    } else {
                        CGContextSetLineWidth(ctx, 1);
                        if(gd.a != 0 || gd.b != 0) {
                            CGContextSetLineDash(ctx, r.origin.y+self.frame.origin.y, (CGFloat[]){gd.a, gd.b}, 2);
                        } else {
                            CGContextSetLineDash(ctx, 0, nil, 0);
                        }
                    }
                    CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
                    CGContextStrokePath(ctx);
                }
            }
            
            CGFloat dayWidth = round((60*60*24)/scl);
            
            if (dayWidth > 80) {
                if (hd != 18) {
                    cmpnts.hour += 6;
                } else {
                    cmpnts.hour = 0;
                    cmpnts.day += 1;
                }
            } else if (dayWidth > 40) {
                if (hd == 0) {
                    cmpnts.hour += 12;
                } else {
                    cmpnts.hour = 0;
                    cmpnts.day += 1;
                }
            } else {
                cmpnts.day += 1;
            }
            d = [calendar dateFromComponents:cmpnts];
            t = [d timeIntervalSinceReferenceDate];
        }
    }
    CGContextRestoreGState(ctx);
}

- (void)ganttView:(IQGanttView *)gantt didScaleWindow:(IQGanttViewTimeWindow)win
{
    self.height = gantt.defaultRowHeight;
    scaleWindow = win;
    
    for(int i = 0; i < rowViews.count; i++) {
        UIView<IQGanttRowDelegate>* rowView = rowViews[i];
        if([rowView respondsToSelector:@selector(ganttView:didScaleWindow:)]) {
            [(id<IQGanttHeaderDelegate>)rowView ganttView:gantt didScaleWindow:scaleWindow];
        }
    }
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        [self updateGroupView];
    }
    [self layoutOnRowsChange];
    [self setNeedsDisplay];
}

#pragma mark - TKDragViewDelegate

- (void)dragViewDidStartDragging:(TKDragView *)dragView
{
    [self.highlightedView setHidden:NO];
}

- (void)dragViewDidEndDragging:(TKDragView *)dragView
{
    [self.highlightedView setHidden:YES];
}

- (void)dragViewDidMove:(TKDragView *)dragView
{
    IQLabelView *groupView = (IQLabelView*) dragView;
    
    NSTimeInterval t0 = scaleWindow.windowStart;
    NSTimeInterval t1 = scaleWindow.windowEnd;
    CGSize sz = self.bounds.size;
    CGFloat tscl = sz.width / (t1 - t0);
    CGFloat originX = groupView.frame.origin.x;
    
    NSTimeInterval startTime = t0 + originX/tscl;
    NSTimeInterval diff = startTime - [[self.dataSource startDate] timeIntervalSinceReferenceDate];
    
    
    for (id<IQCalendarDataSource> row in self.dataSource.listOfTask) {
        [row setStartDate:[[row startDate] dateByAddingTimeInterval:diff]];
    }
    
    for(int i = 0; i < rowViews.count; i++) {
        UIView<IQGanttRowDelegate>* rowView = rowViews[i];
        id<IQCalendarDataSource> row = self.dataSource.listOfTask[i];
        if([rowView respondsToSelector:@selector(ganttView:didChangeDataSource:)]) {
            [(id<IQGanttRowDelegate>)rowView ganttView:(IQGanttView*)self.superview.superview didChangeDataSource:row];
        }
    }
    NSTimeInterval newStartTime = [[self.dataSource startDate] timeIntervalSinceReferenceDate];
    
    NSTimeInterval diffOriginX = newStartTime - startTime;
    if (diffOriginX != 0) {
        dragView.offsetStartLocation = CGPointMake(dragView.offsetStartLocation.x + diffOriginX*tscl, dragView.offsetStartLocation.y);
    }
    NSTimeInterval endTime = [[self.dataSource endDate] timeIntervalSinceReferenceDate];
    
    if(newStartTime > t1 || endTime < t0) {
        return;
    }
    CGRect frame = CGRectMake((newStartTime-t0)*tscl, 0, (endTime-newStartTime)*tscl, self.height);
    [self.groupView setFrame:frame];
    
    self.highlightedView.frame = CGRectMake((newStartTime-t0)*tscl, 0, (endTime-newStartTime)*tscl, (self.dataSource.listOfTask.count+1)*self.height);
}

#pragma mark - IQGanttGroupRowViewDelegate

- (void)ganttRowView:(IQGanttRowView*)view didChangeDataSource:(id<IQCalendarDataSource>)dataSource
{
    if(scaleWindow.windowEnd > scaleWindow.windowStart) {
        [self updateGroupView];
    }
}

@end


