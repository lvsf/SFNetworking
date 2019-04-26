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

- (SFRequestError *)shouldSendRequestTask:(SFRequestTask *)requestTask withRequest:(SFRequest *)request;

- (BOOL)shouldCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response;

- (BOOL)shouldCallbackCompleteForRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response;

@end

NS_ASSUME_NONNULL_END
