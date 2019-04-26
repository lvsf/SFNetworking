//
//  SFRequestCacheProtocol.h
//  Pocket
//
//  Created by YunSL on 2019/4/24.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestTask.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestCacheProtocol <NSObject>
@required
- (void)cacheResponseObject:(id)responseObject forRequestTask:(SFRequestTask *)requestTask;;
- (id)responseObjectForCachedRequestTask:(SFRequestTask *)requestTask;
@end

NS_ASSUME_NONNULL_END
