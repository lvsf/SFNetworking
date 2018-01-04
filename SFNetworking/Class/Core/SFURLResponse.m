//
//  SFURLResponse.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLResponse.h"

@implementation SFURLResponse

+ (instancetype)responseWithURLSessionDataTask:(NSURLSessionTask *)dataTask responseObject:(id)responseObject error:(SFURLError *)error {
    SFURLResponse *response = [self new];
    response.success = !error;
    response.responseObject = responseObject;
    response.reformerObject = responseObject;
    response.code = error.code;
    response.message = error.message;
    return response;
}

@end
