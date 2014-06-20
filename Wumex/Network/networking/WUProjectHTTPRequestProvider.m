//
//  WUProjectHTTPRequestProvider.m
//  Wumex
//
//  Created by Nicolas Bonnet on 03.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUProjectHTTPRequestProvider.h"

NSString * const kWUProjectHTTPRequestPathCreate = @"projects/create";
NSString * const kWUProjectHTTPRequestPathUpdate = @"projects/update";
NSString * const kWUProjectHTTPRequestPathDelete = @"projects/delete";
NSString * const kWUProjectHTTPRequestPathGet = @"projects";

NSString * const kWUProjectHTTPRequestParameterProjectId = @"project_id";

@implementation WUProjectHTTPRequestProvider

- (void)createProject:(WUProject*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:project]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPOST
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUProjectHTTPRequestPathCreate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)updateProject:(WUProject*)project success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:project]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWUProjectHTTPRequestParameterProjectId : project.projectId,
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPUT
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUProjectHTTPRequestPathUpdate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)deleteWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    if (projectId == nil) {
        NSLog(@"projectId can't be null");
        return;
    }
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWUProjectHTTPRequestParameterProjectId : projectId,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
    
    [self performRequestWithMethod:kWUHTTPRequestMethodDELETE
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUProjectHTTPRequestPathDelete
                        parameters:parameters
                           success:success
                           failure:failure];
}

//if succeed, success == @{@"projects": NSArray<WUProject*>}
- (void)getProjectsWithSuccess:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
    
    [self performRequestWithMethod:kWUHTTPRequestMethodGET
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUProjectHTTPRequestPathGet
                        parameters:parameters
                           success:^(NSDictionary *response) {
                               if ( response != nil )
                               {
                                   NSArray *listJSONProject = (NSArray*)response;
                                   
                                   if ( listJSONProject != nil )
                                   {
                                       NSMutableArray *listProject = [NSMutableArray array];
                                       
                                       for ( NSDictionary* projectJSON in listJSONProject )
                                       {
                                           WUProject* project = [[WUJSONToObjectMapper defaultMapper] mapJSONDictionaryToObject:projectJSON objectClass:[WUProject class]];
                                           [listProject addObject:project];
                                       }
                                                                              
                                       if ( success != nil )
                                       {
                                           success(@{@"projects": listProject });
                                       }
                                   }
                                   else
                                   {
                                       LogE(@"List of project returned from server is nil");
                                       if ( failure != nil )
                                       {
                                           failure(kWUErrorCodeUnknownError);
                                       }
                                   }
                               }
                               else
                               {
                                   LogE(@"Response from server with list of project is nil");
                                   if ( failure != nil )
                                   {
                                       failure(kWUErrorCodeUnknownError);
                                   }
                               }
                           }
                           failure:failure];
}

+ (WUProjectHTTPRequestProvider *)sharedInstance
{
    static WUProjectHTTPRequestProvider *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [WUProjectHTTPRequestProvider new];
    });
    
    return sharedInstance;
}

@end
