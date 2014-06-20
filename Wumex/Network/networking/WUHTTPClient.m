//
//  WUHTTPClient.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/28/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"

NSString * const kWUAPIBaseURLString = @"http://wumex-api.herokuapp.com:80/api/v1";

NSString * const kWUHTTPRequestParameterClientMetaData = @"client_meta_data";
NSString * const kWUHTTPRequestParameterClientLoginToken = @"token";
NSString * const kWUHTTPRequestParameterClientLocaleCode = @"locale";

@interface WUHTTPClient()

@property (nonatomic, strong) WUSession *session;
@property (nonatomic, strong) NSOperationQueue *requestQueue;

@end

@implementation WUHTTPClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self != nil)
    {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];

        // in order to have custom logic executed when reachability *changes* uncomment this and place the logic in the new block
        //[self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //}];

        self.session = [WUSession new];

        self.requestQueue = [NSOperationQueue new];
        self.requestQueue.maxConcurrentOperationCount = 6;
    }

    return self;
}

/* 
 Downloads the image with given URL
 
 @imageURL The URL for the image that will be downloaded.
 
 @note If URL is nil or otherwise invalid, the operation will fail silently but the success block will not be called. Use only for mass image download when failure doesn't have to be handled. Use version with failure block if you need to handle or exit paths.
 */
- (void)downloadImageWithURL:(NSURL *)imageURL success:(WUHTTPClientImageDownloadSuccessBlock)success
{
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:success];

    [self.operationQueue addOperation:operation];
}

- (void)downloadImageWithURL:(NSURL *)imageURL imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];

    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:imageProcessingBlock success:success failure:failure];

    [self.operationQueue addOperation:operation];
}

- (NSString *)getNetworkAccessToken
{
    if (![self hasValidSession])
    {
        LogE(@"Can't load error access token because session is invalid");
        return @"";
    }

    return [self getLoggedInUser].token;
}

- (void)saveSession
{
    [self.session saveSession];
}

- (void)discardSession
{
    [self.session discardSession];
}

- (BOOL)hasValidSession
{
    return [self.session isValid];
}

- (void)setLoggedInUser:(WUUser *)user
{
    self.session.user = user;
}

- (WUUser *)getLoggedInUser
{
    return self.session.user;
}

- (BOOL)isNetworkReachable
{
    return self.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable && self.networkReachabilityStatus != AFNetworkReachabilityStatusUnknown;
}

+ (NSDictionary *)getClientMetaData
{
    static NSDictionary *result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *applicationVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        NSString *buildVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        NSString *platform = @"iOS";

        result = @{
                    @"app_version" : applicationVersion,
                    @"build_version" : buildVersion,
                    @"platform" : platform
                  };
    });

    return result;
}

+ (NSString *)getSystemLanguageCode
{
    static NSString *result = @"en";
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if ( [NSLocale preferredLanguages] != nil && [NSLocale preferredLanguages].count > 0 )
        {
            result = [NSLocale preferredLanguages][0];
        }
    });

    return result;
}

+ (WUHTTPClient *)sharedClient
{
    static WUHTTPClient *sharedClient;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClient = [[WUHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kWUAPIBaseURLString]];
    });

    return sharedClient;
}

@end
