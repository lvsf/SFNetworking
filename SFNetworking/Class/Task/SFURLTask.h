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

@interface SFURLTask : NSObject
@property (nonatomic,copy,readonly) NSString *identifier;
@property (nonatomic,assign) BOOL cache;
@property (nonatomic,copy) NSString *taskURL;
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSString *pathURL;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,assign) SFURLSerializerType responseSerializerType;
@property (nonatomic,strong) SFURLTaskLog *debugLog;
@end

#pragma mark - 请求处理
@protocol SFURLTaskResponseSerializerDelegate<NSObject>
@optional
- (BOOL)task:(SFURLTask *)task successWithResponseObject:(id)responseObject;
- (NSInteger)task:(SFURLTask *)task statusWithResponseObject:(id)responseObject;
- (id)task:(SFURLTask *)task reformerObject:(id)responseObject;
- (NSString *)task:(SFURLTask *)task messageWithResponseObject:(id)responseObject error:(SFURLError *)error;
@end

@protocol SFURLTaskRequestDelegate<NSObject>
@optional
- (void)taskWillSend:(SFURLTask *)task;
- (void)task:(SFURLTask *)task didCompleteWithResponse:(SFURLResponse *)response;
- (void)task:(SFURLTask *)task didHitCacheWithResponse:(SFURLResponse *)response;
@end

@interface SFURLTask(SFAddTaskProcess)
@property (nonatomic,weak) id<SFURLTaskResponseSerializerDelegate> responseSerializer;
@property (nonatomic,copy) NSArray<NSString *> *successStatus;
@property (nonatomic,copy) BOOL (^successFromResponseObject)(id responseObject);
@property (nonatomic,copy) NSInteger (^statusFromResponseObject)(id responseObject);
@property (nonatomic,copy) NSString *(^messageFromResponseObject)(id responseObject, SFURLError *error);
@property (nonatomic,weak) id<SFURLTaskRequestDelegate> delegate;
@property (nonatomic,copy) void (^willSend)(SFURLTask *task);
@property (nonatomic,copy) void (^hitCache)(SFURLTask *task, SFURLResponse *response);
@property (nonatomic,copy) void (^complete)(SFURLTask *task, SFURLResponse *response);
@end

#pragma mark - 请求过滤
@protocol SFURLTaskFilterDelegate<NSObject>
@optional
- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request;
- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response;
@end

@interface SFURLTask(SFAddTaskFitler)
@property (nonatomic,weak) id<SFURLTaskFilterDelegate> filter;
@property (nonatomic,copy) SFURLError *(^shouldSend)(SFURLTask *task, SFURLRequest *request);
@property (nonatomic,copy) SFURLError *(^shouldComplete)(SFURLTask *task, SFURLResponse *response);
@end

#pragma mark - 请求与界面交互
@protocol SFURLTaskRequestInteractionDelegate<NSObject>
@property (nonatomic,weak) UIView *targetView;
@property (nonatomic,weak) UIView *dismissTargetView;
@property (nonatomic,copy) NSAttributedString *loadingAttributedText;
@property (nonatomic,copy) NSString *loadingText;
@property (nonatomic,copy) NSString *placeholderText;
@optional
- (void)task:(SFURLTask *)task beginInteractionWithRequest:(SFURLRequest *)request;
- (void)task:(SFURLTask *)task endInteractionWithResponse:(SFURLResponse *)response;
@end

@interface SFURLTask(SFAddTaskInteraction)
@property (nonatomic,weak) id<SFURLTaskRequestInteractionDelegate> interaction;
@end
