//
//  NSObject+SFNetworking.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestSesssion.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SFNetworking)
@property (nonatomic,strong,readonly) SFRequestSesssion *networking_session;
@end

NS_ASSUME_NONNULL_END
