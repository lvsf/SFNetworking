//
//  SFRequestTask.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestTask.h"

NSString *SFRequestTaskIdentifier(SFRequestTask *requestTask) {
    if (requestTask.request.taskURL) {
        return [NSString stringWithFormat:@"%@?p=%@&bp=%@",
                requestTask.request.taskURL,
                requestTask.request.parameters?:@"",
                requestTask.configuration.builtinParameters?:@""];
    } else {
        NSString *baseURL = requestTask.configuration.baseURL?:requestTask.request.baseURL;
        return  [NSString stringWithFormat:@"%@/%@?p=%@&bp=%@",
                 baseURL,
                 requestTask.request.pathURL,
                 requestTask.request.parameters?:@"",
                 requestTask.configuration.builtinParameters?:@""];
    }
};

@implementation SFRequestTask

+ (instancetype)taskWithRequest:(SFRequest *)request configuration:(SFRequestTaskConfiguration *)configuration {
    SFRequestTask *task = [self new];
    task.request = request;
    task.configuration = configuration;
    return task;
}

- (instancetype)init {
    if (self = [super init]) {
        _status = SFRequestTaskStatusPrepare;
    }
    return self;
}

@end
