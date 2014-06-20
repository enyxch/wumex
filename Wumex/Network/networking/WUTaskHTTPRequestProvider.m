//
//  WUTaskHTTPRequestProvider.m
//  Wumex
//
//  Created by Nicolas Bonnet on 12.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUTaskHTTPRequestProvider.h"

NSString * const kWUTaskHTTPRequestPathCreate = @"tasks/create";
NSString * const kWUTaskHTTPRequestPathUpdate = @"tasks/update";
NSString * const kWUTaskHTTPRequestPathDelete = @"tasks/delete";
NSString * const kWUTaskHTTPRequestPathGet = @"tasks";

NSString * const kWUTaskHTTPRequestParameterProjectId = @"project_id";
NSString * const kWUTaskHTTPRequestParameterTaskId = @"task_id";

@implementation WUTaskHTTPRequestProvider


- (void)createTask:(WUTask*)task success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:task]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPOST
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUTaskHTTPRequestPathCreate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)updateTask:(WUTask*)task success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[[WUObjectToJSONMapper defaultMapper] mapObjectToJSONProxyDictionary:task]];
    [parameters addEntriesFromDictionary:@{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                           kWUTaskHTTPRequestParameterTaskId : task.taskId,
                                           kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]}];
    
    [self performRequestWithMethod:kWUHTTPRequestMethodPUT
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUTaskHTTPRequestPathUpdate
                        parameters:parameters
                           success:success
                           failure:failure];
}

- (void)deleteWithTaskId:(NSNumber*)taskId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    if (taskId == nil) {
        NSLog(@"projectId can't be null");
        return;
    }
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWUTaskHTTPRequestParameterTaskId : taskId,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
    
    [self performRequestWithMethod:kWUHTTPRequestMethodDELETE
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUTaskHTTPRequestPathDelete
                        parameters:parameters
                           success:success
                           failure:failure];
}

//if succeed, success == @{@"tasks": NSArray<WUTask*>}
- (void)getTasksWithProjectId:(NSNumber*)projectId success:(WUHTTPClientSuccessBlockWithReponse)success failure:(WUHTTPClientFailureBlock)failure
{
    if (projectId == nil) {
        NSLog(@"projectId can't be null");
        return;
    }
    NSDictionary *parameters = @{kWUHTTPRequestParameterClientLoginToken : [[WUHTTPClient sharedClient] getNetworkAccessToken],
                                 kWUTaskHTTPRequestParameterProjectId : projectId,
                                 kWUHTTPRequestParameterClientMetaData : [WUHTTPClient getClientMetaData]};
    
    [self performRequestWithMethod:kWUHTTPRequestMethodGET
                   withCachePolicy:NSURLRequestUseProtocolCachePolicy
                              path:kWUTaskHTTPRequestPathGet
                        parameters:parameters
                           success:^(NSDictionary *response) {
                               if ( response != nil )
                               {
                                   NSArray *listJSONTask = (NSArray*)response;
                                   
                                   if ( listJSONTask != nil )
                                   {
                                       NSMutableArray *listTask = [NSMutableArray array];
                                       
                                       for ( NSDictionary* taskJSON in listJSONTask )
                                       {
                                           WUTask* task = [[WUJSONToObjectMapper defaultMapper] mapJSONDictionaryToObject:taskJSON objectClass:[WUTask class]];
                                           [listTask addObject:task];
                                       }
                                       
                                       if ( success != nil )
                                       {
                                           success(@{@"tasks": listTask });
                                       }
                                   }
                                   else
                                   {
                                       LogE(@"List of task returned from server is nil");
                                       if ( failure != nil )
                                       {
                                           failure(kWUErrorCodeUnknownError);
                                       }
                                   }
                               }
                               else
                               {
                                   LogE(@"Response from server with list of task is nil");
                                   if ( failure != nil )
                                   {
                                       failure(kWUErrorCodeUnknownError);
                                   }
                               }
                           }
                           failure:failure];
}

+ (WUTaskHTTPRequestProvider *)sharedInstance
{
    static WUTaskHTTPRequestProvider *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [WUTaskHTTPRequestProvider new];
    });
    
    return sharedInstance;
}

@end
