//
//  SFRequestRefreshTokenProcessController.m
//  Pocket
//
//  Created by YunSL on 2019/4/22.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestRefreshTokenProcessController.h"
#import "SFRequestSesssion.h"
#import "SFNetworkingEngine.h"

@implementation SFRequestRefreshTokenProcessController

- (SFRequestError *)shouldSendRequestTask:(SFRequestTask *)requestTask withRequest:(SFRequest *)request {
    SFRequestError *error = [super shouldSendRequestTask:requestTask withRequest:request];
    return error;
}

- (BOOL)shouldCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    BOOL should = [super shouldCompleteRequestTask:requestTask withResponse:response];
    if (should) {
        if ([requestTask.request.taskURL isEqualToString:@"https://www.baidu.com"] && requestTask.requestStatus == SFRequestTaskStatusCancel) {
            [self _refreshTokenForRequestTask:requestTask];
            should = NO;
        }
    }
    return should;
}

- (BOOL)shouldCallbackCompleteForRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    BOOL should = [super shouldCallbackCompleteForRequestTask:requestTask withResponse:response];
    if (should) {
    }
    return should;
}

- (BOOL)shouldRefreshTokenForRequestTask:(SFRequestTask *)reqeustTask withResponse:(SFResponse *)response {
    return NO;
}

- (void)_refreshTokenForRequestTask:(SFRequestTask *)requestTask {
    SFRequest *refreshRequest = [SFRequest new];
    refreshRequest.taskURL = @"https://www.tianqiapi.com/api";
    refreshRequest.parameters = @{@"version":@"v1",
                                  @"city":@"厦门"
                                  };
    refreshRequest.method = SFRequestMethodPOST;
    refreshRequest.acceptableContentTypes = @[@"application/javascript"];
    SFRequestTask *refreshRequestTask = [SFRequestTask new];
    refreshRequestTask.record = NO;
    refreshRequestTask.request = refreshRequest;
    refreshRequestTask.responseSerializer.successReformer = ^BOOL(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:@"cityEn"] isEqualToString:@"xiamen"]) {
            return YES;
        }
        return NO;
    };
    refreshRequestTask.complete = ^(SFRequestTask * _Nonnull requestTask1, SFResponse * _Nonnull response) {
        if (response.success) {
            
            SFRequestTask *resendRequestTask = [SFRequestTask new];
            resendRequestTask.request = requestTask.request;
            resendRequestTask.requestSerializer = requestTask.requestSerializer;
            resendRequestTask.responseSerializer = requestTask.responseSerializer;
            resendRequestTask.responseSerializer.messageReformer = ^NSString * _Nullable(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
                return @"刷新token并重发请求成功";
            };
            resendRequestTask.complete = ^(SFRequestTask * _Nonnull requestTask2, SFResponse * _Nonnull response) {
                [requestTask completeWithResponse:response];
            };
            [requestTask.session sendTask:resendRequestTask];
        }
    };
    [requestTask.session sendTask:refreshRequestTask];
}

@end
