//
//  WULabel.h
//  Wumex
//
//  Created by Nicolas Bonnet on 10.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseModel.h"
#import "WUObjectJSONMapping.h"

#import "IQCalendarDataSource.h"
#import "WUTask.h"

//extern NSString * const kWULabelProperty;
extern NSString * const kWULabelPropertyLabelId;
extern NSString * const kWULabelPropertyTitle;
extern NSString * const kWULabelPropertyProjectId;
extern NSString * const kWULabelPropertyPosition;

@interface WULabel : WUBaseModel <IQCalendarDataSource>

@property (nonatomic, strong) NSNumber          *labelId;
@property (nonatomic, strong) NSString          *title;
@property (nonatomic, strong) NSNumber          *projectId;
@property (nonatomic, strong) NSNumber          *position;
@property (nonatomic, strong, readonly) NSMutableArray    *listOfTask;
@property (nonatomic, strong) NSDate            *startDate;
@property (nonatomic, strong) NSDate            *endDate;
@property (nonatomic, strong) NSNumber          *estimatedTime;

- (void)addTask:(WUTask*)task;
- (void)removeTask:(WUTask*)task;
- (void)removeAllTask;

- (void)updateDate;

/**
 @return The user to JSON mapping that can be used with WUObjectToJSONMapper.
 */
+ (WUObjectJSONMapping *)getObjectToJSONMapping;

/**
 @return The JSON to user object mapping that can be used with WUJSONToObjectMapper.
 */
+ (WUObjectJSONMapping *)getJSONToObjectMapping;

@end
