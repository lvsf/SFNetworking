//
//  SFRequestSesssion.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestSesssion.h"
#import "SFNetworkingEngine.h"

@interface SFRequestSesssion()<SFRequestTaskDelegate>
@property (nonatomic,strong) NSMutableArray<SFRequestTask *> *sessionTasks;
@end

@implementation SFRequestSesssion

- (instancetype)init {
    if (self = [super init]) {
        _cancelTaskAutomatic = YES;
        [[SFNetworkingEngine defaultEngine] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[SFNetworkingEngine defaultEngine] removeObserver:self];
    if (_cancelTaskAutomatic) {
        [self cancelAllTasks];
    }
}

- (void)requestTask:(SFRequestTask *)requestTask completeWithResponse:(SFResponse *)response {
    [self.sessionTasks removeObject:requestTask];
}

- (void)sendTask:(SFRequestTask *)requestTask {
    [self _willSendTask:requestTask];
    [[SFNetworkingEngine defaultEngine] sendTask:requestTask];
}

- (void)sendTaskGroup:(SFRequestGroup *)requestTaskGroup {
    [requestTaskGroup setSession:self];
    [requestTaskGroup.tasks enumerateObjectsUsingBlock:^(SFRequestTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _willSendTask:obj];
    }];
    [[SFNetworkingEngine defaultEngine] sendGroup:requestTaskGroup];
}

- (void)cancelTaskGroup:(SFRequestGroup *)requestTaskGroup {
    [requestTaskGroup.tasks enumerateObjectsUsingBlock:^(SFRequestTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelTask:obj];
    }];
}

- (void)cancelAllTasks {
    [self.tasks enumerateObjectsUsingBlock:^(SFRequestTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelTask:obj];
    }];
}

- (void)cancelTask:(SFRequestTask *)requestTask {
    [[SFNetworkingEngine defaultEngine] cancelTask:requestTask];
}

- (void)_willSendTask:(SFRequestTask *)requestTask {
    if (requestTask.configuration == nil) {
        requestTask.configuration = [SFRequestTaskConfiguration new];
    }
    [self.sessionTasks addObject:requestTask];
    [requestTask setSession:self];
}

- (NSArray<SFRequestTask *> *)tasks {
    return _sessionTasks.copy;
}

- (NSMutableArray<SFRequestTask *> *)sessionTasks {
    return _sessionTasks?:({
        _sessionTasks = [NSMutableArray new];
        _sessionTasks;
    });
}

@end
