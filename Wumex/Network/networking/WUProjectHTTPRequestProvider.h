//
//  WUProjectHTTPRequestProvider.h
//  Wumex
//
//  Created by Nicolas Bonnet on 03.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"

#import "WUProject.h"

@interface WUProjectHTTPRequestProvider : WUBaseHTTPRequestProvider

- (void)createProject:(WUProject*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)updateProject:(WUProject*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)deleteWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

/**
 if succeed, success == @{@"projects": NSArray<WUProject*>}
 */
- (void)getProjectsWithSuccess:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

+ (WUProjectHTTPRequestProvider *)sharedInstance;

@end
