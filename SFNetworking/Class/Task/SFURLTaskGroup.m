//
//  SFURLTaskGroup.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskGroup.h"

@interface SFURLTaskGroup()
@property (nonatomic,strong) NSMutableArray<SFURLTask *> *privateTasks;
@end

@implementation SFURLTaskGroup

+ (instancetype)batchGroup {
    SFURLTaskGroup *group = [self new];
    group.mode = SFURLTaskGroupModeBatch;
    return group;
}

+ (instancetype)chainGroup {
    SFURLTaskGroup *group = [self new];
    group.mode = SFURLTaskGroupModeChain;
    return group;
}

- (void)addTask:(SFURLTask *)task {
    if ([self.privateTasks indexOfObject:task] == NSNotFound) {
        [self.privateTasks addObject:task];
    }
}

- (NSArray<SFURLTask *> *)tasks {
    return self.privateTasks.copy;
}

- (NSMutableArray<SFURLTask *> *)privateTasks {
    return _privateTasks?:({
        _privateTasks = [NSMutableArray new];
        _privateTasks;
    });
}

@end
