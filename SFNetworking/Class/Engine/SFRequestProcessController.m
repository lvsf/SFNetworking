//
//  SFRequestProcessController.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestProcessController.h"
#import "SFRequestSesssion.h"
#import "SFNetworkingEngine.h"
#import <AFNetworkReachabilityManager.h>

@implementation SFRequestProcessController

- (instancetype)init {
    if (self = [super init]) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (SFRequestError *)shouldSendRequestTask:(SFRequestTask *)requestTask withRequest:(SFRequest *)request withConfiguration:(SFRequestTaskConfiguration *)configuration {
    if (!request.baseURL && !request.taskURL && !configuration.baseURL) {
        return [SFRequestError errorWithCustomCode:SFURLErrorCustomCodeInvaildRequest
                                            message:@"无效的请求"];
    }
    SFRequestTask *containTask = [[SFNetworkingEngine defaultEngine] containTask:requestTask];
    if (containTask && [containTask.session isEqual:requestTask.session]) {
        return [SFRequestError errorWithCustomCode:SFURLErrorCustomCodeFrequently
                                           message:@"请求太频繁"];
    }
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return [SFRequestError errorWithCustomCode:SFURLErrorCustomCodeNetworkNotReachable
                                           message:@"网络未连接"];
    }
    return nil;
}

- (BOOL)shouldCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    return YES;
}

@end
