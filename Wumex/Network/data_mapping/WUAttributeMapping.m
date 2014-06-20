//
//  WUAttributeMapping.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUAttributeMapping.h"

@implementation WUAttributeMapping

- (id)initWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type mappingClass:(Class)mappingClass
{
    self = [super init];

    if (self != nil) {
        _sourceKeypath = sourceKeypath;
        _targetKeypath = targetKeypath;
        _type = type;
        _mappingClass = mappingClass;
    }

    return self;
}

+ (WUAttributeMapping *)createWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type
{
    return [[WUAttributeMapping alloc] initWithSourceKeypath:sourceKeypath
                                                targetKeypath:targetKeypath
                                                         type:type
                                                 mappingClass:nil];
}

+ (WUAttributeMapping *)createWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type mappingClass:(Class)mappingClass
{
    return [[WUAttributeMapping alloc] initWithSourceKeypath:sourceKeypath
                                                targetKeypath:targetKeypath
                                                         type:type
                                                 mappingClass:mappingClass];
}

@end
