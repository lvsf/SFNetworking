//
//  SFURLTaskManager.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskManager.h"

@interface SFURLTaskManager()
@property (nonatomic,strong) NSMapTable *requestingTasks;
@property (nonatomic,strong) NSMutableDictionary *holdTasks;
@property (nonatomic,strong) dispatch_queue_t taskQueue;
@end

@implementation SFURLTaskManager

- (void)dealloc {
    [self cancelAllTasks];
}

#pragma mark - public
- (void)sendTask:(SFURLTask *)task {
    dispatch_async(self.taskQueue, ^{
        [[SFURLTaskManger manager] sendTask:task];
    });
    [self.requestingTasks setObject:task
                             forKey:task.hashKey];
}

- (void)reloadTask:(SFURLTask *)task {
    if (task.page) {
        [task.page reload];
        [self sendTask:task];
    }
    else {
        [self sendTask:task];
    }
}

- (void)loadMoreTask:(SFURLTask *)task {
    if (task.page) {
        [task.page loadNext];
        [self sendTask:task];
    }
    else {
        [self sendTask:task];
    }
}

- (void)sendTaskGroup:(SFURLTaskGroup *)taskGroup {
    [taskGroup.tasks enumerateObjectsUsingBlock:^(SFURLTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if (task.page) {
            [task.page reset];
        }
        [self.requestingTasks setObject:task
                                 forKey:task.hashKey];
    }];
    [[SFURLTaskManger manager] sendTaskGroup:taskGroup];
}

- (void)cancelAllTasks {
    [self.requestingTasks.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
}

#pragma mark - subscript
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey {
    [self.holdTasks setObject:object forKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self.holdTasks objectForKey:key];
}

#pragma mark - set/get
- (NSInteger)requestingsCount {
    return self.requestingTasks.count;
}

- (NSMapTable *)requestingTasks {
    return _requestingTasks?:({
        _requestingTasks = [NSMapTable weakToWeakObjectsMapTable];
        _requestingTasks;
    });
}

- (NSMutableDictionary *)holdTasks {
    return _holdTasks?:({
        _holdTasks = [NSMutableDictionary new];
        _holdTasks;
    });
}

- (dispatch_queue_t)taskQueue {
    return _taskQueue?:({
        _taskQueue = dispatch_queue_create("com.SFNetworingManager.queue", NULL);
        _taskQueue;
    });
}

- (SFURLTaskManager *(^)(SFURLTask *))sendTask {
    return ^SFURLTaskManager *(SFURLTask *task) {
        [self sendTask:task];
        return self;
    };
}

@end

