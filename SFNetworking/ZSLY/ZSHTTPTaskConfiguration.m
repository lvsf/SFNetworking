//
//  ZSHTTPTaskConfiguration.m
//  SFNetworking
//
//  Created by YunSL on 2018/1/2.
//  Copyright © 2018年 YunSL. All rights reserved.
//

#import "ZSHTTPTaskConfiguration.h"
#import "SFURLError.h"
#import "SFURLRequest.h"
#import "SFURLResponse.h"

@implementation ZSHTTPTaskConfiguration
@synthesize shouldSend = _shouldSend;
@synthesize shouldComplete = _shouldComplete;
@synthesize appendBuiltinParameters = _appendBuiltinParameters;
@synthesize appendBuiltinHTTPHeaders = _appendBuiltinHTTPHeaders;
@synthesize loadingResponder = _loadingResponder;
@synthesize completeResponder = _completeResponder;
@synthesize delegate = _delegate;
@synthesize messageFromResponseObject = _messageFromResponseObject;
@synthesize successFromResponseObject = _successFromResponseObject;
@synthesize statusFromResponseObject = _statusFromResponseObject;
@synthesize successStatus = _successStatus;

- (instancetype)init {
    if (self = [super init]) {
        self.successStatus = @[@"10000"];
    }
    return self;
}

- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request {
    return nil;
}

- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response {
    return nil;
}

- (NSDictionary *)taskAppendBuiltinParametersForRequest:(SFURLTask *)task {
    NSMutableDictionary *builtinParameters = [NSMutableDictionary new];
    return builtinParameters.copy;
}

- (NSDictionary *)taskAppendBuiltinHTTPHeadersForRequest:(SFURLTask *)task {
    return @{};
}

- (NSInteger)task:(SFURLTask *)task statusWithResponseObject:(id)responseObject {
    NSInteger status = -1;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = responseObject;
        if ([responseDict.allKeys containsObject:@"resultCode"]) {
            status = [responseDict[@"resultCode"] integerValue];
        }
    }
    return status;
}

- (BOOL)task:(SFURLTask *)task successWithResponseObject:(id)responseObject {
    NSInteger status = -1;
    if (self.statusFromResponseObject) {
        status = self.statusFromResponseObject(responseObject);
    }
    else {
        status = [self task:task statusWithResponseObject:responseObject];
    }
    return [self.successStatus containsObject:[@(status) stringValue]];
}

- (NSString *)task:(SFURLTask *)task messageWithResponseObject:(id)responseObject error:(SFURLError *)error {
    if (error) {
        NSString *message = error.message;
        switch (error.code) {
            case SFURLErrorCustom:{
                switch (error.customCode) {
                    case SFURLErrorCustomCodeFrequently:{
                        message = @"请求太频繁";
                    }
                        break;
                    case SFURLErrorCustomCodeNetworkNotReachable:{
                        message = @"网络未连接";
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case SFURLErrorTimedOut:{
                message = @"请求超时";
            }
                break;
            case SFURLErrorCancelled:{
                message = [NSString stringWithFormat:@"请求已取消:%@",message];
            }
                break;
            default:{
                message = [NSString stringWithFormat:@"请求失败:%@(%@)",message,@(error.code)];
            }
                break;
        }
        return message;
    }
    else {
        NSString *message = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = responseObject;
            if ([responseDict.allKeys containsObject:@"message"]) {
                message = responseDict[@"message"];
            }
        }
        return message;
    }
}

- (void)task:(SFURLTask *)task printLogWithRequest:(SFURLRequest *)request andResponse:(SFURLResponse *)response {
    NSString *method = @"NULL";
    NSTimeInterval cost = 0;
    if (request) {
        method = SFHTTPMethodText(request.HTTPMethod);
        if (request.sendDate && request.completeDate) {
            cost = [request.completeDate timeIntervalSinceDate:request.sendDate];
        }
    }
    NSString *result = response.success?@"success":@"failure";
     NSLog(@"\n====== \n%@ URL %@ [%@] \nparams:%@ \nhead:%@ \ncode:%@ \nstatus:%@ \nmessage:%@ \ncost:%.2fs \nresponseObject:%@\n======",method,request.URL,result,request.parameters,request.HTTPHeaders,@(response.code),@(response.status),response.message,cost,response.responseObject);
}

@end
