//
//  WUErrorHandler.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/8/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUErrorHandler.h"
#import "WUJSONToObjectMapper.h"
#import "AFURLConnectionOperation.h"

NSString * const kWUErrorCodeUnknownError = @"6000";
NSString * const kWUErrorCodeNoConnection = @"6001";
NSString * const kWUErrorCodeCachedResponseNotFound = @"6002";
NSString * const kWUErrorCodeInternalServerError = @"6003";
NSString * const kWUErrorCodeMaintenance = @"6004";

@implementation WUErrorHandler

- (NSString *)extractCustomErrorCodeFromError:(NSError *)error
{
    
    NSLog(@"extractCustomErrorCodeFromError : %@", error);
    
    NSInteger httpErrorCode = [[error userInfo][AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    NSInteger afnetworkingInternalErrorCode = error.code;

    NSString *customErrorCode;
    
    NSString *additionalInfoErr;
    NSString *additionalInfoErr2;

    // checking for internal error code representing "no connection" error
    if ( afnetworkingInternalErrorCode == -1009 )
    {
        customErrorCode = kWUErrorCodeNoConnection;
    }
    // HTTP error = 5xx - internal server error
    else if ( httpErrorCode >= 500 && httpErrorCode < 600 )
    {
        customErrorCode = kWUErrorCodeInternalServerError;
    }
    // HTTP error = 4xx - issue with request - improper authentication/authorization/request
    else if ( httpErrorCode >= 400 && httpErrorCode < 500 )
    {
        NSError *deserializationError;
        // read JSON containing error code from NSError instance
        NSString *errorDetails = [error userInfo][@"NSLocalizedRecoverySuggestion"];
        if ( errorDetails != nil )
        {
            customErrorCode = [[WUJSONToObjectMapper defaultMapper] jsonToDictionary:errorDetails error:&deserializationError][@"error_code"];
            additionalInfoErr = [[WUJSONToObjectMapper defaultMapper] jsonToDictionary:errorDetails error:&deserializationError][@"error_message"];
//            additionalInfoErr2 = [[[WUJSONToObjectMapper defaultMapper] jsonToDictionary:errorDetails error:&deserializationError] objectForKey:@"error_code"];
        }
        
        if (deserializationError != nil || customErrorCode == nil || [customErrorCode isEqual:[NSNull null]] || [customErrorCode isEqualToString:@""])
        {
            customErrorCode = kWUErrorCodeUnknownError;
        }
    }
    // some other error that we probably can't handle
    else
    {
        customErrorCode = kWUErrorCodeUnknownError;
    }

    LogE(@"Networking error. HTTP status code: %d, AFNetworking internal error code: %d, custom error code: %@, additional info on the error: %@ - %@", httpErrorCode, afnetworkingInternalErrorCode, customErrorCode, additionalInfoErr, additionalInfoErr2);
    
    return customErrorCode;
}

- (void)displayAlertForErrorCode:(NSString *)errorCode
{
    NSString *title = [self getLocalizedTitleForErrorCode:errorCode];
    NSString *message = [self getLocalizedMessageForErrorCode:errorCode];

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:NSLocalizedString(@"Ok", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:nil];
    [alertView show];
}

- (NSString *)getLocalizedTitleForErrorCode:(NSString *)errorCode
{
    NSString *title = [WUErrorHandler getErrorTitles][errorCode];

    if (title == nil)
    {
        LogE(@"There's no title for errorCode: %@", errorCode);
        return [WUErrorHandler getErrorTitles][kWUErrorCodeUnknownError];
    }

    return title;
}

- (NSString *)getLocalizedMessageForErrorCode:(NSString *)errorCode
{
    NSString *message = [WUErrorHandler getErrorMessages][errorCode];

    if (message == nil)
    {
        LogE(@"There's no title for errorCode: %@", errorCode);
        return [WUErrorHandler getErrorMessages][kWUErrorCodeUnknownError];
    }

    return message;
}

+ (WUErrorHandler *)defaultHandler
{
    static WUErrorHandler *defaultHandler;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultHandler = [WUErrorHandler new];
    });

    return defaultHandler;
}

+ (NSDictionary *)getErrorTitles
{
    static NSDictionary *errorTitles;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        errorTitles = @{
                            /* Errors in range 6xxx */
                            kWUErrorCodeUnknownError: NSLocalizedString(@"Error", nil),
                            kWUErrorCodeCachedResponseNotFound: NSLocalizedString(@"No local data", ),
                            kWUErrorCodeNoConnection: NSLocalizedString(@"No connection", nil),
                            kWUErrorCodeInternalServerError: NSLocalizedString(@"Internal server error", nil),
                            kWUErrorCodeMaintenance: NSLocalizedString(@"Maintenance", nil)
                          };
    });
    
    return errorTitles;
}

+ (NSDictionary *)getErrorMessages
{
    static NSDictionary *errorMessages;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        errorMessages = @{
                            /* Errors in range 6xxx */
                            kWUErrorCodeUnknownError: NSLocalizedString(@"An error has occured.\nPlease try again later.", nil),
                            kWUErrorCodeCachedResponseNotFound: NSLocalizedString(@"No cached data has been found.", ),
                            kWUErrorCodeNoConnection: NSLocalizedString(@"No internet connection available.", nil),
                          kWUErrorCodeInternalServerError: NSLocalizedString(@"An error has occured on the server. Please try again later.", nil),
                          kWUErrorCodeMaintenance: NSLocalizedString(@"The server is in maintenance. Please try again later.", nil)
                          };
    });

    return errorMessages;
}

@end
