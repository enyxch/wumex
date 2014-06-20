//
//  WUBaseHTTPRequestProvider.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/22/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WUHTTPClient.h"

typedef void (^WUSuccessBlockWithRequestAndResponse)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^WUFailuerBlockWithRequestAndResponse)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);

extern NSString * const kWUHTTPRequestMethodPOST;
extern NSString * const kWUHTTPRequestMethodPUT;
extern NSString * const kWUHTTPRequestMethodGET;
extern NSString * const kWUHTTPRequestMethodDELETE;

@interface WUBaseHTTPRequestProvider : NSObject

- (void)performRequestWithMethod:(NSString *)method withCachePolicy:(NSURLRequestCachePolicy)policy path:(NSString *)path parameters:(NSDictionary *)parameters success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure;

- (NSDictionary *)extractResponseDictionaryFromCachedResponse:(NSCachedURLResponse *)cachedResponse error:(NSError **)error;

@end
