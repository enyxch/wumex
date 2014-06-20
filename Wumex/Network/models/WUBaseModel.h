//
//  WUBaseModel.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 8/2/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUBaseModel : NSObject

- (BOOL)areValuesInKeypathEqual:(NSString *)keypath otherObject:(id)otherObject;

// NOTE! attributes can't be compared for equality by simply using isEqual method as nil object responds to isEqual and always returns YES which can result in false positive
// NOTE! NSNumber instances need to be compared with isEqualToNumber method - otheriwse they will return false even if actual values match
// TODO - try compare method - should work according to this source - http://stackoverflow.com/questions/6605262/comparing-nsnumbers-in-objective-c
- (BOOL)isValue:(id)value1 equalToValue:(id)value2;

- (BOOL)isNumber:(NSNumber *)number1 equalToNumber:(NSNumber *)number2;

@end
