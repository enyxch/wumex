//
//  WUJSONToObjectMapper.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/26/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WUObjectJSONMapping.h"

@interface WUJSONToObjectMapper : NSObject

/** @name Properties */

/**
 String encoding to be used when creating JSON object.

 @note The default is NSUTF8StringEncoding.
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

- (id)mapJSON:(NSString *)json toObjectOfClass:(Class)className error:(NSError **)error;

- (id)mapJSONDictionaryToObject:(NSDictionary *)jsonDictionary objectClass:(Class)className;

- (NSDictionary *)jsonToDictionary:(NSString *)json error:(NSError **)error;

- (id)transformAttributeToJSONValue:(id)value attributeMapping:(WUAttributeMapping *)attributeMapping;

+ (WUJSONToObjectMapper *)defaultMapper;

+ (void)registerMapping:(WUObjectJSONMapping *)mapping forClass:(Class)mappedClass;

+ (void)unregisterMappingForClass:(Class)mappedClass;

@end
