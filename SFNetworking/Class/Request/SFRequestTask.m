//
//  SFRequestTask.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestTask.h"
#import "SFNetworkingEngine.h"

@implementation SFRequestTask

- (instancetype)init {
    if (self = [super init]) {
        _requestStatus = SFRequestTaskStatusPrepare;
        _record = NO;
#ifdef DEBUG
        _record = YES;
#endif
        
    }
    return self;
}

- (void)cancel {
    [[SFNetworkingEngine defaultEngine] cancelTask:self];
}

- (void)completeWithResponse:(SFResponse *)response {
    [[SFNetworkingEngine defaultEngine] completeTask:self withResponse:response];
}

- (SFRequestSerializer<SFRequestSerializerProtocol> *)requestSerializer {
    return _requestSerializer?:({
        _requestSerializer = [SFRequestSerializer new];
        _requestSerializer.serializerType = SFResponseSerializerTypeJSON;
        _requestSerializer;
    });
}

- (SFResponseSerializer<SFResponseSerializerProtocol> *)responseSerializer {
    return _responseSerializer?:({
        _responseSerializer = [SFResponseSerializer new];
        _responseSerializer.serializerType = SFResponseSerializerTypeJSON;
        _responseSerializer;
    });
}

@end
