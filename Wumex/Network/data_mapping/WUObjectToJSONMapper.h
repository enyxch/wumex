//
//  WUObjectToJSONMapper.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WUObjectJSONMapping.h"

/**
 This class is responsible for mapping NSObject instances to JSON using KVC.
 
 In order to use this class to map an object do the following:
 
 - configure the class by setting the stringEncoding, dateFormatter, mapNilsToNulls or leave the default values
 
 - register WUObjectJSONMapping with the registerMapping:forClass:
 
 - use the mapObjectToJSON: to map an object to JSON string
 */
@interface WUObjectToJSONMapper : NSObject

/** @name Properties */

/**
 String encoding to be used when creating JSON object.
 
 @note The default is NSUTF8StringEncoding.
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
 This flag is responsible for determining whether `nil` values in tha mapped object should be ommited or represented as `null` in the resulting JSON.
 
 @note The default value is `NO`.
 
 @warning When this flag is set to `NO`, keys and values for properties with value of `nil` are not included in the resulting JSON!
 */
@property (nonatomic, assign) BOOL mapNilsToNulls;

/**
 Maps given object to JSON proxy NSDictionary instance following NSJSONSerialization rules.

 @param object The object that will be mapped to JSON.

 @return NSDictionary representation of object using registered mapping. The dictionary is created according to the following rules:
 
 - all objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull

 - all dictionary keys are instances of NSString

 - numbers are not `NaN` or `infinity`

 @exception NSInvalidArgumentException Object can't be nil.
 @exception WUInvalidConfigurationException Missing mapping for object's class.
 */

/** @name Instance methods */

- (NSDictionary *)mapObjectToJSONProxyDictionary:(id)object;

- (NSString *)mapDictionaryToJSON:(NSDictionary *)dictionary error:(NSError **)error;

/**
 Maps given object to JSON based on the registered encoding for the class of the object
 
 @param object The object that will be mapped to JSON.
 @param error The error object describing any recoverable issue that arose during mapping object to JSON.
 
 @return JSON string representation of the object or `nil` if there was an error.

 @exception NSInvalidArgumentException Object can't be nil.
 @exception WUInvalidConfigurationException Missing mapping for object's class.
 */
- (NSString *)mapObjectToJSON:(id)object error:(NSError **)error;

/** @name Class methods */

/**
 The default, shared instance of WUObjectToJSONMapper.

 @return The default, shared instance of WUObjectToJSONMapper.
 */
+ (WUObjectToJSONMapper *)defaultMapper;

/**
 Places the given WUObjectJSONMapping instance in the mappings register. Object to JSON mapper uses those mappings to map object of given class when it encounters it.
 
 @param mapping The WUObjectJSONMapping instance that will be registered.
 @param mappedClass The class for which the mapping will be registered.
 */
+ (void)registerMapping:(WUObjectJSONMapping *)mapping forClass:(Class)mappedClass;

/**
 Removes WUObjectJSONMapping instance for given class from the registry.
 
 @param mappedClass The class for which the mapping will unregistered.
 */
+ (void)unregisterMappingForClass:(Class)mappedClass;

@end
