//
//  WUProject.h
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseModel.h"
#import "WUObjectJSONMapping.h"

//extern NSString * const kWUProjectProperty;
extern NSString * const kWUProjectPropertyProjectId;
extern NSString * const kWUProjectPropertyTitle;
extern NSString * const kWUProjectPropertyDescription;
extern NSString * const kWUProjectPropertyDeadline;
extern NSString * const kWUProjectPropertyPercentDone;
extern NSString * const kWUProjectPropertyCreationDate;
extern NSString * const kWUProjectPropertyUpdatedDate;

@interface WUProject : WUBaseModel

@property (nonatomic, strong) NSNumber      *projectId;

@property (nonatomic, strong) NSString      *title;
@property (nonatomic, strong) NSString      *details;
@property (nonatomic, strong) NSDate        *deadline;
@property (nonatomic, strong) NSNumber      *percentDone;
@property (nonatomic, strong) NSDate        *creationDate;
@property (nonatomic, strong) NSDate        *updatedDate;

//- (instancetype)init;

- (NSString*)description;

/**
 @return The user to JSON mapping that can be used with WUObjectToJSONMapper.
 */
+ (WUObjectJSONMapping *)getObjectToJSONMapping;

/**
 @return The JSON to user object mapping that can be used with WUJSONToObjectMapper.
 */
+ (WUObjectJSONMapping *)getJSONToObjectMapping;

@end
