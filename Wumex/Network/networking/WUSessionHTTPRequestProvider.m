//
//  WUSessionHTTPRequestProvider.m
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUSessionHTTPRequestProvider.h"

NSString * const kWUSessionHTTPRequestPathLogin = @"sessions/login";

NSString * const kWUSessionHTTPRequestParameterUser = @"user";
NSString * const kWUSessionHTTPRequestParameterToken = @"token";
NSString * const kWUSessionHTTPRequestParameterPassword = @"password";
NSString * const kWUSessionHTTPRequestParameterEmail = @"email";

@implementation WUSessionHTTPRequestProvider

- (void)loginWithEmail:(NSString*)email password:(NSString*)password success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSDictionary *parameters = @{
                                 kWUSessionHTTPRequestParameterEmail : email,
                                 kWUSessionHTTPRequestParameterPassword : password,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]
                                 };
    
    //    NSLog(@"description of parameter for registration : %@", [parameters description]);
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPOST
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUSessionHTTPRequestPathLogin
                        parameters:parameters
                           success:success
                           failure:failure];
}

+ (WUSessionHTTPRequestProvider *)sharedInstance
{
    static WUSessionHTTPRequestProvider *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [WUSessionHTTPRequestProvider new];
    });
    
    return sharedInstance;
}

@end
