//
//  WUSessionHTTPRequestProvider.h
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"

@interface WUSessionHTTPRequestProvider : WUBaseHTTPRequestProvider

- (void)loginWithEmail:(NSString*)email password:(NSString*)password success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

+ (WUSessionHTTPRequestProvider *)sharedInstance;

@end
