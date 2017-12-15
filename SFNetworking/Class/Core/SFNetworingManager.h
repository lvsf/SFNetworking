//
//  SFNetworingManager.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"
#import "SFURLRequest.h"
#import "SFURLResponse.h"
#import "SFHTTPTask.h"
#import "SFUploadTask.h"
#import "SFDownloadTask.h"
#import "SFURLTaskGroup.h"
#import "SFURLTaskConfiguration.h"

@interface SFNetworingManager : NSObject
+ (instancetype)manager;
- (void)sendTask:(SFURLTask *)task;
- (void)sendTask:(SFURLTask *)task configuration:(SFURLTaskConfiguration *)configuration;
@end

@interface SFNetworingManager(SFAddTaskGroup)
- (void)sendTaskGroup:(SFURLTaskGroup *)taskGroup;
@end
