//
//  WUObjectJSONMapping.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUAttributeMapping.h"

/**
 This class represents a mapping from object to JSON or from JSON to object. It is defined by mapping for each attribute in source or target object descibed by WUAttributeMapping class.
 */
@interface WUObjectJSONMapping : NSObject

/** An array of attribute mappings. */
@property (nonatomic, strong, readonly) NSArray *attributeMappings;

/**
 Init method taking an array of attribute mappings.
 
 @param attributeMappings An array of WUAttributeMapping instances.
 
 @exception NSException The array of attribute mappings is either nil or empty.>
 */
- (id)initWithAttributeMappings:(NSArray *)attributeMappings;

@end
