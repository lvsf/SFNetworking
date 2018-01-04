//
//  SFHTTPTask+ZSLYAdd.m
//  SFNetworking
//
//  Created by YunSL on 2018/1/2.
//  Copyright © 2018年 YunSL. All rights reserved.
//

#import "SFHTTPTask+ZSLYAdd.h"
#import "SFURLTaskPage.h"
#import "ZSHTTPTaskConfiguration.h"

@implementation SFHTTPTask (ZSLYAdd)

+ (instancetype)zsly_task {
    SFHTTPTask *task = [self new];
    ZSHTTPTaskConfiguration *configuration = [ZSHTTPTaskConfiguration new];
    task.requestSerializerType = SFURLSerializerTypeJSON;
    task.responseSerializerType = SFURLSerializerTypeJSON;
    task.method = SFHTTPMethodPOST;
    task.baseURL = @"http://www.baidu.com/";
    task.page = [SFURLTaskPage new];
    task.interaction = configuration;
    task.filter = configuration;
    task.requestSerializer = configuration;
    task.responseSerializer = configuration;
    task.debugDelegate = configuration;
    return task;
}

@end
