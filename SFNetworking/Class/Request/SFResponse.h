//
//  SFResponse.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestError.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFResponse : NSObject
@property (nonatomic,assign) BOOL success;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,assign) SFURLErrorCode code;
@property (nonatomic,assign) SFURLErrorCustomCode customCode;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,strong) id responseObject;
+ (instancetype)responseWithError:(SFRequestError *)error;
@end

NS_ASSUME_NONNULL_END
