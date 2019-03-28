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
#import "SFRequestProcessContollerProtocol.h"
#import "SFRequestRecorderProtocol.h"
#import "SFRequestReactionTriggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestTaskDelegate <NSObject>
@optional
- (void)requestTask:(SFRequestTask *)requestTask willSendWithRequestAttributes:(SFRequestAttributes *)requestAttributes;
- (void)requestTask:(SFRequestTask *)requestTask completeWithResponse:(SFResponse *)response;
@end

@interface SFNetworkingEngine : NSObject
@property (nonatomic,strong) id<SFRequestProcessContollerProtocol> processController;
@property (nonatomic,strong) id<SFRequestRecorderProtocol> recorder;
@property (nonatomic,strong) id<SFRequestReactionTriggerProtocol> reactionTrigger;
+ (instancetype)defaultEngine;
- (SFRequestTask *)containTask:(SFRequestTask *)requestTask;
- (void)sendTask:(SFRequestTask *)requestTask;
- (void)cancelTask:(SFRequestTask *)requestTask;
- (void)completeTask:(SFRequestTask *)requestTask;
- (void)completeTask:(SFRequestTask *)requestTask response:(SFResponse *)response;
- (void)addObserver:(id<SFRequestTaskDelegate>)observer;
- (void)removeObserver:(id<SFRequestTaskDelegate>)observer;
@end

@interface SFNetworkingEngine(SFRequestGroup)
- (void)sendGroup:(SFRequestGroup *)requestGroup;
@end

NS_ASSUME_NONNULL_END
