//
//  SFRequestGroup.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"
#import "SFRequestTask.h"
#import "SFRequestReactionProtocol.h"

@class SFRequestSesssion;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SFRequestGroupType) {
    SFRequestGroupTypeChain = 0,
    SFRequestGroupTypeBatch
};

@interface SFRequestGroup : NSObject
@property (nonatomic,weak) SFRequestSesssion *session;
@property (nonatomic,assign) SFRequestGroupType type;
@property (nonatomic,copy,nullable) NSArray<SFRequestTask *> *tasks;
@property (nonatomic,strong,nullable) dispatch_queue_t queue;
@property (nonatomic,strong,nullable) NSDate *beginDate;
@property (nonatomic,strong,nullable) NSDate *endDate;
@property (nonatomic,strong,nullable) id<SFRequestReactionProtocol> reaction;
@property (nonatomic,copy,nullable) void (^process)(SFRequestGroup *requestGroup, SFRequestTask *requestTask, SFResponse *response);
@property (nonatomic,copy,nullable) void (^complete)(SFRequestGroup *requestGroup);
+ (instancetype)requestGroupWithType:(SFRequestGroupType)groupType;
@end

NS_ASSUME_NONNULL_END
