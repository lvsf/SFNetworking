//
//  SFURLError.m
//  HMSSetupApp
//
//  Created by YunSL on 2017/11/21.
//  Copyright © 2017年 HMS. All rights reserved.
//

#import "SFURLError.h"

@implementation SFURLError

+ (instancetype)errorWithCode:(SFURLErrorCode)code message:(NSString *)message {
    SFURLError *error = [self new];
    error.code = code;
    error.message = message;
    return error;
}

+ (instancetype)errorWithCustomCode:(NSInteger)code message:(NSString *)message {
    SFURLError *error = [self new];
    error.code = SFURLErrorCustom;
    error.customCode = code;
    error.message = message;
    return error;
}

+ (instancetype)errorWithError:(NSError *)error {
    return [self errorWithCode:error.code message:error.localizedDescription];
}

@end
