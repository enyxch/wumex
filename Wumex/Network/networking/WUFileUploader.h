//
//  WUFileUploader.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/2/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUHTTPClient.h"

NSString * const kWUFileUploaderResponseParameterImagePath;
NSString * const kWUFileUploaderResponseParameterImagePath2;

@interface WUFileUploader : NSObject

- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
  dataParameterName:(NSString *)dataParameterName
           fileNameWithoutExt:(NSString *)fileNameWithoutExt
            success:(WUHTTPClientFullSuccessBlock)success
            failure:(WUHTTPClientFullFailureBlock)failure
           progress:(WUHTTPClientProgressBlock)progress;

+ (WUFileUploader *)sharedUploader;

@end
