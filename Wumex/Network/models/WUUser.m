//
//  WUUser.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/24/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#import "WUUser.h"

#import "WUObjectToJSONMapper.h"
#import "WUObjectJSONMapping.h"


NSString * const kWUUserPropertyUserId = @"userId";
NSString * const kWUUserPropertyEmail = @"email";
NSString * const kWUUserPropertyPassword = @"password";
NSString * const kWUUserPropertyToken = @"token";
NSString * const kWUUserPropertyUserName = @"userName";
NSString * const kWUUserPropertyFirstName = @"firstName";
NSString * const kWUUserPropertyLastName = @"lastName";

@interface WUUser ()

@end

@implementation WUUser

+ (WUObjectJSONMapping *)getObjectToJSONMapping
{
    return [[WUObjectJSONMapping alloc] initWithAttributeMappings:@[
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyUserId
                                                                                                  targetKeypath:@"id"
                                                                                                           type:WUAttributeTypeInteger],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyEmail
                                                                                                  targetKeypath:@"email"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyPassword
                                                                                                  targetKeypath:@"password"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyToken
                                                                                                  targetKeypath:@"token"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyUserName
                                                                                                  targetKeypath:@"userName"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyFirstName
                                                                                                  targetKeypath:@"firstName"
                                                                                                           type:WUAttributeTypeString],
                                                                    
                                                                    [WUAttributeMapping createWithSourceKeypath:kWUUserPropertyLastName
                                                                                                  targetKeypath:@"lastName"
                                                                                                           type:WUAttributeTypeString]
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
