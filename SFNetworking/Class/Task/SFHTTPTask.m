//
//  SFHTTPTask.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFHTTPTask.h"

NSString *SFHTTPMethodText(SFHTTPMethod method) {
    switch (method) {
        case SFHTTPMethodGET:return @"GET";break;
        case SFHTTPMethodPOST:return @"POST";
    }
};

NSDictionary *SFHTTPRequestParameters(SFHTTPTask *task) {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters addEntriesFromDictionary:task.parameters];
    [parameters addEntriesFromDictionary:[task.page parametersForRequest]];
    if (task.requestSerializer.appendBuiltinParameters) {
        [parameters addEntriesFromDictionary:task.requestSerializer.appendBuiltinParameters(task)];
    }
    else if ([task.requestSerializer respondsToSelector:@selector(appendBuiltinParameters)]) {
        [parameters addEntriesFromDictionary:[task.requestSerializer taskAppendBuiltinParametersForRequest:task andCurrentParameters:parameters]];
    }
    return parameters;
};

NSDictionary *SFHTTPRequestHeaders(SFHTTPTask *task) {
    NSMutableDictionary *HTTPHeaders = [NSMutableDictionary new];
    [HTTPHeaders addEntriesFromDictionary:task.HTTPRequestHeaders];
    if (task.requestSerializer.appendBuiltinHTTPHeaders) {
        [HTTPHeaders addEntriesFromDictionary:task.requestSerializer.appendBuiltinHTTPHeaders(task)];
    }
    else if ([task.requestSerializer respondsToSelector:@selector(taskAppendBuiltinHTTPHeadersForRequest:)]) {
        [HTTPHeaders addEntriesFromDictionary:[task.requestSerializer taskAppendBuiltinHTTPHeadersForRequest:task]];
    }
    return HTTPHeaders;
};

@implementation SFHTTPTask

- (instancetype)init {
    if (self = [super init]) {
        self.cache = NO;
        self.timeoutInterval = 35;
        self.requestSerializerType = SFURLSerializerTypeJSON;
        self.responseSerializerType = SFURLSerializerTypeJSON;
        self.acceptableContentTypes = [NSSet setWithObjects:
                                       @"application/json",
                                       @"text/json",
                                       @"text/javascript",
                                       @"text/html",
                                       @"text/plain",
                                       @"application/x-javascript",nil];
    }
    return self;
}

- (NSString *)identifier {
    if (self.taskURL) {
        return [NSString stringWithFormat:@"%@?%@&%@&%@",
                self.taskURL,
                SFHTTPRequestParameters(self),
                SFHTTPRequestHeaders(self),
                @(self.method)];
    } else {
        NSString *baseURL = self.baseURL;
        return [NSString stringWithFormat:@"%@/%@?%@&%@&%@",
                baseURL,
                self.pathURL,
                SFHTTPRequestParameters(self),
                SFHTTPRequestHeaders(self),
                @(self.method)];
    }
}

@end
