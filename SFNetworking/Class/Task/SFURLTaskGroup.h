//
//  SFURLTaskGroup.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"

typedef NS_ENUM(NSInteger,SFURLTaskGroupMode) {
    SFURLTaskGroupModeBatch = 0,
    SFURLTaskGroupModeChain
};

@interface SFURLTaskGroup : NSObject
@property (nonatomic,copy,readonly) NSArray<SFURLTask *> *tasks;
@property (nonatomic,assign) SFURLTaskGroupMode mode;
+ (instancetype)chainGroup;
+ (instancetype)batchGroup;
- (void)addTask:(SFURLTask *)task;
@end
