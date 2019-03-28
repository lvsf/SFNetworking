//
//  SFRequestProcessContollerProtocol.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/24.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestError.h"
#import "SFRequestTask.h"
#import "SFResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestProcessContollerProtocol <NSObject>

- (SFRequestError *)shouldSendRequestTask:(SFRequestTask *)requestTask withRequest:(SFRequest *)request withConfiguration:(SFRequestTaskConfiguration *)configuration;

/**
 是否结束请求任务/用于重发任务等

 @param requestTask 请求任务
 @param response    请求响应
 @return 返回NO时,不会结束界面交互也不会回调请求结果
 */
- (BOOL)shouldCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response;
@end

NS_ASSUME_NONNULL_END
