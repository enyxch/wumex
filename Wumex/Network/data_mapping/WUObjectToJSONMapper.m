//
//  WUObjectToJSONMapper.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/25/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUObjectToJSONMapper.h"
#import "ISO8601DateFormatter.h"
#import "WUExceptions.h"

@interface WUObjectToJSONMapper()

@property (nonatomic, strong) ISO8601DateFormatter *dateFormatter;

/**
 Transforms attribute to a JSON friendly value based on the provided type.

 @param attribute The attribute which value is to be transformed.

 @return The value resulting from the tranformation (for example NSString instance for NSDate instance, NSNumber instance for NSInteger etc.)
 */
- (id)transformAttributeToJSONValue:(id)value attributeMapping:(WUAttributeMapping *)attributeMapping;

/**
 @return The dictionary containing the mapping objects.
 */
+ (NSMutableDictionary *)sharedObjectToJSONMappingsRegister;

/**
 Return the mapping registered for the given class.

 @param mappedClass The class for which the mapping will be returned.

 @return The mapping registered for the given class or `nil` if no mapping is found in the register for this class.
 */
+ (WUObjectJSONMapping *)getRegisteredMappingForClass:(Class)mappedClass;

@end

@implementation WUObjectToJSONMapper

- (id)init
{
    self = [super init];

    if (self != nil) {
        self.mapNilsToNulls = NO;
        self.stringEncoding = NSUTF8StringEncoding;

        self.dateFormatter = [[ISO8601DateFormatter alloc] init];
        self.dateFormatter.format = ISO8601DateFormatCalendar;
        self.dateFormatter.includeTime = NO;
        self.dateFormatter.timeSeparator = ISO8601DefaultTimeSeparatorCharacter;
    }

    return self;
}

- (NSString *)mapObjectToJSON:(id)object error:(NSError **)error
{
    // create a dictionary to be transformed into JSON string
    NSDictionary *jsonProxyDictionary = [self mapObjectToJSONProxyDictionary:object];
    
    // create JSON from the prepared dictionary
    NSError *serializationError;
    NSString *resultingJSON = [self mapDictionaryToJSON:jsonProxyDictionary error:&serializationError];
    if (serializationError != nil) {
        *error = serializationError;
        return nil;
    }

    return resultingJSON;
}

- (NSDictionary *)mapObjectToJSONProxyDictionary:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"The object that is supposed to be mapped to JSON can't be nil"];
    }

    WUObjectJSONMapping *mapping = [WUObjectToJSONMapper getRegisteredMappingForClass:[object class]];
    if (mapping == nil)
    {
        NSString *className = NSStringFromClass([object class]);
        [NSException raise:WUInvalidConfigurationException format:@"There is no object-JSON mapping registered for class %@", className];
    }

    NSMutableDictionary *jsonProxyDictionary = [NSMutableDictionary dictionary];
    for (WUAttributeMapping *attributeMapping in mapping.attributeMappings)
    {
        id rawValue = [object valueForKeyPath:attributeMapping.sourceKeypath];
        id jsonValue = [self transformAttributeToJSONValue:rawValue attributeMapping:attributeMapping];

        // don't put nil values into JSON
        if (jsonValue != nil)
        {
            jsonProxyDictionary[attributeMapping.targetKeypath] = jsonValue;
        }
    }

    return jsonProxyDictionary;
}

- (NSString *)mapDictionaryToJSON:(NSDictionary *)dictionary error:(NSError **)error
{
    NSError *serializationError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&serializationError];
    if (serializationError != nil) {
        *error = serializationError;
        return nil;
    }

    return [[NSString alloc] initWithData:jsonData encoding:self.stringEncoding];
}

- (id)transformAttributeToJSONValue:(id)value attributeMapping:(WUAttributeMapping *)attributeMapping
{
    id result = nil;
    WUAttributeType type = attributeMapping.type;

    if (value != nil)
    {
        switch (type)
        {
            case WUAttributeTypeString:
            {
                result = value;
                break;
            }
            case WUAttributeTypeDate:
            {
                result = [self.dateFormatter stringFromDate:value];
                break;
            }
            case WUAttributeTypeBool:
            {
                result = value;
                break;
            }
            case WUAttributeTypeDouble:
            {
                result = value;
                break;
            }
            case WUAttributeTypeFloat:
            {
                result = value;
                break;
            }
            case WUAttributeTypeInteger:
            {
                result = value;
                break;
            }
            case WUAttributeTypeDictionaryPrimitive:
            {
                result = value;
                break;
            }
            case WUAttributeTypeDictionaryMappable:
            {
                if ( attributeMapping.mappingClass != nil )
                {
                    if ( value != nil )
                    {
                        if ( [value isKindOfClass:attributeMapping.mappingClass] )
                        {
                            result = [self mapObjectToJSONProxyDictionary:value];
                        }
                        else
                        {
                            LogE(@"WARNING! Mapping property failed.\n\nSource keypath: %@\nTarget keypath: %@\n\n You specified property class as %@ and and the actual class is %@", attributeMapping.sourceKeypath, attributeMapping.targetKeypath, attributeMapping.mappingClass, [value class]);
                        }
                    }
                }
                else
                {
                    LogE(@"WARNING! Mapping attribute of type WUAttributeTypeDictionaryMappable without specified class.\n\nDid you forget to create attribute mapping using factory method taking class parameter?");
                }
                break;
            }
            case WUAttributeTypeArrayPrimitive:
            {
                result = value;
                break;
            }
            case WUAttributeTypeArrayMappable:
            {
                if ( attributeMapping.mappingClass != nil )
                {
                    if ( value != nil )
                    {
                        if ( [value isKindOfClass:[NSArray class]] )
                        {
                            NSMutableArray *resultArray = [NSMutableArray array];

                            NSArray *valuesArray = (NSArray *)value;
                            for ( id object in valuesArray )
                            {
                                NSDictionary *objectDictionary = [self mapObjectToJSONProxyDictionary:object];
                                if ( objectDictionary != nil )
                                {
                                    [resultArray addObject:objectDictionary];
                                }

                                result = resultArray;
                            }
                        }
                        else
                        {
                            LogE(@"WARNING! Mapping property failed.\n\nSource keypath: %@\nTarget keypath: %@\n\n You specified WUAttributeTypeArrayMappable as attribute type for this property but actual property class is %@ and not NSArray", attributeMapping.sourceKeypath, attributeMapping.targetKeypath, [value class]);
                        }
                    }
                }
                else
                {
                    LogE(@"WARNING! Mapping attribute of type WUAttributeTypeArrayMappable without specified class.\n\nDid you forget to create attribute mapping using factory method taking class parameter?");
                }
                break;
            }
            default:
            {
                break;
            }
        }
    }
    // if value is nil
    else if (self.mapNilsToNulls) {
        result = [NSNull null];
    }

    return result;
}

+ (void)registerMapping:(WUObjectJSONMapping *)mapping forClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);
    [WUObjectToJSONMapper sharedObjectToJSONMappingsRegister][className] = mapping;
}

+ (void)unregisterMappingForClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);
    [[WUObjectToJSONMapper sharedObjectToJSONMappingsRegister] removeObjectForKey:className];
}

+ (WUObjectJSONMapping *)getRegisteredMappingForClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);

    return (WUObjectJSONMapping *)[WUObjectToJSONMapper sharedObjectToJSONMappingsRegister][className];
}

+ (WUObjectToJSONMapper *)defaultMapper
{
    static WUObjectToJSONMapper *defaultMapper;
    static dispatch_once_t predicate = 0;

    dispatch_once(&predicate, ^{
        defaultMapper = [WUObjectToJSONMapper new];
    });

    return defaultMapper;
}

+ (NSMutableDictionary *)sharedObjectToJSONMappingsRegister
{
    static NSMutableDictionary *sharedMappingsRegister;
    static dispatch_once_t predicate = 0;

    dispatch_once(&predicate, ^{
        sharedMappingsRegister = [NSMutableDictionary dictionary];
    });

    return sharedMappingsRegister;
}

@end