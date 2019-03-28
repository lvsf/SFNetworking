//
//  SFRequest.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestSerializer.h"
#import "SFResponseSerializer.h"

typedef NS_ENUM(NSInteger,SFRequestMethod) {
    SFRequestMethodGET = 0,
    SFRequestMethodPOST
};

static inline NSString *SFRequestMethodDescription(SFRequestMethod method) {
    switch (method) {
        case SFRequestMethodGET:return @"GET";break;
        case SFRequestMethodPOST:return @"POST";break;
    }
};

NS_ASSUME_NONNULL_BEGIN

@protocol SFHTTPRequestPageProtocol <NSObject>
@end

@protocol SFHTTPRequestFormDateProtocol <NSObject>
@property (nonatomic,strong) NSData *data;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *mimeType;
- (NSData *)transformData;
@end

@interface SFRequest : NSObject
@property (nonatomic,assign) SFRequestMethod method;
@property (nonatomic,copy) NSString *taskURL;
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSString *pathURL;
@property (nonatomic,copy) NSDictionary *parameters;
@property (nonatomic,strong,nullable) SFRequestSerializer<SFRequestSerializerProtocol> *requestSerializer;
@property (nonatomic,strong,nullable) SFResponseSerializer<SFResponseSerializerProtocol> *responseSerializer;
@end

@interface SFRequest(SFHTTPRequest)
@property (nonatomic,strong) id<SFHTTPRequestPageProtocol> page;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSArray<NSString *> *acceptableContentTypes;
@property (nonatomic,copy) NSArray<id<SFHTTPRequestFormDateProtocol>> *formDatas;
@end

NS_ASSUME_NONNULL_END
