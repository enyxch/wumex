//
//  WUUser.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/24/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUBaseModel.h"
#import "WUObjectJSONMapping.h"

extern NSString * const kWUUserPropertyUserId;
extern NSString * const kWUUserPropertyEmail;
extern NSString * const kWUUserPropertyPassword;
extern NSString * const kWUUserPropertyToken;
extern NSString * const kWUUserPropertyUserName;
extern NSString * const kWUUserPropertyFirstName;
extern NSString * const kWUUserPropertyLastName;

/**
 This class represents a user. User object plays central role in the entire app as it constitues large portion of session data.
 */
@interface WUUser : WUBaseModel

@property (nonatomic, strong) NSNumber      *userId;
@property (nonatomic, strong) NSString      *token;

@property (nonatomic, strong) NSString      *email;
@property (nonatomic, strong) NSString      *password;
@property (nonatomic, strong) NSString      *userName;
@property (nonatomic, strong) NSString      *firstName;
@property (nonatomic, strong) NSString      *lastName;

/**
 @return The user to JSON mapping that can be used with WUObjectToJSONMapper.
 */
+ (WUObjectJSONMapping *)getObjectToJSONMapping;

/**
 @return The JSON to user object mapping that can be used with WUJSONToObjectMapper.
 */
+ (WUObjectJSONMapping *)getJSONToObjectMapping;

@end
