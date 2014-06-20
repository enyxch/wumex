//
//  WUUsersHTTPRequestProvider.m
//  Global_Jury
//
//  Created by Nicolas Bonnet on 13.11.13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUUsersHTTPRequestProvider.h"

#import "WUFileUploader.h"

NSString * const kWUUsersHTTPRequestPathRegister = @"users/register";

NSString * const kWUUsersHTTPRequestParameterUser = @"user";
NSString * const kWUUsersHTTPRequestParameterToken = @"token";

@implementation WUUsersHTTPRequestProvider

- (void)registerUser:(WUUser *)user success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:user]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
//    NSLog(@"description of parameter for registration : %@", [parameters description]);
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPOST
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUUsersHTTPRequestPathRegister
                        parameters:parameters
                           success:success
                           failure:failure];
}

+ (WUUsersHTTPRequestProvider *)sharedInstance
{
    static WUUsersHTTPRequestProvider *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [WUUsersHTTPRequestProvider new];
    });
    
    return sharedInstance;
}

@end
