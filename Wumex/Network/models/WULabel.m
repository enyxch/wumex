//
//  WULabel.m
//  Wumex
//
//  Created by Nicolas Bonnet on 10.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WULabel.h"

//NSString * const kWULabelProperty = @"";
NSString * const kWULabelPropertyLabelId = @"labelId";
NSString * const kWULabelPropertyTitle = @"title";
NSString * const kWULabelPropertyProjectId = @"projectId";
NSString * const kWULabelPropertyPosition = @"position";

@implementation WULabel

- (id)init
{
    self = [super init];
    if (self) {
        _listOfTask = [NSMutableArray array];
        _estimatedTime = [NSNumber numberWithInteger:0];
    }
    return self;
}

- (void)addTask:(WUTask*)task
{
    task.parentLabel = self;
    for (id<IQCalendarDataSource> data in self.listOfTask) {
        if ([[data startDate] timeIntervalSinceReferenceDate] > [task.startDate timeIntervalSinceReferenceDate]) {
            [_listOfTask insertObject:task atIndex:[_listOfTask indexOfObject:data]];
            break;
        }
    }
    
    if (![_listOfTask containsObject:task]) {
        [_listOfTask addObject:task];
    }
    
    [self updateDate];
}

- (void)removeTask:(WUTask*)task
{
    task.parentLabel = nil;
    [_listOfTask removeObject:task];
}

- (void)removeAllTask
{
    [_listOfTask removeAllObjects];
}

- (void)updateDate
{
    NSDate *startDate, *endDate;
    NSInteger cumulatedTime = 0.0f;
    for (WUTask *task in self.listOfTask) {
        if (startDate == nil || [startDate timeIntervalSinceReferenceDate] > [task.startDate timeIntervalSinceReferenceDate]) {
            startDate = task.startDate;
        }
        if (endDate == nil || [endDate timeIntervalSinceReferenceDate] < [task.endDate timeIntervalSinceReferenceDate]) {
            endDate = task.endDate;
        }
        cumulatedTime += [task.estimatedTime integerValue];
    }
    self.estimatedTime = [NSNumber numberWithInteger:cumulatedTime];
    self.startDate = startDate;
    self.endDate = endDate;
}

+ (WUObjectJSONMapping *)getObjectToJSONMapping
{
    return [[WUObjectJSONMapping alloc] initWithAttributeMappings:@[
                                                                    [WUAttributeMapping createWithSourceKeypath:kWULabelPropertyLabelId
                                                                                                  targetKeypath:@"id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWULabelPropertyTitle
                                                                                                  targetKeypath:@"name"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWULabelPropertyProjectId
                                                                                                  targetKeypath:@"project_id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWULabelPropertyPosition
                                                                                                  targetKeypath:@"position"
                                                                                                           type:WUAttributeTypeInteger]
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
