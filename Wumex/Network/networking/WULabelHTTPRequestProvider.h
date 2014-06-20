//
//  WULabelHTTPRequestProvider.h
//  Wumex
//
//  Created by Nicolas Bonnet on 12.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"

#import "WULabel.h"

@interface WULabelHTTPRequestProvider : WUBaseHTTPRequestProvider

- (void)createLabel:(WULabel*)label success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)updateLabel:(WULabel*)label success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (void)deleteWithLabelId:(NSNumber*)labelId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

/**
 if succeed, success == @{@"labels": NSArray<WULabel*>}
 */
- (void)getLabelsWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

+ (WULabelHTTPRequestProvider *)sharedInstance;

@end
