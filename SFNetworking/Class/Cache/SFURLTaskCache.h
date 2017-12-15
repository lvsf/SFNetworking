//
//  SFURLTaskCache.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFHTTPTask.h"
@interface SFURLTaskCache : NSObject
+ (instancetype)sharedInstance;
- (void)clearAllCache;
- (void)clearResponseObject:(id)responseObject forTask:(SFURLTask *)task;
- (void)setResponseObject:(id)responseObject forTask:(SFURLTask *)task;
- (BOOL)containResponseObjectWithTask:(SFURLTask *)task;
- (id)getResponseObjectWithTask:(SFURLTask *)task;
@end
