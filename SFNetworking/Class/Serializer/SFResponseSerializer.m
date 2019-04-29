//
//  SFResponseSerializer.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFResponseSerializer.h"

@implementation SFResponseSerializer

- (instancetype)init {
    if (self = [super init]) {
        _serializerType = SFResponseSerializerTypeJSON;
        _removesKeysWithNullValues = YES;
    }
    return self;
}

- (SFResponse *)responseWithResponseObject:(id)responseObject error:(SFRequestError *)error {
    SFResponse *response = nil;
    if (error) {
        response = [SFResponse responseWithError:error];
    }
    else {
        response = [SFResponse new];
        response.responseObject = responseObject;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = responseObject;
            // 返回信息
            if (_messageKey) {
                id messageValue = nil;
                if ([_messageKey containsString:@"."]) {
                    messageValue = [dictionary valueForKey:_messageKey];
                }
                else {
                    messageValue = [dictionary objectForKey:_messageKey];
                }
                if ([messageValue isKindOfClass:[NSString class]]) {
                    response.message = (NSString *)messageValue;
                }
                else if ([messageValue respondsToSelector:@selector(stringValue)]) {
                    response.message = [messageValue stringValue];
                }
            }
            // 返回状态
            if (_statusKey) {
                id statusValue = nil;
                if ([_statusKey containsString:@"."]) {
                    statusValue = [dictionary valueForKey:_statusKey];
                }
                else {
                    statusValue = [dictionary objectForKey:_statusKey];
                }
                if ([statusValue isKindOfClass:[NSString class]]) {
                    response.status = (NSString *)statusValue;
                }
                else if ([statusValue respondsToSelector:@selector(stringValue)]) {
                    response.status = [statusValue stringValue];
                }
            }
            // 返回结果
            id successValue = nil;
            if (_successKey) {
                if ([_successKey containsString:@"."]) {
                    successValue = [dictionary valueForKey:_successKey];
                }
                else {
                    successValue = [dictionary objectForKey:_successKey];
                }
            }
            if (successValue) {
                response.success = [successValue boolValue];
            }
            else {
                if (_successStatuses.count > 0 && response.status) {
                    response.success = [_successStatuses containsObject:response.status];
                }
            }
        }
    }
    if (self.successReformer) {
        response.success = self.successReformer(response,responseObject);
    }
    if (self.messageReformer) {
        response.message = self.messageReformer(response,responseObject);
    }
    return response;
}

@end
