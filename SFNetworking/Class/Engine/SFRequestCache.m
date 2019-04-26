//
//  SFRequestCache.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/28.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestCache.h"

@implementation SFRequestCache

- (void)cacheResponseObject:(id)responseObject forRequestTask:(nonnull SFRequestTask *)requestTask {
    if ([responseObject isKindOfClass:[NSDictionary class]] ||
        [responseObject isKindOfClass:[NSArray class]] ||
        [responseObject isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:requestTask.identifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)responseObjectForCachedRequestTask:(SFRequestTask *)requestTask {
    return [[NSUserDefaults standardUserDefaults] objectForKey:requestTask.identifier];
}


//- (void)requestTaskWillSend:(SFRequestTask *)requestTask {
//    if (requestTask.completeFromCache) {
//        id responseObject = [self.component objectForCacheKey:requestTask.identifier];
//        if (responseObject) {
//            SFResponse *response = [requestTask.responseSerializer responseWithResponseObject:responseObject error:nil];
//            requestTask.completeFromCache(requestTask, response);
//        }
//    }
//}
//
//- (void)requestTask:(SFRequestTask *)requestTask completeWithResponse:(SFResponse *)response {
//    if (requestTask.completeFromCache && response.success) {
//        [self.component setObject:response.responseObject forCacheKey:requestTask.identifier];
//    }
//}

@end
