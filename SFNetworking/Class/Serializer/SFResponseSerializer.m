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
            [_statusKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = nil;
                if ([obj containsString:@"."]) {
                    value = [dictionary valueForKeyPath:obj];
                }
                else if ([dictionary.allKeys containsObject:obj]) {
                    value = [dictionary objectForKey:obj];
                }
                NSString *status = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    status = value;
                }
                if ([value respondsToSelector:@selector(stringValue)]) {
                    status = [value stringValue];
                }
                if (status) {
                    response.status = status;
                    response.success = [self.successStatuses containsObject:response.status];
                    *stop = YES;
                }
            }];
            [_messageKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = nil;
                if ([obj containsString:@"."]) {
                    value = [dictionary valueForKeyPath:obj];
                }
                else if ([dictionary.allKeys containsObject:obj]) {
                    value = [dictionary objectForKey:obj];
                }
                if (value) {
                    response.message = value;
                    *stop = YES;
                }
            }];
            if (self.successReformer) {
                response.success = self.successReformer(response,responseObject);
            }
        }
    }
    if (self.messageReformer) {
        response.message = self.messageReformer(response,responseObject);
    }
    return response;
}

@end
