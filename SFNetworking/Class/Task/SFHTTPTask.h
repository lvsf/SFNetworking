//
//  SFHTTPTask.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//
#import "SFURLTask.h"

@protocol SFURLTaskPageProtocol<NSObject>
@optional
@property (nonatomic,assign) SFURLTaskPageOperation lastLoadOperation;
@property (nonatomic,assign) NSInteger size;
@property (nonatomic,strong) id firstPage;
@property (nonatomic,strong,readonly) id currentPage;
@property (nonatomic,strong,readonly) id lastPage;
@property (nonatomic,strong,readonly) id nextPage;
@property (nonatomic,strong,readonly) id requestPage;
@property (nonatomic,assign,readonly) NSInteger pageTotal;
@property (nonatomic,assign,readonly) BOOL next;
- (void)reset;
- (void)reload;
- (void)loadNext;
- (void)updateWithResponseObject:(id)responseObject;
- (NSDictionary *)parametersForRequest;
@end

@protocol SFHTTPFormDateProtocol <NSObject>
@property (nonatomic,strong) NSData *data;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *mimeType;
@end

typedef NS_ENUM(NSInteger,SFHTTPMethod) {
    SFHTTPMethodGET,
    SFHTTPMethodPOST
};

typedef NS_ENUM(NSInteger,SFURLTaskPageOperation) {
    SFURLTaskPageOperationFirstLoad = 0,
    SFURLTaskPageOperationReload,
    SFURLTaskPageOperationLoadMore
};

FOUNDATION_EXTERN NSString *SFHTTPMethodText(SFHTTPMethod method);

@interface SFHTTPTask : SFURLTask

@property (nonatomic,assign) SFHTTPMethod method;

@property (nonatomic,strong) id<SFURLTaskPageProtocol> page;

@property (nonatomic,assign) SFURLSerializerType requestSerializerType;

@property (nonatomic,copy) NSDictionary *builtinHTTPRequestHeaders;

@property (nonatomic,copy) NSDictionary *HTTPRequestHeaders;

@property (nonatomic,copy) NSSet<NSString *> *acceptableContentTypes;

@property (nonatomic,strong) id<SFHTTPFormDateProtocol> formData;

@end
