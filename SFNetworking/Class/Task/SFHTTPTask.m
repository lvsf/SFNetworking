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
        default:return nil;break;
    }
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
        return [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@",
                self.taskURL,
                self.parameters,
                self.builtinParameters,
                self.HTTPRequestHeaders,
                self.builtinHTTPRequestHeaders,
                @(self.method)];
    } else {
        NSString *baseURL = self.baseURL;
#ifdef DEBUG
        baseURL = self.debugBaseURL;
#endif
        return [NSString stringWithFormat:@"%@/%@?%@&%@&%@&%@&%@",
                baseURL,
                self.pathURL,
                self.parameters,
                self.builtinParameters,
                self.HTTPRequestHeaders,
                self.builtinHTTPRequestHeaders,
                @(self.method)];
    }
}

@end
