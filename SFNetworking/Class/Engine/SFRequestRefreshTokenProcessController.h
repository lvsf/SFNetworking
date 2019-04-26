//
//  SFRequestRefreshTokenProcessController.h
//  Pocket
//
//  Created by YunSL on 2019/4/22.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestProcessController.h"

@protocol SFRequestRefreshTokenProcessControllerProtocol <NSObject>
@required
- (BOOL)shouldRefreshTokenForRequestTask:(SFRequestTask *)reqeustTask withResponse:(SFResponse *)response;
@end

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestRefreshTokenProcessController : SFRequestProcessController<SFRequestRefreshTokenProcessControllerProtocol>
@end

NS_ASSUME_NONNULL_END
