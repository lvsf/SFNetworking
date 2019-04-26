//
//  SFRequestError.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestError.h"

@implementation SFRequestError

+ (instancetype)requestErrorWithError:(NSError *)error {
    SFRequestError *requestError = [self new];
    requestError.code = error.code;
    requestError.message = error.localizedDescription;
    return requestError;
}

+ (instancetype)requestErrorWithCode:(SFURLErrorCode)code message:(NSString *)message {
    SFRequestError *requestError = [self new];
    requestError.code = code;
    requestError.message = message;
    return requestError;
}

+ (instancetype)requestErrorWithCustomCode:(SFURLErrorCustomCode)customCode message:(NSString *)message {
    SFRequestError *requestError = [self new];
    requestError.code = SFURLErrorCustom;
    requestError.customCode = customCode;
    requestError.message = message;
    return requestError;
}

@end
