//
//  SFNetworingManager.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFNetworingManager.h"
#import "SFURLTaskManger.h"
#import "SFURLTaskCache.h"
#import "SFURLTaskLogger.h"
#import "SFURLTaskLog.h"
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
    [self sendTask:task completion:nil];
}

- (void)sendTask:(SFURLTask *)task completion:(void(^)(SFURLResponse *response))completion {
    SFURLRequest *request = [self requestWithTask:task];
    SFURLError *error = [self shouldSendTask:task request:request];
    task.debugLog = [SFURLTaskLog new];
    task.debugLog.request = request;
    task.debugLog.sendDate = [NSDate date];
    if (error) {
        [self didCompleteTask:task
                     response:[SFURLResponse responseWithURLSessionDataTask:nil
                                                             responseObject:nil
                                                                      error:error]];
        return;
    }
    
    [self willSendTask:task];
    
    @sf_weakify(self)
    if ([task isKindOfClass:[SFHTTPTask class]]) {
        SFHTTPTask *httpTask = (SFHTTPTask *)task;
        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
        objc_setAssociatedObject(self, _cmd, sessionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        sessionManager.requestSerializer = request.requestSerializer;
        sessionManager.responseSerializer = request.responseSerializer;
        switch (httpTask.method) {
            case SFHTTPMethodGET:{
                [sessionManager GET:request.URL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @sf_strongify(self)
                    [self completeTask:httpTask
                              dataTask:task
                        responseObject:responseObject
                                 error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    @sf_strongify(self)
                    [self completeTask:httpTask
                              dataTask:task
                        responseObject:nil
                                 error:error];
                }];
            }
                break;
            case SFHTTPMethodPOST:{
                [sessionManager POST:request.URL parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    if (httpTask.formData) {
                        [formData appendPartWithFileData:httpTask.formData.data
                                                    name:httpTask.formData.name
                                                fileName:httpTask.formData.fileName
                                                mimeType:httpTask.formData.mimeType];
                    }
                } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @sf_strongify(self)
                    [self completeTask:httpTask
                              dataTask:task
                        responseObject:responseObject
                                 error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    @sf_strongify(self)
                    [self completeTask:httpTask
                              dataTask:task
                        responseObject:nil
                                 error:error];
                }];
            }
                break;
            default:
                break;
        }
        self.httpTasks[httpTask.hashKey] = httpTask;
    }
}

- (void)checkCacheForTask:(SFURLTask *)task {
    if ([[SFURLTaskCache sharedInstance] containResponseObjectWithTask:task]) {
        id responseObject = [[SFURLTaskCache sharedInstance] getResponseObjectWithTask:task];
        SFURLResponse *response = [self responseWithURLSessionTask:nil
                                                    responseObject:responseObject
                                                             error:nil
                                                           forTask:task];
        response.fromCache = YES;
        if ([task.delegate respondsToSelector:@selector(task:didCompleteWithResponse:)]) {
            [task.delegate task:task didCompleteWithResponse:response];
        }
        if (task.completeBlock) {
            task.completeBlock(task, response);
        }
    }
}

- (void)willSendTask:(SFURLTask *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([task.interaction respondsToSelector:@selector(taskWillSend:)]) {
            [task.interaction taskWillSend:task];
        }
        if ([task.delegate respondsToSelector:@selector(taskWillSend:)]) {
            [task.delegate taskWillSend:task];
        }
        [self checkCacheForTask:task];
    });
}

- (SFURLError *)shouldSendTask:(SFURLTask *)task request:(SFURLRequest *)request {
    if ([task.filter respondsToSelector:@selector(task:shouldSendWithRequest:)]) {
        SFURLError *error = [task.filter task:task shouldSendWithRequest:nil];
        if (error) {
            return error;
        }
    }
    //1.检查重复
    BOOL shouldSendWhileFrequently = (task.filter)?task.filter.shouldSendWhileFrequently:NO;
    if (self.allTasks[task.hashKey] && !shouldSendWhileFrequently) {
        return [SFURLError errorWithCode:SFURLErrorFrequently message:@"[Frequently]"];
    }
    //2.检查缓存
    BOOL shouldSendWhileFindCache = (task.filter)?task.filter.shouldSendWhileFindCache:YES;
    if (task.cache && [[SFURLTaskCache sharedInstance] containResponseObjectWithTask:task] && !shouldSendWhileFindCache) {
        return [SFURLError errorWithCode:SFURLErrorUseCache message:@"[UseCache]"];
    }
    //3.检查网络
    BOOL shouldSendWhileNetworkNotReachable = (task.filter)?task.filter.shouldSendWhileNetworkNotReachable:NO;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable && !shouldSendWhileNetworkNotReachable) {
        return [SFURLError errorWithCode:SFURLErrorNotConnectedToInternet message:@"[NotConnectedToInternet]"];
    }
    return nil;
}

- (BOOL)shouldCompleteTask:(SFURLTask *)task response:(SFURLResponse *)response {
    BOOL shouldComplete = YES;
    if ([task.filter respondsToSelector:@selector(task:shouldCompleteWithResponse:)]) {
        shouldComplete = [task.filter task:task shouldCompleteWithResponse:response];
    }
    return shouldComplete;
}

- (void)completeTask:(SFURLTask *)task dataTask:(NSURLSessionDataTask *)dataTask responseObject:(id)responseObject error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        SFURLError *URLError = error?[SFURLError errorWithError:error]:nil;
        SFURLResponse *response = [self responseWithURLSessionTask:dataTask
                                                    responseObject:responseObject
                                                             error:URLError
                                                           forTask:task];
        if (response.success) {
            if (task.cache) {
                [[SFURLTaskCache sharedInstance] setResponseObject:responseObject forTask:task];
            }
            if ([task.page respondsToSelector:@selector(updateWithResponseObject:)]) {
                [task.page updateWithResponseObject:responseObject];
            }
        }
        [self didCompleteTask:task response:response];
    });
}

- (void)didCompleteTask:(SFURLTask *)task response:(SFURLResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self shouldCompleteTask:task response:response]) {
            if ([task.delegate respondsToSelector:@selector(task:didCompleteWithResponse:)]) {
                [task.delegate task:task didCompleteWithResponse:response];
            }
            if (task.completeBlock) {
                task.completeBlock(task, response);
            }
        }
        if ([task.interaction respondsToSelector:@selector(task:didCompleteWithResponse:)]) {
            [task.interaction task:task didCompleteWithResponse:response];
        }
        if ([self.httpTasks.allKeys containsObject:task.identifier]) {
            self.httpTasks[task.identifier] = nil;
        }
        self.allTasks[task.identifier] = nil;
        task.debugLog.response = response;
        task.debugLog.completeDate = [NSDate date];
        [[SFURLTaskLogger manager] printHTTPTaskLog:task.debugLog];
    });
}

- (SFURLRequest *)requestWithTask:(SFURLTask *)task {
    SFURLRequest *request = [SFURLRequest new];
    NSString *taskURL = task.taskURL;
    if (taskURL == nil) {
        NSString *baseURL = task.baseURL;
#ifdef DEBUG
        if (task.debugBaseURL) {
            baseURL = task.debugBaseURL;
        }
#endif
        NSString *pathURL = task.pathURL;
        pathURL = ([pathURL hasPrefix:@"/"])?[pathURL substringFromIndex:1]:pathURL;
        pathURL = pathURL?:@"";
        taskURL = [[NSURL URLWithString:pathURL
                          relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
    }
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters addEntriesFromDictionary:task.builtinParameters];
    [parameters addEntriesFromDictionary:task.parameters];
    [parameters addEntriesFromDictionary:[task.page parametersForRequest]];
    
    [request setURL:taskURL.copy];
    [request setParameters:parameters.copy];
    
    //HTTP
    if ([task isKindOfClass:[SFHTTPTask class]]) {
        SFHTTPTask *httpTask = (SFHTTPTask *)task;
        NSMutableDictionary *HTTPHeaders = [NSMutableDictionary new];
        [HTTPHeaders addEntriesFromDictionary:httpTask.builtinHTTPRequestHeaders];
        [HTTPHeaders addEntriesFromDictionary:httpTask.HTTPRequestHeaders];
        [request setHTTPMethod:httpTask.method];
        [request setHTTPHeaders:HTTPHeaders];
        [request setRequestSerializer:({
            AFHTTPRequestSerializer *serializer = nil;
            switch (httpTask.requestSerializerType) {
                case SFURLSerializerTypeHTTP:
                    serializer = [AFHTTPRequestSerializer serializer];break;
                case SFURLSerializerTypeJSON:
                    serializer = [AFJSONRequestSerializer serializer];break;
                case SFURLSerializerTypePropertyList:serializer = [AFPropertyListRequestSerializer serializer];break;
                default:break;
            }
            [HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [serializer setValue:obj forHTTPHeaderField:key];
            }];
            serializer.timeoutInterval = httpTask.timeoutInterval;
            serializer;
        })];
        [request setResponseSerializer:({
            AFHTTPResponseSerializer *serializer = nil;
            switch (httpTask.responseSerializerType) {
                case SFURLSerializerTypeHTTP:
                    serializer = [AFHTTPResponseSerializer serializer];break;
                case SFURLSerializerTypePropertyList:
                    serializer = [AFPropertyListResponseSerializer serializer];break;
                case SFURLSerializerTypeJSON:{
                    AFJSONResponseSerializer *JSONResponseSerializer = [AFJSONResponseSerializer serializer];
                    JSONResponseSerializer.removesKeysWithNullValues = YES;
                    serializer = JSONResponseSerializer;
                }
                    break;
                default:
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
        if ([task.responseSerializer respondsToSelector:@selector(task:statusWithResponseObject:)]) {
            response.status = [task.responseSerializer task:task
                                   statusWithResponseObject:responseObject];
        }
        if ([task.responseSerializer respondsToSelector:@selector(task:successWithResponseObject:)]) {
            response.success = [task.responseSerializer task:task
                                   successWithResponseObject:responseObject];
        }
    }
    if ([task.responseSerializer respondsToSelector:@selector(task:messageWithResponseObject:error:)]) {
        response.message = [task.responseSerializer task:task
                               messageWithResponseObject:responseObject
                                                   error:error];
    }
    id reformerObject = responseObject;
    if ([task.responseSerializer.reformer respondsToSelector:@selector(task:reformerObject:forResponse:)]) {
        reformerObject = [task.responseSerializer.reformer task:task reformerObject:reformerObject forResponse:response];
    }
    if ([task.responseSerializer.reformerDelegate respondsToSelector:@selector(task:reformerObject:forResponse:)]) {
        reformerObject = [task.responseSerializer.reformerDelegate task:task reformerObject:reformerObject forResponse:response];
    }
    response.reformerObject = reformerObject;
    return response;
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

@end

#pragma mark - TaskGroup
@implementation SFURLTaskManger(SFAddTaskGroup)

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

- (NSMutableArray<SFURLTaskGroup *> *)allTaskGroups {
    return _allTaskGroups?:({
        _allTaskGroups = [NSMutableArray new];
        _allTaskGroups;
    });
}

- (dispatch_queue_t)taskGroupQueue {
    return _taskGroupQueue?:({
        _taskGroupQueue = dispatch_queue_create("com.SFURLTaskManager.taskGroupQueue", NULL);
        _taskGroupQueue;
    });
}

@end

