//
//  WUFileUploader.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/2/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUFileUploader.h"
#import "WUHTTPClient.h"
#import "AFJSONRequestOperation.h"

NSString * const kWUFileUploaderResponseParameterImagePath = @"image_remote_url";
NSString * const kWUFileUploaderResponseParameterImagePath2 = @"image_remote_path";

@interface WUFileUploader ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation WUFileUploader

- (id)init
{
    self = [super init];

    if (self != nil) {
        self.queue = [NSOperationQueue new];
        [self.queue setMaxConcurrentOperationCount:3];
    }

    return self;
}

- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
  dataParameterName:(NSString *)dataParameterName
           fileNameWithoutExt:(NSString *)fileNameWithoutExt
            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
           progress:(WUHTTPClientProgressBlock)progress
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", fileNameWithoutExt, @"jpg"];
    NSString *mime = @"image/jpeg";
    
    path = [NSString stringWithFormat:@"%@/%@", path, [[WUHTTPClient sharedClient] getNetworkAccessToken]];
    
    NSURLRequest *request = [[WUHTTPClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:dataParameterName fileName:fileName mimeType:mime];
    }];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success != nil) {
            success(request, response, JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure != nil) {
            failure(request, response, error, JSON);
        }
    }];

    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float progressValue = (float)((double)totalBytesWritten/(double)totalBytesExpectedToWrite);
        if ( progress != nil )
        {
            progress(progressValue);
        }
    }];

    [self.queue addOperation:operation];
}

+ (WUFileUploader *)sharedUploader
{
    static WUFileUploader *sharedUploader;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedUploader = [WUFileUploader new];
    });

    return sharedUploader;
}

@end
