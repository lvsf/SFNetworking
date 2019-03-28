//
//  SFRequest.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequest.h"

@interface SFRequest()
@property (nonatomic,strong) id<SFHTTPRequestPageProtocol> page;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSSet<NSString *> *acceptableContentTypes;
@property (nonatomic,copy) NSArray<id<SFHTTPRequestFormDateProtocol>> *formDatas;
@end

@implementation SFRequest

- (instancetype)init {
    if (self = [super init]) {
        _method = SFRequestMethodPOST;
    }
    return self;
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

@implementation SFRequest(SFHTTPRequest)
@end
