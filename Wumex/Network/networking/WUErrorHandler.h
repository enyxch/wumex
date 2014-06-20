//
//  WUErrorHandler.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/8/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Error codes constants */

extern NSString * const kWUErrorCodeUnknownError;
extern NSString * const kWUErrorCodeNoConnection;
extern NSString * const kWUErrorCodeCachedResponseNotFound;
extern NSString * const kWUErrorCodeInternalServerError;
extern NSString * const kWUErrorCodeMaintenance;

@interface WUErrorHandler : NSObject

- (NSString *)extractCustomErrorCodeFromError:(NSError *)error;

- (void)displayAlertForErrorCode:(NSString *)errorCode;

+ (WUErrorHandler *)defaultHandler;

@end

