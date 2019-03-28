//
//  SFRequestRecorderProtocol.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/24.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestTask.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestRecorderProtocol <NSObject>
@optional
- (void)recordForRequestTaskBeginHandle:(SFRequestTask *)requestTask;
- (void)recordForRequestTaskSend:(SFRequestTask *)requestTask;
- (void)recordForRequestTaskCompleteSend:(SFRequestTask *)requestTask;
- (void)recordForRequestTaskEndHandle:(SFRequestTask *)requestTask;
@end

NS_ASSUME_NONNULL_END
