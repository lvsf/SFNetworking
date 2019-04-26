//
//  SFResponse.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFResponse.h"

@implementation SFResponse

+ (instancetype)responseWithError:(SFRequestError *)error {
    SFResponse *response = [SFResponse new];
    response.success = NO;
    response.code = error.code;
    response.customCode = error.customCode;
    response.message = error.message;
    return response;
}

@end
