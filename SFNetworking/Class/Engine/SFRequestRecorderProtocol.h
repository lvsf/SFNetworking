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
- (void)recordForRequestTaskSendComplete:(SFRequestTask *)requestTask withResponse:(SFResponse *)response;
@end

NS_ASSUME_NONNULL_END
