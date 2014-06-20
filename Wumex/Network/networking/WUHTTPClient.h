//
//  WUHTTPClient.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/28/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//
#import <MBProgressHUD/MBProgressHUD.h>

#import "AFHTTPClient.h"
#import "WUErrorHandler.h"
#import "WUSession.h"
#import "WUJSONToObjectMapper.h"
#import "WUObjectToJSONMapper.h"

typedef void(^WUHTTPClientSuccessBlock)();
typedef void(^WUHTTPClientSuccessBlockWithReponse)(NSDictionary *response);
typedef void(^WUHTTPClientFailureBlock)(NSString *errorCode);
typedef void(^WUHTTPClientProgressBlock)(float progress);

typedef void(^WUHTTPClientLongRunningOperationStartBlock)();
typedef void(^WUHTTPClientImageDownloadSuccessBlock)(UIImage *image);

typedef void(^WUHTTPClientFullSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void(^WUHTTPClientFullFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);
typedef void(^WUHTTPClientFullProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

extern NSString * const kWUHTTPRequestParameterClientMetaData;
extern NSString * const kWUHTTPRequestParameterClientLoginToken;
extern NSString * const kWUHTTPRequestParameterClientLocaleCode;

@interface WUHTTPClient : AFHTTPClient

- (void)downloadImageWithURL:(NSURL *)imageURL success:(WUHTTPClientImageDownloadSuccessBlock)success;

- (void)downloadImageWithURL:(NSURL *)imageURL imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (NSString *)getNetworkAccessToken;

- (void)saveSession;

- (void)discardSession;

- (BOOL)hasValidSession;

- (void)setLoggedInUser:(WUUser *)user;

- (WUUser *)getLoggedInUser;

- (BOOL)isNetworkReachable;

+ (NSDictionary *)getClientMetaData;

+ (NSString *)getSystemLanguageCode;

+ (WUHTTPClient *)sharedClient;

@end
