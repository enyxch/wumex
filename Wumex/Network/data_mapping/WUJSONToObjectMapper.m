//
//  WUJSONToObjectMapper.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/26/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUJSONToObjectMapper.h"
#import "ISO8601DateFormatter.h"
#import "WUExceptions.h"

@interface WUJSONToObjectMapper ()

@property (nonatomic, strong) ISO8601DateFormatter *dateFormatter;

@end

@implementation WUJSONToObjectMapper

- (id)init
{
    self = [super init];

    if (self != nil)
    {
        self.stringEncoding = NSUTF8StringEncoding;

        self.dateFormatter = [[ISO8601DateFormatter alloc] init];
        self.dateFormatter.format = ISO8601DateFormatCalendar;
        self.dateFormatter.includeTime = NO;
        self.dateFormatter.timeSeparator = ISO8601DefaultTimeSeparatorCharacter;
    }

    return self;
}

- (id)mapJSON:(NSString *)json toObjectOfClass:(Class)className error:(NSError **)error
{
    if (json == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"JSON can't be nil"];
    }

    NSError *deserializationError;
    NSDictionary *jsonDictionary = [self jsonToDictionary:json error:&deserializationError];
    if (deserializationError != nil)
    {
        *error = deserializationError;
        return nil;
    }

    return [self mapJSONDictionaryToObject:jsonDictionary objectClass:className];
}

// TODO - create a common method for JSON to object and object to JSON mapper - sourceObject and targetObject - or maybe there actually is a need for a method specifically returning Dictionary and Object?
- (id)mapJSONDictionaryToObject:(NSDictionary *)jsonDictionary objectClass:(Class)className
{
    id mappedObject = [[className alloc] init];

    WUObjectJSONMapping *mapping = [WUJSONToObjectMapper getRegisteredMappingForClass:className];
    if (mapping == nil)
    {
        [NSException raise:WUInvalidConfigurationException format:@"There is no object-JSON mapping registered for class %@", className];
    }
    
    for (WUAttributeMapping *attributeMapping in mapping.attributeMappings)
    {
        
        id rawValue = [jsonDictionary valueForKeyPath:attributeMapping.sourceKeypath];
        id objectValue = [self transformAttributeToJSONValue:rawValue attributeMapping:attributeMapping];
        // don't put nil values into JSON
        if (objectValue != nil)
        {
            [mappedObject setValue:objectValue forKeyPath:attributeMapping.targetKeypath];
        }
    }

    return mappedObject;
}

- (id)transformAttributeToJSONValue:(id)value attributeMapping:(WUAttributeMapping *)attributeMapping
{
    id result = nil;
    WUAttributeType type = attributeMapping.type;
    
    // if value is NSNull instance map it to nil
    if ( value == [NSNull null] )
    {
        result = nil;
    }
    else if (value != nil)
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
                result = [self.dateFormatter dateFromString:value];
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
                        // can't check it that way - actual reqturned value is NSCFDictionary which is not a subclass of NSDictionary and is not even a proper Objective-C class
                        if ( [value isKindOfClass:[NSDictionary class]] )
                        {
                            result = [self mapJSONDictionaryToObject:value objectClass:attributeMapping.mappingClass];  
                        }
                        else
                        {
                            LogE(@"WARNING! Mapping attribute of type WUAttributeTypeDictionaryMappable but ");
                        }
                    }
                }
                else
                {
                    LogE(@"WARNING! Mapping attribute of type WUAttributeTypeDictionaryMappable without specified class. Did you forget to create attribute mapping using factory method taking class parameter?");
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
                            for (NSDictionary *jsonDictionary in valuesArray)
                            {
                                id mappedObject = [self mapJSONDictionaryToObject:jsonDictionary objectClass:attributeMapping.mappingClass];
                                if ( mappedObject != nil )
                                {
                                    [resultArray addObject:mappedObject];
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

    return result;
}

- (NSDictionary *)jsonToDictionary:(NSString *)json error:(NSError **)error
{
    NSData *jsonData = [json dataUsingEncoding:self.stringEncoding];
    NSError *newError;
    NSDictionary *dictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&newError];
    *error = newError;

    return dictionary;
}

+ (void)registerMapping:(WUObjectJSONMapping *)mapping forClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);
    [WUJSONToObjectMapper sharedJSONToObjectMappingsRegister][className] = mapping;
}

+ (void)unregisterMappingForClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);
    [[WUJSONToObjectMapper sharedJSONToObjectMappingsRegister] removeObjectForKey:className];
}

+ (WUObjectJSONMapping *)getRegisteredMappingForClass:(Class)mappedClass
{
    NSString *className = NSStringFromClass(mappedClass);

    return (WUObjectJSONMapping *)[self sharedJSONToObjectMappingsRegister][className];
}

+ (WUJSONToObjectMapper *)defaultMapper
{
    static WUJSONToObjectMapper *defaultMapper;
    static dispatch_once_t predicate = 0;

    dispatch_once(&predicate, ^{
        defaultMapper = [WUJSONToObjectMapper new];
    });

    return defaultMapper;
}

+ (NSMutableDictionary *)sharedJSONToObjectMappingsRegister
{
    static NSMutableDictionary *sharedMappingsRegister;
    static dispatch_once_t predicate = 0;

    dispatch_once(&predicate, ^{
        sharedMappingsRegister = [NSMutableDictionary dictionary];
    });

    return sharedMappingsRegister;
}

@end
