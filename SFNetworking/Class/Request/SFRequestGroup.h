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

@class SFRequestSesssion;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SFRequestGroupType) {
    SFRequestGroupTypeChain = 0,
    SFRequestGroupTypeBatch
};

@interface SFRequestGroup : NSObject
@property (nonatomic,copy) NSString *key;
@property (nonatomic,weak) SFRequestSesssion *session;
@property (nonatomic,assign) SFRequestGroupType type;
@property (nonatomic,strong,nullable) NSDate *beginDate;
@property (nonatomic,strong,nullable) NSDate *endDate;
@property (nonatomic,strong,nullable) id<SFRequestReactionProtocol> reaction;
@property (nonatomic,copy) NSArray<SFRequestTask *> *tasks;
@property (nonatomic,copy) void (^complete)(SFRequestGroup *requestGroup);
@property (nonatomic,copy) void (^process)(SFRequestGroup *requestGroup, SFRequestTask *requestTask, SFResponse *response);
+ (instancetype)requestGroupWithType:(SFRequestGroupType)groupType;
@end

NS_ASSUME_NONNULL_END
