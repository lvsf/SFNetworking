//
//  SFRequestSerializer.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestSerializer.h"

@implementation SFRequestSerializer

- (instancetype)init {
    if (self = [super init]) {
        _serializerType = SFRequestSerializerTypeJSON;
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

- (NSString *)requestTaskURLWithRequest:(SFRequest *)request {
    NSString *taskURL = request.taskURL;
    if (taskURL == nil) {
        NSString *baseURL = request.baseURL?:_baseURL;
        if (baseURL.length > 0) {
            NSString *pathURL = request.pathURL;
            if (pathURL == nil && request.subPathURL) {
                NSString *module = request.module?:_module;
                NSString *version = request.version?:_version;
                if (version.length > 0 && module.length > 0) {
                    pathURL = [NSString stringWithFormat:@"%@/%@/%@",module,version,request.subPathURL];
                }
                else if (version.length > 0 || module.length > 0){
                    pathURL = [NSString stringWithFormat:@"%@/%@",module?:version,request.subPathURL];
                }
                else {
                    pathURL = request.subPathURL;
                }
                pathURL = [pathURL stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            }
            if (pathURL) {
                pathURL = ([pathURL hasPrefix:@"/"])?[pathURL substringFromIndex:1]:pathURL;
                taskURL = [[NSURL URLWithString:pathURL?:@""
                                  relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
            }
        }
    }
    return taskURL;
}

- (NSDictionary *)requestParametersWithRequest:(SFRequest *)request {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters addEntriesFromDictionary:request.parameters];
    [parameters addEntriesFromDictionary:_builtinParameters];
    if ([request.page respondsToSelector:@selector(requestPageParameters)]) {
        [parameters addEntriesFromDictionary:[request.page requestPageParameters]];
    }
    return parameters;
}

@end
