//
//  WUJSONRequestOperation.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/16/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUJSONRequestOperation.h"

@implementation WUJSONRequestOperation

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *result = [super connection:connection willCacheResponse:cachedResponse];

    LogD(@"Caching response for connection with URL %@", connection.originalRequest.URL);

    return result;
}

@end
