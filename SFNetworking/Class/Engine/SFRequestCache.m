//
//  SFRequestCache.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/28.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestCache.h"

@interface SFRequestCacheUserDefaultsComponent : NSObject<SFRequestCacheComponentProtocol>
@end

@implementation SFRequestCacheUserDefaultsComponent

- (void)setObject:(id)object forCacheKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectForCacheKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end

@implementation SFRequestCache

+ (instancetype)cache {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _component = [SFRequestCacheUserDefaultsComponent new];
    }
    return self;
}

- (void)requestTask:(SFRequestTask *)requestTask willSendWithRequestAttributes:(SFRequestAttributes *)requestAttributes {
    if (requestTask.completeFromCache) {
        id responseObject = [self.component objectForCacheKey:requestTask.identifier];
        if (responseObject) {
            SFResponse *response = [requestTask.request.responseSerializer responseWithResponseObject:responseObject error:nil];
            requestTask.completeFromCache(requestTask, response);
        }
    }
}

- (void)requestTask:(SFRequestTask *)requestTask completeWithResponse:(SFResponse *)response {
    if (requestTask.completeFromCache && response.success) {
        [self.component setObject:response.responseObject forCacheKey:requestTask.identifier];
    }
}

@end
