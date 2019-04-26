//
//  SFRequest.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequest.h"

inline NSString *SFRequestMethodDescription(SFRequestMethod method) {
    switch (method) {
        case SFRequestMethodGET:return @"GET";break;
        case SFRequestMethodPOST:return @"POST";break;
    }
};

@interface SFRequest()
@property (nonatomic,strong) id<SFHTTPRequestPageProtocol> page;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSArray<id<SFHTTPRequestFormDateProtocol>> *formDatas;
@end

@implementation SFRequest

- (instancetype)init {
    if (self = [super init]) {
        _method = SFRequestMethodPOST;
    }
    return self;
}

+ (instancetype)requestWithPathURL:(NSString *)pathURL parameters:(NSDictionary *)parameters {
    SFRequest *request = [SFRequest new];
    request.pathURL = pathURL;
    request.parameters = parameters;
    return request;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ taskURL:%@ baseURL:%@ pathURL:%@ subPathURL:%@ module:%@ version:%@ parameters:%@",[super description],_taskURL,_baseURL,_pathURL,_subPathURL,_module,_version,_parameters];
}

@end

@implementation SFRequest(SFHTTPRequest)
@end
