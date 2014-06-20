//
//  WUUsersHTTPRequestProvider.h
//  Global_Jury
//
//  Created by Nicolas Bonnet on 13.11.13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"

@interface WUUsersHTTPRequestProvider : WUBaseHTTPRequestProvider

- (void)registerUser:(WUUser *)user success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

+ (WUUsersHTTPRequestProvider *)sharedInstance;

@end
