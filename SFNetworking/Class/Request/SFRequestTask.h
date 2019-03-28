//
//  SFRequestTask.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"
#import "SFRequestAttributes.h"
#import "SFRequestTaskConfiguration.h"
#import "SFRequestReactionProtocol.h"
#import "SFResponse.h"

@class SFRequestSesssion,SFRequestTask;

extern NSString *SFRequestTaskIdentifier(SFRequestTask *requestTask);

typedef NS_ENUM(NSInteger,SFRequestTaskStatus) {
    SFRequestTaskStatusPrepare = 0,
    SFRequestTaskStatusCancelling,
    SFRequestTaskStatusSending,
    SFRequestTaskStatusComplete,
};

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestTask : NSObject
@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,weak) SFRequestSesssion *session;
@property (nonatomic,assign) SFRequestTaskStatus status;
@property (nonatomic,strong,nullable) NSDate *beginDate;
@property (nonatomic,strong,nullable) NSDate *endDate;
@property (nonatomic,strong,nullable) NSDate *requestDate;
@property (nonatomic,strong,nullable) NSDate *responseDate;
@property (nonatomic,strong) SFRequest *request;
@property (nonatomic,strong) SFRequestTaskConfiguration *configuration;
@property (nonatomic,strong,nullable) SFRequestAttributes *requestAttributes;
@property (nonatomic,strong,nullable) SFResponse *response;
@property (nonatomic,strong,nullable) id<SFRequestReactionProtocol> reaction;
@property (nonatomic,copy) void (^complete)(SFRequestTask *requestTask, SFResponse *response);
@property (nonatomic,copy) void (^completeFromCache)(SFRequestTask *requestTask, SFResponse *response);
+ (instancetype)taskWithRequest:(SFRequest *)request configuration:(SFRequestTaskConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END
