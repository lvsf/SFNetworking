//
//  SFResponseSerializer.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFResponseSerializer.h"
#import "SFResponse.h"

@implementation SFResponseSerializer
@synthesize codeKeys = _codeKeys;
@synthesize messageKeys = _messageKeys;
@synthesize successStatusVaules = _successStatusVaules;
@synthesize successReformer = _successReformer;
@synthesize messageReformer = _messageReformer;

- (SFResponse *)responseWithResponseObject:(id)responseObject error:(NSError * _Nullable)error {
    SFResponse *response = [SFResponse new];
    response.responseObject = responseObject;
    if (error) {
        response.success = NO;
        response.code = error.code;
        response.message = error.localizedDescription;
    }
    else {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = responseObject;
            [_codeKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = nil;
                if ([obj containsString:@"."]) {
                    value = [dictionary valueForKeyPath:obj];
                }
                else if ([dictionary.allKeys containsObject:obj]) {
                    value = [dictionary objectForKey:obj];
                }
                if (value) {
                    response.status = [value integerValue];
                    response.success = [self.successStatusVaules containsObject:@(response.status)];
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
            if (self.messageReformer) {
                response.message = self.messageReformer(response,responseObject);
            }
        }
    }
    return response;
}

@end
