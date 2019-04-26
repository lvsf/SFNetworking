//
//  SFRequestSerializer.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"

typedef NS_ENUM(NSInteger,SFRequestSerializerType) {
    SFRequestSerializerTypeHTTP = 0,
    SFRequestSerializerTypeJSON,
    SFRequestSerializerTypeXML,
    SFRequestSerializerTypePropertyList
};

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestSerializerProtocol <NSObject>
@required
- (NSString *)requestTaskURLWithRequest:(SFRequest *)request;
- (NSDictionary *)requestParametersWithRequest:(SFRequest *)request;
@end

@interface SFRequestSerializer : NSObject<SFRequestSerializerProtocol>
@property (nonatomic,assign) SFRequestSerializerType serializerType;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSString *version;
@property (nonatomic,copy) NSString *module;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSDictionary *builtinParameters;
@property (nonatomic,copy) NSArray<NSString *> *acceptableContentTypes;
@end

NS_ASSUME_NONNULL_END
