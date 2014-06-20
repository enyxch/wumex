//
//  WUBaseHTTPRequestProvider.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/22/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUBaseHTTPRequestProvider.h"
#import "WUJSONRequestOperation.h"

NSString * const kWUHTTPRequestMethodPOST = @"POST";
NSString * const kWUHTTPRequestMethodPUT = @"PUT";
NSString * const kWUHTTPRequestMethodGET = @"GET";
NSString * const kWUHTTPRequestMethodDELETE = @"DELETE";

@implementation WUBaseHTTPRequestProvider

// TODO - ALLOW SETTING THE POLICY FOR LOGIN AND THE LIKE!
/* private - extracted common logic from requests */
- (void)performRequestWithMethod:(NSString *)method withCachePolicy:(NSURLRequestCachePolicy)policy path:(NSString *)path parameters:(NSDictionary *)parameters success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableURLRequest *request = [[WUHTTPClient sharedClient] requestWithMethod:method path:path parameters:parameters];
    request.cachePolicy = policy;

    WUSuccessBlockWithRequestAndResponse onSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success != nil)
        {
            success((NSDictionary *)JSON);
        }
    };

    WUFailuerBlockWithRequestAndResponse onFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSString *customErrorCode = [[WUErrorHandler defaultHandler] extractCustomErrorCodeFromError:error];

//        LogD(@"Response code: %d", response.statusCode);

        if (failure != nil)
        {
            failure(customErrorCode);
        }
    };

    AFJSONRequestOperation *operation = [WUJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];

    // in case the network is not reachable try to read cached response
    if ( ![[WUHTTPClient sharedClient] isNetworkReachable] && policy != NSURLRequestReloadIgnoringLocalCacheData)
    {
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        if ( cachedResponse != nil )
        {
            // TODO - handle error
            NSError *error;
            NSDictionary *jsonDictionary = [self extractResponseDictionaryFromCachedResponse:cachedResponse error:&error];
            if ( jsonDictionary != nil )
            {
                if ( onSuccess != nil )
                {
                    onSuccess(request, (NSHTTPURLResponse *)cachedResponse.response, jsonDictionary);
                }

                return;
            }
        }
    }

    // perform request on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [operation start];
    });
}

- (NSDictionary *)extractResponseDictionaryFromCachedResponse:(NSCachedURLResponse *)cachedResponse error:(NSError **)error
{
    NSDictionary *result = nil;

    if (cachedResponse != nil && cachedResponse.data != nil && [cachedResponse.data length] > 0)
    {
        NSError *deserializationError;
        NSString *jsonString = [[NSString alloc] initWithData:cachedResponse.data encoding:[WUJSONToObjectMapper defaultMapper].stringEncoding];
        result = [[WUJSONToObjectMapper defaultMapper] jsonToDictionary:jsonString error:&deserializationError];
        if (deserializationError != nil)
        {
            *error = deserializationError;
            return nil;
        }
    }
    
    return result;
}

// NOTE: no longer used because automatic caching is triggered if Cache-Control is properly set in server response
//- (void)manuallyCacheResponse
//{
//    AFJSONRequestOperation *operation = [WUJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//    NSData *responseData = [NSKeyedArchiver archivedDataWithRootObject:JSON];
//    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:responseData];
//    [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
//}

@end
