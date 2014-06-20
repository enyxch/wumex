//
//  WUProject.m
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUProject.h"

//NSString * const kWUProjectProperty = @"";
NSString * const kWUProjectPropertyProjectId = @"projectId";
NSString * const kWUProjectPropertyTitle = @"title";
NSString * const kWUProjectPropertyDetails = @"details";
NSString * const kWUProjectPropertyDeadline = @"deadline";
NSString * const kWUProjectPropertyPercentDone = @"percentDone";
NSString * const kWUProjectPropertyCreationDate = @"creationDate";
NSString * const kWUProjectPropertyUpdatedDate = @"updatedDate";

@implementation WUProject

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        NSLog(@"init WUProject : %@", [self description]);
//    }
//    return self;
//}

- (NSString*)description
{
    return [NSString stringWithFormat:@"project ( %@ )", self.title];
}

+ (WUObjectJSONMapping *)getObjectToJSONMapping
{
    return [[WUObjectJSONMapping alloc] initWithAttributeMappings:@[
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyProjectId
                                                                                                  targetKeypath:@"id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyTitle
                                                                                                  targetKeypath:@"title"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyDetails
                                                                                                  targetKeypath:@"description"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyDeadline
                                                                                                  targetKeypath:@"deadline"
                                                                                                           type:WUAttributeTypeDate],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyPercentDone
                                                                                                  targetKeypath:@"percent_done"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyCreationDate
                                                                                                  targetKeypath:@"created_at"
                                                                                                           type:WUAttributeTypeDate],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUProjectPropertyUpdatedDate
                                                                                                  targetKeypath:@"updated_at"
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
