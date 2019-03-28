//
//  SFRequestCacheComponentProtocol.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/28.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestCacheComponentProtocol <NSObject>
@required
- (void)setObject:(id)object forCacheKey:(NSString *)key;
- (id)objectForCacheKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
