//
//  SFRequestCache.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/28.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFNetworkingEngine.h"
#import "SFRequestCacheComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestCache : NSObject<SFRequestTaskDelegate>
@property (nonatomic,strong) id<SFRequestCacheComponentProtocol> component;
+ (instancetype)cache;

@end

NS_ASSUME_NONNULL_END
