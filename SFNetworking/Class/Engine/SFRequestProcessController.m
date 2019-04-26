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

- (SFRequestError *)shouldSendRequestTask:(SFRequestTask *)requestTask withRequest:(nonnull SFRequest *)request {
    // 检测网络环境
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return [SFRequestError requestErrorWithCustomCode:SFURLErrorCustomCodeNetworkNotReachable
                                           message:@"SFURLErrorCustomCodeNetworkNotReachable"];
    }
    return nil;
}

- (BOOL)shouldCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    return YES;
}

- (BOOL)shouldCallbackCompleteForRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    return YES;
}

@end
