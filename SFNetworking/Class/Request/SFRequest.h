//
//  SFRequest.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestPage.h"

typedef NS_ENUM(NSInteger,SFRequestMethod) {
    SFRequestMethodGET = 0,
    SFRequestMethodPOST
};

extern NSString *SFRequestMethodDescription(SFRequestMethod method);

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic,copy) NSString *pathURL;    //baseURL/pathURL?parameters
@property (nonatomic,copy) NSString *subPathURL; //baseURL/module/version/subPathURL?parameters
@property (nonatomic,copy) NSString *module;
@property (nonatomic,copy) NSString *version;
@property (nonatomic,copy) NSDictionary *parameters;
@property (nonatomic,copy) NSArray<NSString *> *acceptableContentTypes;
@property (nonatomic,strong) SFRequestPage *page;

+ (instancetype)requestWithPathURL:(NSString *)pathURL parameters:(NSDictionary *)parameters;

@end

@interface SFRequest(SFHTTPRequest)
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSArray<id<SFHTTPRequestFormDateProtocol>> *formDatas;
@end

NS_ASSUME_NONNULL_END
