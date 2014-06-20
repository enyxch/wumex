#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WUAttributeType) {
    WUAttributeTypeString,
    WUAttributeTypeBool,
    WUAttributeTypeDate,
    WUAttributeTypeInteger,
    WUAttributeTypeFloat,
    WUAttributeTypeDouble,
    WUAttributeTypeDictionaryPrimitive, /* contains only basic objects: NSNumber, NSString, NSNull */
    WUAttributeTypeDictionaryMappable, /* represents a complete mappable object like for example user (it might contain nested mappable objects) */
    WUAttributeTypeArrayPrimitive, /* contains only basic objects: NSNumber, NSString, NSNull */
    WUAttributeTypeArrayMappable /* contains mappable objects (with mappings registered in objects mapper */
};

/* NOTE! only here for reference how to define enums and bit options the "Apple way" */
//typedef WU_OPTIONS(NSUInteger, WUAttributeType) {
//    NSJSONReadingMutableContainers = (1UL << 0),
//    NSJSONReadingMutableLeaves = (1UL << 1),
//    NSJSONReadingAllowFragments = (1UL << 2)
//};
