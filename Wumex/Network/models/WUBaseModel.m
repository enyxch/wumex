//
//  WUBaseModel.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 8/2/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUBaseModel.h"

@implementation WUBaseModel

- (BOOL)areValuesInKeypathEqual:(NSString *)keypath otherObject:(id)otherObject
{
    id value1 = [self valueForKeyPath:keypath];
    id value2 = [otherObject valueForKeyPath:keypath];

    return [self isValue:value1 equalToValue:value2];
}

// NOTE! attributes can't be compared for equality by simply using isEqual method as nil object responds to isEqual and always returns YES which can result in false positive
// NOTE! NSNumber instances need to be compared with isEqualToNumber method - otheriwse they will return false even if actual values match
- (BOOL)isValue:(id)value1 equalToValue:(id)value2
{
    if ( value1 == value2 )
    {
        return YES;
    }

    if ( value1 == nil )
    {
        if ( value2 == nil )
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }

    if ( [value1 isEqual:[NSNull null]] )
    {
        if ( [value2 isEqual:[NSNull null]] )
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }

    if ( [value1 isEqual:value2] )
    {
        return YES;
    }

    // specific comparison for NSNumbers is a must unfortunatelly
    if ( [value1 isKindOfClass:[NSNumber class]] )
    {
        if ( [self isNumber:value1 equalToNumber:value2] )
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isNumber:(NSNumber *)number1 equalToNumber:(NSNumber *)number2
{
    long long value1 = [(NSNumber *)number1 longLongValue];
    long long value2 = [(NSNumber *)number2 longLongValue];

    if ( value1 == value2 )
    {
        return YES;
    }
    
    return NO;
}

@end
