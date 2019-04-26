//
//  SFNetworkingEngine.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestTask.h"
#import "SFRequestGroup.h"
#import "SFRequestSesssion.h"
#import "SFRequestProcessContollerProtocol.h"
#import "SFRequestRecorderProtocol.h"
#import "SFRequestCacheProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class SFNetworkingEngine;
@protocol SFNetworkingEngineDelegate <NSObject>
@optional

/**
 开始处理请求任务

 @param engine -
 @param requestTask -
 */
- (void)networkingEngine:(SFNetworkingEngine *)engine
  beginHandleRequestTask:(SFRequestTask *)requestTask;

/**
 开始发送请求任务/请求可能被过滤掉而不调用该方法

 @param engine -
 @param requestTask -
 @param requestAttributes -
 */
- (void)networkingEngine:(SFNetworkingEngine *)engine
         sendRequestTask:(SFRequestTask *)requestTask
   withRequestAttributes:(SFRequestAttributes *)requestAttributes;

/**
 完成发送请求任务

 @param engine -
 @param requestTask -
 @param response -
 */
- (void)networkingEngine:(SFNetworkingEngine *)engine
 completeSendRequestTask:(SFRequestTask *)requestTask
            withResponse:(SFResponse *)response;

/**
 完成处理请求任务/请求可能被暂时挂起而不调用该方法

 @param engine -
 @param requestTask -
 */
- (void)networkingEngine:(SFNetworkingEngine *)engine
    endHandleRequestTask:(SFRequestTask *)requestTask
            withResponse:(SFResponse *)response;
@end

@interface SFNetworkingEngine : NSObject
@property (nonatomic,strong) id<SFRequestProcessContollerProtocol> processController;
@property (nonatomic,strong) id<SFRequestRecorderProtocol> recorder;
@property (nonatomic,strong) id<SFRequestCacheProtocol> cache;
+ (instancetype)defaultEngine;
- (void)sendTask:(SFRequestTask *)requestTask;
- (void)cancelTask:(SFRequestTask *)requestTask;
- (void)completeTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response;
- (void)addObserver:(id<SFNetworkingEngineDelegate>)observer;
- (void)removeObserver:(id<SFNetworkingEngineDelegate>)observer;
@end

@interface SFNetworkingEngine(SFRequestGroup)
- (void)sendGroup:(SFRequestGroup *)requestGroup;
@end

NS_ASSUME_NONNULL_END
