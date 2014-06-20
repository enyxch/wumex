//
//  WUAttributeMapping.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUAttributeType.h"

/**
 This class is a container for information regarding specific attribute mapping in object to JSON and JSON to object mappings.
 */
@interface WUAttributeMapping : NSObject

/** The keypath to the attribute in the source object (either JSON string or NSObject instance) */
@property (nonatomic, strong, readonly) NSString *sourceKeypath;

/** The keypath to the attribute in the target object (either JSON string or NSObject instance) */
@property (nonatomic, strong, readonly) NSString *targetKeypath;

/** The type of the attribute - determines how the value will be serialized/deserialized */
@property (nonatomic, assign, readonly) WUAttributeType type;

/** Only for attirbute of type mappable (array or single attribute) */
@property (nonatomic, strong, readonly) Class mappingClass;

/**
 Init method with keypaths and type parameters.

 @param sourceKeypath The keypath to the attribute in the source object (either JSON string or NSObject instance).
 @param targetKeypath The keypath to the attribute in the target object (either JSON string or NSObject instance).
 @param type The type of the attribute - determines how the value will be serialized/deserialized.
 
 @return WUAttributeMapping instance.
 */
- (id)initWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type mappingClass:(Class)mappingClass;

/** 
 Factory method for creating WUAttributeMapping instances.
 
 @param sourceKeypath The keypath to the attribute in the source object (either JSON string or NSObject instance).
 @param targetKeypath The keypath to the attribute in the target object (either JSON string or NSObject instance).
 @param type The type of the attribute - determines how the value will be serialized/deserialized.
 
 @return Attribute mapping given constructed with given parameters.
 */
+ (WUAttributeMapping *)createWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type;

+ (WUAttributeMapping *)createWithSourceKeypath:(NSString *)sourceKeypath targetKeypath:(NSString *)targetKeypath type:(WUAttributeType)type mappingClass:(Class)mappingClass;

@end
