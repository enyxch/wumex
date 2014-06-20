//
//  WULabelHTTPRequestProvider.m
//  Wumex
//
//  Created by Nicolas Bonnet on 12.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WULabelHTTPRequestProvider.h"

NSString * const kWULabelHTTPRequestPathCreate = @"labels/create";
NSString * const kWULabelHTTPRequestPathUpdate = @"labels/update";
NSString * const kWULabelHTTPRequestPathDelete = @"labels/delete";
NSString * const kWULabelHTTPRequestPathGet = @"labels";

NSString * const kWULabelHTTPRequestParameterProjectId = @"project_id";
NSString * const kWULabelHTTPRequestParameterLabelId = @"label_id";


@implementation WULabelHTTPRequestProvider


- (void)createLabel:(WULabel*)label success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:label]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPOST
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWULabelHTTPRequestPathCreate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)updateLabel:(WULabel*)label success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:label]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWULabelHTTPRequestParameterLabelId : label.labelId,
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPUT
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWULabelHTTPRequestPathUpdate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)deleteWithLabelId:(NSNumber*)labelId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    if (labelId == nil) {
        NSLog(@"labelId can't be null");
        return;
    }
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWULabelHTTPRequestParameterLabelId : labelId,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
    
    [self performRequestWithMethod:kWUHTTPRequestMethodDELETE
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWULabelHTTPRequestPathDelete
                        parameters:parameters
                           success:success
                           failure:failure];
}

//if succeed, success == @{@"labels": NSArray<WULabel*>}
- (void)getLabelsWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    if (projectId == nil) {
        NSLog(@"projectId can't be null");
        return;
    }
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWULabelHTTPRequestParameterProjectId : projectId,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
        
    [self performRequestWithMethod:kWUHTTPRequestMethodGET
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWULabelHTTPRequestPathGet
                        parameters:parameters
                           success:^(NSDictionary *response) {
                               if ( response != nil )
                               {
                                   NSArray *listJSONLabel = (NSArray*)response;
                                   
                                   if ( listJSONLabel != nil )
                                   {
                                       
                                       NSMutableArray *listLabel = [NSMutableArray array];
                                       
                                       for ( NSDictionary* labelJSON in listJSONLabel )
                                       {
                                           WULabel* label = [[WUJSONToObjectMapper defaultMapper] mapJSONDictionaryToObject:labelJSON objectClass:[WULabel class]];
                                           [listLabel addObject:label];
                                       }
                                       
                                       if ( success != nil )
                                       {
                                           success(@{@"labels": listLabel });
                                       }
                                   }
                                   else
                                   {
                                       LogE(@"List of label returned from server is nil");
                                       if ( failure != nil )
                                       {
                                           failure(kWUErrorCodeUnknownError);
                                       }
                                   }
                               }
                               else
                               {
                                   LogE(@"Response from server with list of label is nil");
                                   if ( failure != nil )
                                   {
                                       failure(kWUErrorCodeUnknownError);
                                   }
                               }
                           }
                           failure:failure];
}

+ (WULabelHTTPRequestProvider *)sharedInstance
{
    static WULabelHTTPRequestProvider *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [WULabelHTTPRequestProvider new];
    });
    
    return sharedInstance;
}

@end
