//
//  SFURLTaskLogger.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskLogger.h"

@implementation SFURLTaskLogger

+ (instancetype)manager {
    static SFURLTaskLogger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (void)printHTTPTaskLog:(SFURLTaskLog *)log {
    NSString *method = SFHTTPMethodText(log.request.HTTPMethod);
    NSString *result = log.response.success?@"success":@"failure";
    NSTimeInterval cost = 0;
    if (log.sendDate && log.completeDate) {
        cost = [log.completeDate timeIntervalSinceDate:log.sendDate];
    }
    NSLog(@"\n====== \n%@ URL %@ [%@] \nparams:%@ \nhead:%@ \ncode:%@ \nstatus:%@ \nmessage:%@ \ncost:%.2fs \nresponseObject:%@\n======",method,log.request.URL,result,log.request.parameters,log.request.HTTPHeaders,@(log.response.code),@(log.response.status),log.response.message,cost,log.response.responseObject);
}

@end
