//
//  WUObjectJSONMapping.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUObjectJSONMapping.h"

@implementation WUObjectJSONMapping

- (id)initWithAttributeMappings:(NSArray *)attributeMappings
{
    self = [super init];

    if (attributeMappings == nil || [attributeMappings count] == 0) {
        [NSException raise:@"Empty attribute mappings" format:@"The array of attribute mappings is either nil or empty. Did you forget to register mappings in your AppDelegate?"];
    }

    if (self != nil) {
        _attributeMappings = attributeMappings;
    }

    return self;
}

@end
