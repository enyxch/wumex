//
//  WUTask.h
//  Wumex
//
//  Created by Nicolas Bonnet on 10.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseModel.h"
#import "WUObjectJSONMapping.h"

#import "IQCalendarDataSource.h"

//extern NSString * const kWUTaskProperty;
extern NSString * const kWUTaskPropertyTaskId;
extern NSString * const kWUTaskPropertyTitle;
extern NSString * const kWUTaskPropertyDetail;
extern NSString * const kWUTaskPropertyProjectId;
extern NSString * const kWUTaskPropertyStartDate;
extern NSString * const kWUTaskPropertyEndDate;
extern NSString * const kWUTaskPropertyEstimatedTime;
extern NSString * const kWUTaskPropertyTimeSpent;
extern NSString * const kWUTaskPropertyTaskType;
extern NSString * const kWUTaskPropertyPriority;
extern NSString * const kWUTaskPropertyState;
extern NSString * const kWUTaskPropertyDependsOnTaskId;
extern NSString * const kWUTaskPropertyLabelId;
extern NSString * const kWUTaskPropertyOwnerId;

@class WULabel;

@interface WUTask : WUBaseModel <IQCalendarDataSource>

@property (nonatomic, strong) NSNumber      *taskId;
@property (nonatomic, strong) NSString      *title;
@property (nonatomic, strong) NSString      *detail;
@property (nonatomic, strong) NSNumber      *projectId;
@property (nonatomic, strong) NSNumber      *labelId;
@property (nonatomic, strong) NSNumber      *ownerId;

@property (nonatomic, strong) NSDate        *startDate;
@property (nonatomic, strong) NSDate        *endDate;
@property (nonatomic, strong) NSNumber      *estimatedTime;
@property (nonatomic, strong) NSNumber      *timeSpent;
@property (nonatomic, strong) NSNumber      *percentDone;

@property (nonatomic, strong) NSString      *taskType;
@property (nonatomic, strong) NSString      *priority;
@property (nonatomic, strong) NSString      *state;

//Apparence
@property (nonatomic, strong) UIColor       *color;

//Dependencies
@property (nonatomic, strong) NSString              *dependsOnTaskId;
@property (nonatomic, strong) NSMutableArray        *beforeTaskId;
@property (nonatomic, strong) NSMutableArray        *afterTaskId;

@property (nonatomic, weak) WULabel* parentLabel;

/**
 @return The user to JSON mapping that can be used with WUObjectToJSONMapper.
 */
+ (WUObjectJSONMapping *)getObjectToJSONMapping;

/**
 @return The JSON to user object mapping that can be used with WUJSONToObjectMapper.
 */
+ (WUObjectJSONMapping *)getJSONToObjectMapping;

@end
