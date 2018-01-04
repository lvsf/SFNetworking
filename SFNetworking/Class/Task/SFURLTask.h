//
//  SFURLTask.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/29.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFURLTask,SFURLTaskLog,SFURLError,SFURLRequest,SFURLResponse;

typedef NS_ENUM(NSInteger,SFURLSerializerType) {
    SFURLSerializerTypeHTTP = 0,
    SFURLSerializerTypeJSON,
    SFURLSerializerTypeXML,
    SFURLSerializerTypePropertyList
};

#pragma mark - 请求过滤
@protocol SFURLTaskFilterProtocol<NSObject>
@property (nonatomic,copy) SFURLError *(^shouldSend)(SFURLTask *task, SFURLRequest *request);
@property (nonatomic,copy) SFURLError *(^shouldComplete)(SFURLTask *task, SFURLResponse *response);
- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request;
- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response;
@end

#pragma mark - 请求解析
@protocol SFURLTaskRequestSerializerProtocol<NSObject>
@optional
@property (nonatomic,copy) NSDictionary *(^appendBuiltinParameters)(SFURLTask *task);
@property (nonatomic,copy) NSDictionary *(^appendBuiltinHTTPHeaders)(SFURLTask *task);
- (NSDictionary *)taskAppendBuiltinParametersForRequest:(SFURLTask *)task;
- (NSDictionary *)taskAppendBuiltinHTTPHeadersForRequest:(SFURLTask *)task;
@end

@protocol SFURLTaskResponseSerializerProtocol<NSObject>
@optional
@property (nonatomic,copy) NSArray<NSString *> *successStatus;
@property (nonatomic,copy) BOOL (^successFromResponseObject)(id responseObject);
@property (nonatomic,copy) NSInteger (^statusFromResponseObject)(id responseObject);
@property (nonatomic,copy) NSString *(^messageFromResponseObject)(id responseObject, SFURLError *error);
- (BOOL)task:(SFURLTask *)task successWithResponseObject:(id)responseObject;
- (NSInteger)task:(SFURLTask *)task statusWithResponseObject:(id)responseObject;
- (NSString *)task:(SFURLTask *)task messageWithResponseObject:(id)responseObject error:(SFURLError *)error;
@end

#pragma mark - 请求与界面交互
@protocol SFURLTaskInteractionDelegate<NSObject>
@optional
- (void)task:(SFURLTask *)task beginInteractionWithRequest:(SFURLRequest *)request;
- (void)task:(SFURLTask *)task endInteractionWithResponse:(SFURLResponse *)response;
@end

@protocol SFURLTaskInteractionResponderProtocol<NSObject>
@property (nonatomic,weak) UIView *container;
@property (nonatomic,assign) UIEdgeInsets containerInset;
@end

@protocol SFURLTaskInteractionProtocol<NSObject>
@optional
@property (nonatomic,weak) id<SFURLTaskInteractionDelegate> delegate;
@property (nonatomic,copy) id<SFURLTaskInteractionResponderProtocol> (^loadingResponder)(SFURLTask *task, SFURLRequest *request);
@property (nonatomic,copy) id<SFURLTaskInteractionResponderProtocol> (^completeResponder)(SFURLTask *task, SFURLResponse *response);
- (id<SFURLTaskInteractionResponderProtocol>)task:(SFURLTask *)task
                       loadingResponderForRequest:(SFURLRequest *)request;
- (id<SFURLTaskInteractionResponderProtocol>)task:(SFURLTask *)task
                     completeResponderForResponse:(SFURLResponse *)response;
@end

#pragma mark - 请求回调
@protocol SFURLTaskRequestDelegate<NSObject>
@optional
- (void)taskWillSend:(SFURLTask *)task;
- (void)task:(SFURLTask *)task didCompleteWithResponse:(SFURLResponse *)response;
- (void)task:(SFURLTask *)task didHitCacheWithResponse:(SFURLResponse *)response;
@end

#pragma mark - 请求调试
@protocol SFURLTaskDebugDelegate<NSObject>
- (void)task:(SFURLTask *)task printLogWithRequest:(SFURLRequest *)request andResponse:(SFURLResponse *)response;
@end

@interface SFURLTask : NSObject
@property (nonatomic,copy,readonly) NSString *identifier;
@property (nonatomic,assign) BOOL cache;
@property (nonatomic,copy) NSString *taskURL;
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSString *pathURL;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,assign) SFURLSerializerType responseSerializerType;
@property (nonatomic,strong) SFURLRequest *request;
@property (nonatomic,strong) id<SFURLTaskFilterProtocol> filter;
@property (nonatomic,strong) id<SFURLTaskInteractionProtocol> interaction;
@property (nonatomic,strong) id<SFURLTaskRequestSerializerProtocol> requestSerializer;
@property (nonatomic,strong) id<SFURLTaskResponseSerializerProtocol> responseSerializer;
@property (nonatomic,copy) void (^willSend)(SFURLTask *task);
@property (nonatomic,copy) void (^hitCache)(SFURLTask *task, SFURLResponse *response);
@property (nonatomic,copy) void (^complete)(SFURLTask *task, SFURLResponse *response);
@property (nonatomic,weak) id<SFURLTaskRequestDelegate> delegate;
@property (nonatomic,weak) id<SFURLTaskDebugDelegate> debugDelegate;
@end
