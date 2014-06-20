//
//  WUTask.m
//  Wumex
//
//  Created by Nicolas Bonnet on 10.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUTask.h"

#import "WULabel.h"

//NSString * const kWUTaskProperty = @"";
NSString * const kWUTaskPropertyTaskId = @"taskId";
NSString * const kWUTaskPropertyTitle = @"title";
NSString * const kWUTaskPropertyDetail = @"detail";
NSString * const kWUTaskPropertyProjectId = @"projectId";
NSString * const kWUTaskPropertyStartDate = @"startDate";
NSString * const kWUTaskPropertyEndDate = @"endDate";
NSString * const kWUTaskPropertyEstimatedTime = @"estimatedTime";
NSString * const kWUTaskPropertyTimeSpent = @"timeSpent";
NSString * const kWUTaskPropertyTaskType = @"taskType";
NSString * const kWUTaskPropertyPriority = @"priority";
NSString * const kWUTaskPropertyState = @"state";
NSString * const kWUTaskPropertyDependsOnTaskId = @"dependsOnTaskId";
NSString * const kWUTaskPropertyLabelId = @"labelId";
NSString * const kWUTaskPropertyOwnerId = @"ownerId";

@implementation WUTask

- (id)init
{
    self = [super init];
    if (self) {
        _beforeTaskId = [NSMutableArray array];
        _afterTaskId  = [NSMutableArray array];
        _startDate = [NSDate date];
        _endDate = [NSDate date];
        _estimatedTime = @0;
        _timeSpent = @0;
        _taskType = @"Task";
        _priority = @"Normal";
        _state = @"New";
    }
    return self;
}

- (id)copy
{
    WUTask *task = [[WUTask alloc] init];
    task.taskId = [self.taskId copy];
    task.title = [self.title copy];
    task.detail = [self.detail copy];
    task.projectId = [self.projectId copy];
    task.labelId = [self.labelId copy];
    task.ownerId = [self.ownerId copy];
    task.startDate = [self.startDate copy];
    task.estimatedTime = [self.estimatedTime copy];
    task.endDate = [self.endDate copy];
    task.timeSpent = [self.timeSpent copy];
    task.taskType = [self.taskType copy];
    task.priority = [self.priority copy];
    task.state = [self.state copy];
    task.color = [self.color copy];
    task.dependsOnTaskId = [self.dependsOnTaskId copy];
    return task;
}

#pragma mark - Set

- (void)setStartDate:(NSDate *)startDate
{
    if ([self isUnWantedDate:startDate]) {
        _startDate = [self getWantedDayBefore:([startDate timeIntervalSinceReferenceDate] < [_startDate timeIntervalSinceReferenceDate]) date:startDate];
    } else {
        _startDate = startDate;
    }
    if (_estimatedTime) {
        _endDate = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _endDate = [_startDate dateByAddingTimeInterval:([_estimatedTime floatValue] + unwantedTime)];
    } else if (_endDate) {
        _estimatedTime = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _estimatedTime = [NSNumber numberWithFloat:([_endDate timeIntervalSinceDate:_startDate]-unwantedTime)];
    }
    if (self.parentLabel) {
        [self.parentLabel updateDate];
    }
}

- (void)setEstimatedTime:(NSNumber *)estimatedTime
{
    _estimatedTime = estimatedTime;
    if (_startDate) {
        _endDate = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _endDate = [_startDate dateByAddingTimeInterval:([_estimatedTime floatValue] + unwantedTime)];
    } else if (_endDate) {
        _startDate = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _startDate = [_endDate dateByAddingTimeInterval:-([_estimatedTime floatValue] + unwantedTime)];
    }
    if (self.parentLabel) {
        [self.parentLabel updateDate];
    }
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = endDate;
    if (_startDate) {
        _estimatedTime = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _estimatedTime = [NSNumber numberWithFloat:([_endDate timeIntervalSinceDate:_startDate]-unwantedTime)];
    } else if (_estimatedTime) {
        _startDate = nil;
        NSTimeInterval unwantedTime = [self unwantedTime];
        _startDate = [_endDate dateByAddingTimeInterval:-([_estimatedTime floatValue] + unwantedTime)];
    }
    if (self.parentLabel) {
        [self.parentLabel updateDate];
    }
}

#pragma mark - Calcul method

- (NSDate*)getWantedDayBefore:(BOOL)before date:(NSDate*)date
{
    NSTimeInterval addingTime = before ? -24*60*60 : 24*60*60;
    date = [date dateByAddingTimeInterval:addingTime];
    while ([self isUnWantedDate:date]) {
        date = [date dateByAddingTimeInterval:addingTime];
    }
    return date;
}

- (BOOL)isUnWantedDate:(NSDate*)date
{
    BOOL result = NO;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    
    if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
        result = YES;
    }
    return result;
}

- (NSTimeInterval)unwantedTime
{
    NSTimeInterval result = 0;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if (_startDate && _estimatedTime) {
        NSTimeInterval estimatedTime = [_estimatedTime floatValue];
        NSDate *startDate = _startDate;
        NSDateComponents* cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
        
        if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
            result -= [startDate timeIntervalSinceDate:[calendar dateFromComponents:cmpnts]];
        }
        
        while (estimatedTime >= 0) {
            if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
                result += 24*60*60;
                estimatedTime += 24*60*60;
            }
            cmpnts.day ++;
            startDate = [calendar dateFromComponents:cmpnts];
            cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
            estimatedTime -= 24*60*60;
        }
    }
    if (_startDate && _endDate) {
        NSDate *startDate = _startDate;
        NSDateComponents* cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
        NSDateComponents* cmpntsEnd = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:_endDate];
        
        if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
            result -= [startDate timeIntervalSinceDate:[calendar dateFromComponents:cmpnts]];
        }
        
        while (![cmpnts isEqual:cmpntsEnd]) {
            if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
                result += 24*60*60;
            }
            cmpnts.day ++;
            startDate = [calendar dateFromComponents:cmpnts];
            cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
        }
        if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
            result += [calendar components:NSHourCalendarUnit fromDate:_endDate].hour * 60 * 60;
        }
    }
    if (_endDate && _estimatedTime) {
        NSTimeInterval estimatedTime = [_estimatedTime floatValue];
        NSDate *endDate = _endDate;
        NSDateComponents* cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:_endDate];
        
        if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
            result += [_endDate timeIntervalSinceDate:[calendar dateFromComponents:cmpnts]];
        }
        
        while (estimatedTime >= 0) {
            if ( cmpnts.weekday == 1 || cmpnts.weekday == 7 ) {
                result += 24*60*60;
                estimatedTime += 24*60*60;
            }
            cmpnts.day --;
            endDate = [calendar dateFromComponents:cmpnts];
            cmpnts = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:endDate];
            estimatedTime -= 24*60*60;
        }
    }
//    NSLog(@"unwantedTime with _startDate && _endDate : %f", result/(24*60*60.f));
    
    return result;
}

#pragma mark - JSON serialization

+ (WUObjectJSONMapping *)getObjectToJSONMapping
{
    return [[WUObjectJSONMapping alloc] initWithAttributeMappings:@[
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyTaskId
                                                                                                  targetKeypath:@"id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyTitle
                                                                                                  targetKeypath:@"name"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyDetail
                                                                                                  targetKeypath:@"description"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyTaskType
                                                                                                  targetKeypath:@"task_type"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyPriority
                                                                                                  targetKeypath:@"priority"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyState
                                                                                                  targetKeypath:@"state"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyTimeSpent
                                                                                                  targetKeypath:@"time_spent"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyEstimatedTime
                                                                                                  targetKeypath:@"time_estimated"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyDependsOnTaskId
                                                                                                  targetKeypath:@"depends_on_task_id"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyLabelId
                                                                                                  targetKeypath:@"label_id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyProjectId
                                                                                                  targetKeypath:@"project_id"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyOwnerId
                                                                                                  targetKeypath:@"user_id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUTaskPropertyStartDate
                                                                                                  targetKeypath:@"start_date"
                                                                                                           type:WUAttributeTypeDate]
                                                                    ]];
}

+ (WUObjectJSONMapping *)getJSONToObjectMapping
{
    return [self getInversedMappingForMapping:[self getObjectToJSONMapping]];
}

+ (WUObjectJSONMapping *)getInversedMappingForMapping:(WUObjectJSONMapping *)sourceMapping
{
    NSMutableArray *inversedMappingsArray = [NSMutableArray array];
    
    for ( WUAttributeMapping *attributeMapping in sourceMapping.attributeMappings )
    {
        WUAttributeMapping *inversedMapping = [WUAttributeMapping createWithSourceKeypath:attributeMapping.targetKeypath
                                                                            targetKeypath:attributeMapping.sourceKeypath
                                                                                     type:attributeMapping.type
                                                                             mappingClass:attributeMapping.mappingClass];
        [inversedMappingsArray addObject:inversedMapping];
    }
    
    return [[WUObjectJSONMapping alloc] initWithAttributeMappings:inversedMappingsArray];
}

@end
