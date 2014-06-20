//
//  WUTaskHTTPRequestProvider.h
//  Wumex
//
//  Created by Nicolas Bonnet on 12.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"

#import "WUTask.h"

@interface WUTaskHTTPRequestProvider : WUBaseHTTPRequestProvider

- (void)createTask:(WUTask*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)updateTask:(WUTask*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)deleteWithTaskId:(NSNumber*)taskId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

/**
 if succeed, success == @{@"tasks": NSArray<WUTask*>}
 */
- (void)getTasksWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

+ (WUTaskHTTPRequestProvider *)sharedInstance;

@end
