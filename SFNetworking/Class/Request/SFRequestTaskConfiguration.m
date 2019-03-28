//
//  SFRequestTaskConfiguration.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestTaskConfiguration.h"

@implementation SFRequestTaskConfiguration

- (id)copyWithZone:(NSZone *)zone {
    SFRequestTaskConfiguration *configuration = [self.class new];
    configuration.baseURL = _baseURL;
    configuration.HTTPHeaders = _HTTPHeaders;
    configuration.builtinParameters = _builtinParameters;
    configuration.acceptableContentTypes = _acceptableContentTypes;
    configuration.timeoutInterval = _timeoutInterval;
    configuration.record = _record;
    return configuration;
}

- (instancetype)init {
    if (self = [super init]) {
        _record = YES;
        _timeoutInterval = 25;
        _acceptableContentTypes = @[@"application/json",
                                    @"text/json",
                                    @"text/javascript",
                                    @"text/html",
                                    @"text/plain",
                                    @"application/x-javascript"];
    }
    return self;
}

- (SFRequestTaskConfiguration *)duplicate {
    return [self copy];
}

- (SFRequestTaskConfiguration * _Nonnull (^)(BOOL))record_ {
    return ^SFRequestTaskConfiguration *(BOOL record){
        self.record = record;
        return self;
    };
}

- (SFRequestTaskConfiguration * _Nonnull (^)(NSTimeInterval))timeoutInterval_ {
    return ^SFRequestTaskConfiguration *(NSTimeInterval timeoutInterval){
        self.timeoutInterval = timeoutInterval;
        return self;
    };
}

@end
