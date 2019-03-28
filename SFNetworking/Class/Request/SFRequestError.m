//
//  SFRequestError.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestError.h"

@implementation SFRequestError

+ (instancetype)errorWithCode:(SFURLErrorCode)code message:(NSString *)message {
    SFRequestError *error = [self new];
    error.code = code;
    error.message = message;
    return error;
}

+ (instancetype)errorWithCustomCode:(SFURLErrorCustomCode)customCode message:(NSString *)message {
    SFRequestError *error = [self new];
    error.code = SFURLErrorCustom;
    error.customCode = customCode;
    error.message = message;
    return error;
}

@end
