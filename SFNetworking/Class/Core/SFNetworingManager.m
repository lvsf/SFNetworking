//
//  SFNetworingManager.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFNetworingManager.h"
#import "SFURLTaskCache.h"
#import "SFURLTaskLogger.h"
#import <AFNetworking.h>
#import <objc/runtime.h>

@interface SFNetworingManager()
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFURLTask *> *allTasks;
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFHTTPTask *> *httpTasks;
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFUploadTask *> *uploadTasks;
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFDownloadTask *> *downloadTasks;
@property (nonatomic,strong) NSMutableArray<SFURLTaskGroup *> *allTaskGroups;
@property (nonatomic,strong) dispatch_queue_t taskGroupQueue;
@property (nonatomic,strong) dispatch_queue_t taskQueue;
@end

#pragma mark - URLTask
@implementation SFNetworingManager

+ (instancetype)manager {
    static SFNetworingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (void)sendTask:(SFURLTask *)task {
    dispatch_async(self.taskQueue, ^{
        [self sendTask:task completion:nil];
    });
}

- (void)cancelTask:(SFURLTask *)task {
    
}

- (void)sendTask:(SFURLTask *)task completion:(void(^)(SFURLResponse *response))completion {
    //准备发送
    [self prepareSendTask:task];
    //允许发送
    SFURLError *error = [self shouldSendTask:task];
    if (error) {
        SFURLResponse *response = [SFURLResponse responseWithURLSessionDataTask:nil
                                                                 responseObject:nil
                                                                          error:error];
        [self completeTask:task response:response];
        return;
    }
    //即将发送
    [self willSendTask:task];
    //HTTP
    if ([task isKindOfClass:[SFHTTPTask class]]) {
        SFHTTPTask *httpTask = (SFHTTPTask *)task;
        SFURLRequest *request = httpTask.request;
        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
        sessionManager.requestSerializer = request.requestSerializer;
        sessionManager.responseSerializer = request.responseSerializer;
        self.httpTasks[httpTask.identifier] = httpTask;
        switch (httpTask.method) {
            case SFHTTPMethodGET:{
                [sessionManager GET:request.URL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self completeRequestWithTask:httpTask
                                         dataTask:task
                                   responseObject:responseObject
                                            error:nil
                                       completion:completion];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self completeRequestWithTask:httpTask
                                         dataTask:task
                                   responseObject:nil
                                            error:error
                                       completion:completion];
                }];
            }
                break;
            case SFHTTPMethodPOST:{
                [sessionManager POST:request.URL parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    if (httpTask.formDatas) {
                        [httpTask.formDatas enumerateObjectsUsingBlock:^(id<SFHTTPFormDateProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [formData appendPartWithFileData:obj.data
                                                        name:obj.name
                                                    fileName:obj.fileName
                                                    mimeType:obj.mimeType];
                        }];
                    }
                } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self completeRequestWithTask:httpTask
                                         dataTask:task
                                   responseObject:responseObject
                                            error:nil
                                       completion:completion];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self completeRequestWithTask:httpTask
                                         dataTask:task
                                   responseObject:nil
                                            error:error
                                       completion:completion];
                }];
            }
                break;
            default:
                break;
        }
    }
}

- (SFURLError *)shouldSendTask:(SFURLTask *)task {
    //1.网络检查
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return [SFURLError errorWithCustomCode:SFURLErrorCustomCodeNetworkNotReachable message:@"[NotConnectedToInternet]"];
    }
    //2.重复检查
    if (self.allTasks[task.identifier]) {
        return [SFURLError errorWithCustomCode:SFURLErrorCustomCodeFrequently message:@"[Frequently]"];
    }
    //3.外部检查
    SFURLError *error = nil;
    task.request = [self requestWithTask:task];
    if (task.filter.shouldSend) {
        error = task.filter.shouldSend(task,task.request);
    }
    else if ([task.filter respondsToSelector:@selector(task:shouldSendWithRequest:)]) {
        error = [task.filter task:task shouldSendWithRequest:task.request];
    }
    return error;
}

- (void)prepareSendTask:(SFURLTask *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([task.interaction.delegate respondsToSelector:@selector(task:beginInteractionWithRequest:)]) {
            [task.interaction.delegate task:task beginInteractionWithRequest:task.request];
        }
    });
}

- (void)willSendTask:(SFURLTask *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        task.request.sendDate = [NSDate date];
        if (task.willSend) {
            task.willSend(task);
        }
        if ([task.delegate respondsToSelector:@selector(taskWillSend:)]) {
            [task.delegate taskWillSend:task];
        }
        if (task.cache) {
            if ([[SFURLTaskCache sharedInstance] containResponseObjectWithTask:task]) {
                id responseObject = [[SFURLTaskCache sharedInstance] getResponseObjectWithTask:task];
                SFURLResponse *response = [self responseWithURLSessionTask:nil
                                                            responseObject:responseObject
                                                                     error:nil
                                                                   forTask:task];
                if (task.hitCache) {
                    task.hitCache(task, response);
                }
                if ([task.delegate respondsToSelector:@selector(task:didHitCacheWithResponse:)]) {
                    [task.delegate task:task didHitCacheWithResponse:response];
                }
            }
        }
    });
}

- (SFURLError *)shouldCompleteTask:(SFURLTask *)task response:(SFURLResponse *)response {
    SFURLError *error = nil;
    if (task.filter.shouldComplete) {
        error = task.filter.shouldComplete(task,response);
    }
    else if ([task.filter respondsToSelector:@selector(task:shouldCompleteResponse:)]) {
        error = [task.filter task:task shouldCompleteResponse:response];
    }
    return error;
}

- (void)completeRequestWithTask:(SFURLTask *)task dataTask:(NSURLSessionDataTask *)dataTask responseObject:(id)responseObject error:(NSError *)error completion:(void(^)(SFURLResponse *response))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        SFURLResponse *response = [self responseWithURLSessionTask:dataTask
                                                    responseObject:responseObject
                                                             error:error?[SFURLError errorWithError:error]:nil
                                                           forTask:task];
        if (response.success) {
            if (task.cache) {
                [[SFURLTaskCache sharedInstance] setResponseObject:responseObject forTask:task];
            }
        }
        if (completion) {
            completion(response);
        }
        [self completeTask:task response:response];
    });
}

- (void)completeTask:(SFURLTask *)task response:(SFURLResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        task.request.completeDate = [NSDate date];
        SFURLError *error = [self shouldCompleteTask:task response:response];
        if (!error) {
            if (task.complete) {
                task.complete(task, response);
            }
            if ([task.delegate respondsToSelector:@selector(task:didCompleteWithResponse:)]) {
                [task.delegate task:task didCompleteWithResponse:response];
            }
        }
        if ([task.interaction.delegate respondsToSelector:@selector(task:endInteractionWithResponse:)]) {
            [task.interaction.delegate task:task endInteractionWithResponse:response];
        }
        [self printLogWithTask:task request:task.request response:response];
        [self clearTask:task];
    });
}

- (void)printLogWithTask:(SFURLTask *)task request:(SFURLRequest *)request response:(SFURLResponse *)response {
    if ([task.debugDelegate respondsToSelector:@selector(task:printLogWithRequest:andResponse:)]) {
        [task.debugDelegate task:task printLogWithRequest:request andResponse:response];
    }
}

- (void)clearTask:(SFURLTask *)task {
    task.request = nil;
    self.allTasks[task.identifier] = nil;
    if ([self.httpTasks.allKeys containsObject:task.identifier]) {
        self.httpTasks[task.identifier] = nil;
    }
}

- (SFURLRequest *)requestWithTask:(SFURLTask *)task {
    SFURLRequest *request = [SFURLRequest new];
    //URL
    [request setURL:({
        NSString *taskURL = task.taskURL;
        if (taskURL == nil) {
            NSString *pathURL = task.pathURL;
            pathURL = ([pathURL hasPrefix:@"/"])?[pathURL substringFromIndex:1]:pathURL;
            pathURL = pathURL?:@"";
            taskURL = [[NSURL URLWithString:pathURL
                              relativeToURL:[NSURL URLWithString:task.baseURL]] absoluteString];
        }
        taskURL;
    })];
    //HTTP
    if ([task isKindOfClass:[SFHTTPTask class]]) {
        SFHTTPTask *httpTask = (SFHTTPTask *)task;
        [request setHTTPMethod:httpTask.method];
        [request setHTTPHeaders:SFHTTPRequestHeaders(httpTask)];
        [request setParameters:SFHTTPRequestParameters(httpTask)];
        [request setRequestSerializer:({
            AFHTTPRequestSerializer *serializer = nil;
            switch (httpTask.requestSerializerType) {
                case SFURLSerializerTypeHTTP:
                case SFURLSerializerTypeXML:
                    serializer = [AFHTTPRequestSerializer serializer];break;
                case SFURLSerializerTypeJSON:
                    serializer = [AFJSONRequestSerializer serializer];break;
                case SFURLSerializerTypePropertyList:serializer = [AFPropertyListRequestSerializer serializer];break;
            }
            [request.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [serializer setValue:obj forHTTPHeaderField:key];
            }];
            serializer.timeoutInterval = httpTask.timeoutInterval;
            serializer;
        })];
        [request setResponseSerializer:({
            AFHTTPResponseSerializer *serializer = nil;
            switch (httpTask.responseSerializerType) {
                case SFURLSerializerTypeHTTP:
                case SFURLSerializerTypeXML:
                    serializer = [AFHTTPResponseSerializer serializer];break;
                case SFURLSerializerTypePropertyList:
                    serializer = [AFPropertyListResponseSerializer serializer];break;
                case SFURLSerializerTypeJSON:{
                    AFJSONResponseSerializer *JSONResponseSerializer = [AFJSONResponseSerializer serializer];
                    JSONResponseSerializer.removesKeysWithNullValues = YES;
                    serializer = JSONResponseSerializer;
                }
                    break;
            }
            serializer.acceptableContentTypes = httpTask.acceptableContentTypes;
            serializer;
        })];
    }
    //upload
    if ([task isKindOfClass:[SFUploadTask class]]) {
        
    }
    //download
    if ([task isKindOfClass:[SFDownloadTask class]]) {
        
    }
    return request;
}

- (SFURLResponse *)responseWithURLSessionTask:(NSURLSessionTask *)sessionTask responseObject:(id)responseObject error:(SFURLError *)error forTask:(SFURLTask *)task {
    SFURLResponse *response = [SFURLResponse responseWithURLSessionDataTask:sessionTask
                                                             responseObject:responseObject
                                                                      error:error];
    if (response.success) {
        if (task.responseSerializer.statusFromResponseObject) {
            response.status = task.responseSerializer.statusFromResponseObject(responseObject);
        }
        else if ([task.responseSerializer respondsToSelector:@selector(task:statusWithResponseObject:)]) {
            response.status = [task.responseSerializer task:task statusWithResponseObject:responseObject];
        }
        if (task.responseSerializer.successFromResponseObject) {
            response.success = task.responseSerializer.successFromResponseObject(responseObject);
        }
        else if ([task.responseSerializer respondsToSelector:@selector(task:successWithResponseObject:)]) {
            response.success = [task.responseSerializer task:task
                                   successWithResponseObject:responseObject];
        }
        if (response.success) {
            if ([task isKindOfClass:[SFHTTPTask class]]) {
                SFHTTPTask *httpTask = (SFHTTPTask *)task;
                if ([httpTask.page respondsToSelector:@selector(updateWithResponseObject:)]) {
                    [httpTask.page updateWithResponseObject:responseObject];
                }
            }
        }
    }
    if (task.responseSerializer.messageFromResponseObject) {
        response.message = task.responseSerializer.messageFromResponseObject(responseObject,error);
    }
    else if ([task.responseSerializer respondsToSelector:@selector(task:messageWithResponseObject:error:)]) {
        response.message = [task.responseSerializer task:task
                               messageWithResponseObject:responseObject
                                                   error:error];
    }
    return response;
}

- (dispatch_queue_t)taskQueue {
    return _taskQueue?:({
        _taskQueue = dispatch_queue_create("com.SFNetworingManager.taskQueue", NULL);
        _taskQueue;
    });
}

- (NSMutableDictionary<NSString *,SFURLTask *> *)allTasks {
    return _allTasks?:({
        _allTasks = [NSMutableDictionary new];
        _allTasks;
    });
}

- (NSMutableDictionary<NSString *,SFHTTPTask *> *)httpTasks {
    return _httpTasks?:({
        _httpTasks = [NSMutableDictionary new];
        _httpTasks;
    });
}

- (NSMutableDictionary<NSString *,SFUploadTask *> *)uploadTasks {
    return _uploadTasks?:({
        _uploadTasks = [NSMutableDictionary new];
        _uploadTasks;
    });
}

- (NSMutableDictionary<NSString *,SFDownloadTask *> *)downloadTasks {
    return _downloadTasks?:({
        _downloadTasks = [NSMutableDictionary new];
        _downloadTasks;
    });
}

- (dispatch_queue_t)taskGroupQueue {
    return _taskGroupQueue?:({
        _taskGroupQueue = dispatch_queue_create("com.SFNetworingManager.taskGroupQueue", NULL);
        _taskGroupQueue;
    });
}

- (NSMutableArray<SFURLTaskGroup *> *)allTaskGroups {
    return _allTaskGroups?:({
        _allTaskGroups = [NSMutableArray new];
        _allTaskGroups;
    });
}

@end

#pragma mark - TaskGroup
@implementation SFNetworingManager(SFAddTaskGroup)

- (void)sendTaskGroup:(SFURLTaskGroup *)taskGroup {
    dispatch_group_t group_t = dispatch_group_create();
    dispatch_semaphore_t semaphore = (taskGroup.mode == SFURLTaskGroupModeChain)? dispatch_semaphore_create(1):nil;
    dispatch_async(self.taskGroupQueue, ^{
        __weak typeof(taskGroup) w_taskGroup = taskGroup;
        [taskGroup.tasks enumerateObjectsUsingBlock:^(SFURLTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if (taskGroup.mode == SFURLTaskGroupModeChain) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_group_enter(group_t);
            [self sendTask:task completion:^(SFURLResponse *response) {
                __strong typeof (w_taskGroup) taskGroup = w_taskGroup;
                if (taskGroup.mode == SFURLTaskGroupModeChain) {
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        }];
        dispatch_group_notify(group_t, dispatch_get_main_queue(), ^{
            [self.allTaskGroups removeObject:taskGroup];
        });
    });
    [self.allTaskGroups addObject:taskGroup];
}

@end

