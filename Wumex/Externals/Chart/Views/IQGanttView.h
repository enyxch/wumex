//
//  IQGanttView.h
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

#import <UIKit/UIKit.h>
#import "IQScrollView.h"

#import "WUTask.h"
#import "WULabel.h"
#import "IQScheduleView.h"

@protocol IQGanttHeaderDelegate;
@protocol IQGanttRowDelegate;
@protocol IQCalendarDataSource;
@protocol IQGanttGroupRowViewDelegate;

@class IQGanttView;

typedef UIView* (^IQGanttBlockViewCreationCallback)(IQGanttView* gantt, UIView* rowView, id item, CGRect frame);
typedef NSInteger (^IQGanttRowHeightCallback)(IQGanttView* gantt, UIView* rowView, id<IQCalendarDataSource> rowData);

typedef struct _IQGanttViewTimeWindow {
    NSTimeInterval windowStart, windowEnd;
    NSTimeInterval viewStart, viewSize;
} IQGanttViewTimeWindow;

@interface IQGanttView : IQScrollView {
@private
    NSInteger defaultRowHeight;
    NSMutableArray* rows;
    NSMutableArray* rowViews;
    IQGanttViewTimeWindow scaleWindow;
    NSCalendarUnit displayCalendarUnits;
    IQGanttRowHeightCallback rowHeight;
    NSCalendar* calendar;
    IQGanttViewTimeWindow scaleWindowBeforePinch;
    CGPoint lastPinchCenter;
    BOOL isPinching;
}

@property (nonatomic) IQGanttViewTimeWindow scaleWindow;
@property (nonatomic) NSCalendarUnit displayCalendarUnits;
@property (nonatomic) NSInteger defaultRowHeight;
@property (nonatomic, retain) NSCalendar* calendar;

- (void)removeAllRows;
- (void)addRow:(id<IQCalendarDataSource>)row;

// Overridable methods. Subclass IQGanttView and override the below methods
// to achieve further customization of the user interface.
- (UIView*) cornerViewWithFrame:(CGRect)frame; // default implementation returns nil
- (UIView<IQGanttHeaderDelegate>*) timeHeaderViewWithFrame:(CGRect)frame; // default implementation returns a IQGanttHeaderView
- (UIView*) rowHeaderViewWithFrame:(CGRect)frame; // default implementation returns nil

- (UIView<IQGanttRowDelegate>*) viewForRow:(id<IQCalendarDataSource>)row withFrame:(CGRect)frame; // default implementation returns a IQGanttRowView

//update Display
- (void) layoutOnPropertyChange:(BOOL)didChangeZoom;

@end

@protocol IQGanttHeaderDelegate
@optional
- (void)ganttView:(IQGanttView*)view didScaleWindow:(IQGanttViewTimeWindow)win;
- (void)ganttView:(IQGanttView*)view didMoveWindow:(IQGanttViewTimeWindow)win;
- (void)ganttView:(IQGanttView*)view shouldDisplayCalendarUnits:(NSCalendarUnit) displayCalendarUnits;
- (void)ganttView:(IQGanttView*)view didChangeCalendar:(NSCalendar*)calendar;
@end

@protocol IQGanttRowDelegate
@optional
- (void)ganttView:(IQGanttView*)view didChangeDataSource:(id<IQCalendarDataSource>)dataSource;
- (void)ganttView:(IQGanttView*)view didChangeCalendar:(NSCalendar*)calendar;
- (void)ganttView:(IQGanttView*)gantt didScaleWindow:(IQGanttViewTimeWindow)win;
- (void)ganttView:(IQGanttView*)view didMoveWindow:(IQGanttViewTimeWindow)win;
- (CGFloat)ganttViewRowHeight;
@end

@interface IQGanttHeaderView : UIView <IQGanttHeaderDelegate> {
@private
    IQGanttViewTimeWindow scaleWindow;
    CGFloat offset;
    UIColor* tintColor;
    UIColor* textColor;
    UIColor* firstDayColor;
    UIColor* textTitleColor;
    CGGradientRef grad;
    CGColorRef border;
    NSCalendarUnit displayCalendarUnits;
    NSMutableArray* floatingLabels;
    NSArray *weekdaysLetters;
    NSArray *weekdaysShort;
    NSArray *weekdaysLong;
    NSCalendar* cal;
    NSDateFormatter* monthNameFormatter;
}

@property (nonatomic, retain) UIColor* tintColor;
@property (nonatomic, readonly) NSDateFormatter* monthNameFormatter;
@end

typedef struct _IQGridDash {
    CGFloat a,b;
} IQGridDash;

static IQGridDash IQMakeGridDash(CGFloat a, CGFloat b) {
    IQGridDash ret;
    ret.a = a;
    ret.b = b;
    return ret;
}

@interface IQGanttRowView : UIView <IQGanttRowDelegate, TKDragViewDelegate> {
@private
    NSCalendar* cal;
    IQGanttViewTimeWindow scaleWindow;
    NSCalendarUnit primaryLineUnits;
    NSCalendarUnit secondaryLineUnits;
    NSCalendarUnit tertaryLineUnits;
}

@property (nonatomic, retain) id<IQCalendarDataSource> dataSource;
@property (nonatomic, retain) UIColor* primaryGridColor;
@property (nonatomic, retain) UIColor* secondaryGridColor;
@property (nonatomic, retain) UIColor* tertaryGridColor;
@property (nonatomic) IQGridDash primaryGridDash;
@property (nonatomic) IQGridDash secondaryGridDash;
@property (nonatomic) IQGridDash tertaryGridDash;
@property (nonatomic, weak) NSObject<IQGanttGroupRowViewDelegate>* delegate;

// Overridable. Called to create and manage the subviews.
- (void) layoutItems:(IQGanttView*)gantt;
@end

@protocol IQGanttGroupRowViewDelegate
@optional
- (void)ganttRowView:(IQGanttRowView*)view didChangeDataSource:(id<IQCalendarDataSource>)dataSource;
@end

@interface IQGanttGroupRowView : UIView <IQGanttRowDelegate, TKDragViewDelegate, IQGanttGroupRowViewDelegate> {
@private
    NSCalendar* cal;
    IQGanttViewTimeWindow scaleWindow;
    NSCalendarUnit primaryLineUnits;
    NSCalendarUnit secondaryLineUnits;
    NSCalendarUnit tertaryLineUnits;
    NSMutableArray* rowViews;
}

@property (nonatomic, strong) UIView* highlightedView;
@property (nonatomic, strong) IQLabelView* groupView;
@property (nonatomic, retain) WULabel* dataSource;
@property (nonatomic, retain) UIColor* primaryGridColor;
@property (nonatomic, retain) UIColor* secondaryGridColor;
@property (nonatomic, retain) UIColor* tertaryGridColor;
@property (nonatomic) IQGridDash primaryGridDash;
@property (nonatomic) IQGridDash secondaryGridDash;
@property (nonatomic) IQGridDash tertaryGridDash;
@property (nonatomic) CGFloat height;

// Overridable. Called to create and manage the subviews.
- (void) layoutItems:(IQGanttView*)gantt;
@end
