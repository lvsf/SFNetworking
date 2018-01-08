//
//  SFURLTaskCache.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskCache.h"
#import "YYCache.h"

@interface SFURLTaskCache()
@property (nonatomic,strong) YYCache *taskCache;
@end

@implementation SFURLTaskCache

+ (instancetype)sharedInstance {
    static SFURLTaskCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [SFURLTaskCache new];
    });
    return cache;
}

- (void)clearAllCache {
    [self.taskCache removeAllObjects];
}

- (void)clearResponseObject:(id)responseObject forTask:(SFURLTask *)task {
    [self.taskCache removeObjectForKey:task.identifier];
}

- (void)setResponseObject:(id)responseObject forTask:(SFURLTask *)task {
    [self.taskCache setObject:responseObject forKey:task.identifier];
}

- (id)getResponseObjectWithTask:(SFURLTask *)task {
    return [self.taskCache objectForKey:task.identifier];
}

- (BOOL)containResponseObjectWithTask:(SFURLTask *)task {
    return [self.taskCache containsObjectForKey:task.identifier];
}

- (YYCache *)taskCache {
    return _taskCache?:({
        _taskCache = [YYCache cacheWithName:@"com.SFURLTaskCache"];
        _taskCache;
    });
}

@end
