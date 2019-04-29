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
#import "SFResponse.h"
#import "SFRequestSerializer.h"
#import "SFResponseSerializer.h"
#import "SFRequestReactionProtocol.h"

@class SFRequestSesssion,SFRequestGroup,SFRequestTask;

typedef NS_ENUM(NSInteger,SFRequestTaskStatus) {
    SFRequestTaskStatusPrepare = 0,
    SFRequestTaskStatusCancel,
    SFRequestTaskStatusSending,
    SFRequestTaskStatusRespond,
    SFRequestTaskStatusComplete,
};

typedef NS_ENUM(NSInteger,SFRequestTaskOperation) {
    SFRequestTaskOperationLoad = 0,
    SFRequestTaskOperationReload,
    SFRequestTaskOperationLoadNext
};

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestTask : NSObject
@property (nonatomic,assign) BOOL record;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,weak) SFRequestSesssion *session;
@property (nonatomic,weak) SFRequestGroup *group;
@property (nonatomic,assign) SFRequestTaskOperation operation;
@property (nonatomic,assign) SFRequestTaskStatus requestStatus;
@property (nonatomic,strong,nullable) NSDate *requestDate;
@property (nonatomic,strong,nullable) NSDate *responseDate;
@property (nonatomic,strong) SFRequest *request;
@property (nonatomic,strong,nullable) SFRequestAttributes *requestAttributes;
@property (nonatomic,strong,nullable) SFResponse *response;
@property (nonatomic,strong) SFRequestSerializer<SFRequestSerializerProtocol> *requestSerializer;
@property (nonatomic,strong) SFResponseSerializer<SFResponseSerializerProtocol> *responseSerializer;
@property (nonatomic,strong) id<SFRequestReactionProtocol> reaction;
@property (nonatomic,copy) void (^complete)(SFRequestTask *requestTask, SFResponse *response);
@property (nonatomic,copy) void (^completeFromCache)(SFRequestTask *requestTask, SFResponse *response);

+ (SFRequestTask *)createByRequestTask:(SFRequestTask *)requestTask;

- (void)cancel;
- (void)completeWithResponse:(SFResponse *)response;

- (void)reload;
- (void)loadNext;

@end

NS_ASSUME_NONNULL_END
