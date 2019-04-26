//
//  SFNetworkingEngine.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFNetworkingEngine.h"
#import "SFRequestSesssion.h"
#import "SFRequestRecorder.h"
#import "SFRequestProcessController.h"
#import "SFRequestCache.h"
#import <AFNetworking.h>
#import <objc/runtime.h>
#import <pthread.h>

static inline void _dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void SFNetworkingLog(NSString *message) {
#ifdef DEBUG
    NSLog(@"[SFNetworking] %@",message);
#endif
};

@interface SFRequestAttributes(SFNetworkingEngine)
@property (nonatomic,strong) id<AFURLRequestSerialization> requestSerializer;
@property (nonatomic,strong) id<AFURLResponseSerialization> responseSerializer;
@end

@implementation SFRequestAttributes(SFNetworkingEngine)

- (void)setRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer {
    objc_setAssociatedObject(self, @selector(requestSerializer), requestSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer {
    objc_setAssociatedObject(self, @selector(responseSerializer), responseSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AFURLRequestSerialization>)requestSerializer {
    return objc_getAssociatedObject(self, _cmd);
}

- (id<AFURLResponseSerialization>)responseSerializer {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@interface SFRequestTask(SFNetworkingEngine)
@property (nonatomic,weak) AFURLSessionManager *sessionManager;
@property (nonatomic,strong) NSURLSessionTask *sessionTask;
@property (nonatomic,copy) void(^completeForGroup)(SFRequestTask *requestTask, SFResponse *response);
@end

@implementation SFRequestTask(SFNetworkingEngine)

- (void)setSessionManager:(AFURLSessionManager *)sessionManager {
    objc_setAssociatedObject(self, @selector(sessionManager), sessionManager, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setSessionTask:(NSURLSessionTask *)sessionTask {
    objc_setAssociatedObject(self, @selector(requestSerializer), sessionTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCompleteForGroup:(void (^)(SFRequestTask *, SFResponse *))completeForGroup {
    objc_setAssociatedObject(self, @selector(completeForGroup), completeForGroup, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (AFURLSessionManager *)sessionManager {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSURLSessionTask *)sessionTask {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(SFRequestTask *, SFResponse *))completeForGroup {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@interface SFNetworkingEngine()
@property (nonatomic,strong) NSMutableDictionary<NSString *, NSMutableArray <SFRequestTask *> *> *allRequestTasks;
@property (nonatomic,strong) NSMutableArray<SFRequestGroup *> *allRequestGroups;
@property (nonatomic,strong) dispatch_queue_t requestGroupQueue;
@property (nonatomic,strong) dispatch_queue_t requestQueue;
@property (nonatomic,strong) NSPointerArray *observers;
@end

@implementation SFNetworkingEngine

+ (instancetype)defaultEngine {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)addObserver:(id<SFNetworkingEngineDelegate>)observer {
    if (observer && [self.observers.allObjects indexOfObject:observer] == NSNotFound) {
        [self.observers addPointer:(__bridge void * _Nullable)(observer)];
    }
}

- (void)removeObserver:(id<SFNetworkingEngineDelegate>)observer {
    NSInteger index = [self.observers.allObjects indexOfObject:observer];
    if (index != NSNotFound) {
        [self.observers removePointerAtIndex:index];
    }
}

- (void)sendTask:(SFRequestTask *)requestTask {
    dispatch_queue_t queue = self.requestQueue;
    if (requestTask.group) {
        queue = requestTask.group.queue?:self.requestGroupQueue;
    }
    dispatch_async(queue, ^{
        [self _sendTask:requestTask];
    });
}

- (void)cancelTask:(SFRequestTask *)requestTask {
    if (requestTask.requestStatus != SFRequestTaskStatusCancel &&
        requestTask.requestStatus != SFRequestTaskStatusComplete) {
        dispatch_queue_t queue = self.requestQueue;
        if (requestTask.group) {
            queue = requestTask.group.queue?:self.requestGroupQueue;
        }
        dispatch_async(queue, ^{
            [requestTask setRequestStatus:SFRequestTaskStatusCancel];
            [requestTask.sessionTask cancel];
            [self _abandonRequestTask:requestTask
                            withError:[SFRequestError requestErrorWithCustomCode:SFURLErrorCustomCodeInitiativeCancelled
                                                                         message:@"SFURLErrorCustomCodeInitiativeCancelled"]];
        });
    }
}

- (void)completeTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    [requestTask setResponse:response];
    if (requestTask.requestStatus != SFRequestTaskStatusComplete) {
        _dispatch_async_on_main_queue(^{
            BOOL shouldCallback = YES;
            if ([self.processController respondsToSelector:@selector(shouldCallbackCompleteForRequestTask:withResponse:)]) {
                shouldCallback = [self.processController shouldCallbackCompleteForRequestTask:requestTask
                                                                                 withResponse:response];
            }
            if (requestTask.complete && shouldCallback) {
                requestTask.complete(requestTask, response);
            }
            if (requestTask.completeForGroup) {
                requestTask.completeForGroup(requestTask, response);
                requestTask.completeForGroup = nil;
            }
            [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(networkingEngine:completeSendRequestTask:withResponse:)]) {
                    [obj networkingEngine:self completeSendRequestTask:requestTask withResponse:response];
                }
            }];
            [self _endHandleRequestTask:requestTask];
        });
    }
}

- (void)_sendTask:(SFRequestTask *)requestTask {
    BOOL should = [self _shouldHandleTask:requestTask];
    if (!should) {
        return;
    }
    [self _beginHandleTask:requestTask];
     
    SFRequestError *error = nil;
    if ([self.processController respondsToSelector:@selector(shouldSendRequestTask:withRequest:)]) {
        error = [self.processController shouldSendRequestTask:requestTask withRequest:requestTask.request];
    }
    if (error) {
        [self _abandonRequestTask:requestTask withError:error];
        return;
    }
    
    [requestTask setRequestStatus:SFRequestTaskStatusSending];
    SFRequestAttributes *requestAttributes = [self _reformRequestAttributesForRequestTask:requestTask];
    if (_observers.count > 0) {
        _dispatch_async_on_main_queue(^{
            [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(networkingEngine:sendRequestTask:withRequestAttributes:)]) {
                    [obj networkingEngine:self sendRequestTask:requestTask withRequestAttributes:requestAttributes];
                }
            }];
        });
    }
    [requestTask setRequestDate:[NSDate date]];
    switch (requestTask.requestAttributes.kind) {
        case SFRequestKindHTTP:{
            [self _sendHTTPTask:requestTask withRequestAttributes:requestAttributes];
        }
            break;
        default:
            break;
    }
}

- (BOOL)_shouldHandleTask:(SFRequestTask *)requestTask {
    // 只处理准备状态或者完成状态的请求任务
    if (requestTask.requestStatus != SFRequestTaskStatusPrepare &&
        requestTask.requestStatus != SFRequestTaskStatusComplete) {
        SFNetworkingLog([NSString stringWithFormat:@"状态无效:%@",requestTask.request]);
        return NO;
    }
    // 不处理参数无效的请求
    NSString *taskURL = [requestTask.requestSerializer requestTaskURLWithRequest:requestTask.request];
    NSDictionary *parameters = [requestTask.requestSerializer requestParametersWithRequest:requestTask.request];
    if (taskURL.length == 0) {
        SFNetworkingLog([NSString stringWithFormat:@"参数无效:%@",requestTask.request]);
        return NO;
    }
    // 不处理同时发起同一个请求任务的情况
    NSString *identifier = [NSString stringWithFormat:@"%@/%@",taskURL,parameters];
    if ([[self _requestTasksWithIdentifier:identifier] containsObject:requestTask]) {
        SFNetworkingLog([NSString stringWithFormat:@"请求无效:%@",requestTask.request]);
        return NO;
    }
    requestTask.identifier = identifier;
    requestTask.requestAttributes = [SFRequestAttributes new];
    requestTask.requestAttributes.taskURL = taskURL;
    requestTask.requestAttributes.parameters = parameters;
    requestTask.requestStatus = SFRequestTaskStatusPrepare;
    return YES;
}

- (void)_beginHandleTask:(SFRequestTask *)requestTask {
    [[self _requestTasksWithIdentifier:requestTask.identifier] addObject:requestTask];
    // 查找缓存数据
    id responseObject = nil;
    if (requestTask.completeFromCache && requestTask.identifier) {
        responseObject = [self.cache responseObjectForCachedRequestTask:requestTask];
    }
    _dispatch_async_on_main_queue(^{
        // 界面交互
        if ([requestTask.reaction respondsToSelector:@selector(requestReactionToRequestTask:)]) {
            [requestTask.reaction requestReactionToRequestTask:requestTask];
        }
        // 缓存数据回调
        if (responseObject) {
            SFResponse *response = [requestTask.responseSerializer responseWithResponseObject:responseObject error:nil];
            requestTask.completeFromCache(requestTask, response);
        }
        // 回调观察者
        [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(networkingEngine:beginHandleRequestTask:)]) {
                [obj networkingEngine:self beginHandleRequestTask:requestTask];
            }
        }];
    });
}

- (void)_sendHTTPTask:(SFRequestTask *)httpTask withRequestAttributes:(SFRequestAttributes *)requestAttributes {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = requestAttributes.requestSerializer;
    sessionManager.responseSerializer = requestAttributes.responseSerializer;
    httpTask.sessionManager = sessionManager;
    __weak SFNetworkingEngine *weak_self = self;
    void (^responseBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error){
        __strong SFNetworkingEngine *strong_self = weak_self;
        [strong_self _respondToHTTPTask:httpTask withResponseObject:responseObject error:error];
    };
    switch (httpTask.request.method) {
        case SFRequestMethodGET:{
            httpTask.sessionTask = [sessionManager GET:requestAttributes.taskURL parameters:requestAttributes.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                responseBlock(responseObject,nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                responseBlock(nil,error);
            }];
        }
            break;
        case SFRequestMethodPOST:{
            if (httpTask.request.formDatas.count > 0) {
                httpTask.sessionTask = [sessionManager POST:requestAttributes.taskURL parameters:requestAttributes.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    [httpTask.request.formDatas enumerateObjectsUsingBlock:^(id<SFHTTPRequestFormDateProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [formData appendPartWithFileData:obj.data
                                                    name:obj.name
                                                fileName:obj.fileName
                                                mimeType:obj.mimeType];
                    }];
                } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    responseBlock(responseObject,nil);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    responseBlock(nil,error);
                }];
            }
            else {
                httpTask.sessionTask = [sessionManager POST:requestAttributes.taskURL parameters:requestAttributes.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    responseBlock(responseObject,nil);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    responseBlock(nil,error);
                }];
            }
        }
            break;
        default:
            break;
    }
}

- (void)_respondToHTTPTask:(SFRequestTask *)requestTask withResponseObject:(id)responseObject error:(NSError *)error  {
    // 请求完成回调的时候有可能请求已被取消
    if (requestTask.requestStatus == SFRequestTaskStatusSending) {
        SFRequestError *requestError = nil;
        if (error) {
            requestError = [SFRequestError requestErrorWithError:error];
        }
        [requestTask setResponseDate:[NSDate date]];
        [requestTask setRequestStatus:SFRequestTaskStatusRespond];
        [self _completeRequestTask:requestTask
                      withResponse:[requestTask.responseSerializer responseWithResponseObject:responseObject
                                                                                        error:requestError]];
    }
}

- (void)_abandonRequestTask:(SFRequestTask *)requestTask withError:(SFRequestError *)error {
    SFResponse *response = [requestTask.responseSerializer responseWithResponseObject:nil error:error];
    [self _completeRequestTask:requestTask withResponse:response];
}

- (void)_completeRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    // 缓存数据
    if (requestTask.completeFromCache && response.success && requestTask.identifier) {
        [self.cache cacheResponseObject:response.responseObject forRequestTask:requestTask];
    }
    _dispatch_async_on_main_queue(^{
        // 请求日志记录
        if (requestTask.record &&
            [self.recorder respondsToSelector:@selector(recordForRequestTaskSendComplete:withResponse:)]) {
            [self.recorder recordForRequestTaskSendComplete:requestTask withResponse:response];
        }
        // 是否按正常流程结束请求任务
        BOOL shouldComplete = YES;
        if ([self.processController respondsToSelector:@selector(shouldCompleteRequestTask:withResponse:)]) {
            shouldComplete = [self.processController shouldCompleteRequestTask:requestTask withResponse:response];
        }
        if (shouldComplete) {
            [self completeTask:requestTask withResponse:response];
        }
    });
}

- (void)_endHandleRequestTask:(SFRequestTask *)requestTask {
    requestTask.requestStatus = SFRequestTaskStatusComplete;
    if ([requestTask.reaction respondsToSelector:@selector(respondReactionToRequestTask:)]) {
        [requestTask.reaction respondReactionToRequestTask:requestTask];
    }
    [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(networkingEngine:endHandleRequestTask:withResponse:)]) {
            [obj networkingEngine:self endHandleRequestTask:requestTask withResponse:requestTask.response];
        }
    }];
    NSURLSession *session = requestTask.sessionManager.session;
    requestTask.requestAttributes = nil;
    requestTask.response = nil;
    requestTask.sessionManager = nil;
    requestTask.sessionTask = nil;
    requestTask.requestDate = nil;
    requestTask.responseDate = nil;
    [session finishTasksAndInvalidate];
    [[self _requestTasksWithIdentifier:requestTask.identifier] removeObject:requestTask];
}

- (SFRequestAttributes *)_reformRequestAttributesForRequestTask:(SFRequestTask *)requestTask {
    SFRequest *request = requestTask.request;
    SFRequestSerializer *requestSerializer = requestTask.requestSerializer;
    SFResponseSerializer *responseSerializer = requestTask.responseSerializer;
    SFRequestAttributes *requestAttributes = requestTask.requestAttributes;
    [requestAttributes setKind:({
        SFRequestKind kind = SFRequestKindHTTP;
        kind;
    })];
    [requestAttributes setAcceptableContentTypes:({
        NSMutableArray *types = [NSMutableArray new];
        [types addObjectsFromArray:requestSerializer.acceptableContentTypes];
        [types addObjectsFromArray:request.acceptableContentTypes];
        [NSSet setWithArray:[types valueForKeyPath:@"@distinctUnionOfObjects.self"]];
    })];
    [requestAttributes setHTTPHeaders:({
        NSMutableDictionary *HTTPHeaders = [NSMutableDictionary new];
        [HTTPHeaders addEntriesFromDictionary:request.HTTPHeaders];
        [HTTPHeaders addEntriesFromDictionary:requestSerializer.HTTPHeaders];
        HTTPHeaders;
    })];
    [requestAttributes setRequestSerializer:({
        AFHTTPRequestSerializer *serializer = nil;
        switch (requestTask.requestSerializer.serializerType) {
            case SFRequestSerializerTypeHTTP:
            case SFRequestSerializerTypeXML:
                serializer = [AFHTTPRequestSerializer serializer];
                break;
            case SFRequestSerializerTypeJSON:
                serializer = [AFJSONRequestSerializer serializer];
                break;
            case SFRequestSerializerTypePropertyList:
                serializer = [AFPropertyListRequestSerializer serializer];
                break;
        }
        [requestAttributes.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [serializer setValue:obj forHTTPHeaderField:key];
        }];
        serializer.timeoutInterval = requestSerializer.timeoutInterval;
        serializer;
    })];
    [requestAttributes setResponseSerializer:({
        AFHTTPResponseSerializer *serializer = nil;
        switch (requestTask.responseSerializer.serializerType) {
            case SFResponseSerializerTypeHTTP:
            case SFResponseSerializerTypeXML:
                serializer = [AFHTTPResponseSerializer serializer];
                break;
            case SFResponseSerializerTypePropertyList:
                serializer = [AFPropertyListResponseSerializer serializer];
                break;
            case SFResponseSerializerTypeJSON:{
                AFJSONResponseSerializer *JSONResponseSerializer = [AFJSONResponseSerializer serializer];
                JSONResponseSerializer.removesKeysWithNullValues = responseSerializer.removesKeysWithNullValues;
                serializer = JSONResponseSerializer;
            }
                break;
        }
        serializer.acceptableContentTypes = requestAttributes.acceptableContentTypes;
        serializer;
    })];
    return requestAttributes;
}

- (NSMutableArray<SFRequestTask *> *)_requestTasksWithIdentifier:(NSString *)identifier {
    NSMutableArray *requestTasks = nil;
    if (identifier.length > 0) {
        requestTasks = self.allRequestTasks[identifier];
        if (requestTasks == nil) {
            requestTasks = [NSMutableArray new];
            self.allRequestTasks[identifier] = requestTasks;
        }
    }
    return requestTasks;
}

- (id<SFRequestRecorderProtocol>)recorder {
    return _recorder?:({
        _recorder = [SFRequestRecorder new];
        _recorder;
    });
}

- (id<SFRequestProcessContollerProtocol>)processController {
    return _processController?:({
        _processController = [SFRequestProcessController new];
        _processController;
    });
}

- (id<SFRequestCacheProtocol>)cache {
    return _cache?:({
        _cache = [SFRequestCache new];
        _cache;
    });
}

- (NSPointerArray *)observers {
    return _observers?:({
        _observers = [NSPointerArray weakObjectsPointerArray];
        _observers;
    });
}

- (dispatch_queue_t)requestQueue {
    return _requestQueue?:({
        _requestQueue = dispatch_queue_create("com.SFNetworkingEngine.requestQueue", NULL);
        _requestQueue;
    });
}


- (dispatch_queue_t)requestGroupQueue {
    return _requestGroupQueue?:({
        _requestGroupQueue = dispatch_queue_create("com.SFNetworkingEngine.requestGroupQueue", NULL);
        _requestGroupQueue;
    });
}

- (NSMutableDictionary<NSString *,NSMutableArray<SFRequestTask *> *> *)allRequestTasks {
    return _allRequestTasks?:({
        _allRequestTasks = [NSMutableDictionary new];
        _allRequestTasks;
    });
}


- (NSMutableArray<SFRequestGroup *> *)allRequestGroups {
    return _allRequestGroups?:({
        _allRequestGroups = [NSMutableArray new];
        _allRequestGroups;
    });
}

@end

@implementation SFNetworkingEngine(SFRequestGroup)

- (void)sendGroup:(SFRequestGroup *)requestGroup {
    if ([self.allRequestGroups containsObject:requestGroup]) {
        return;
    }
    [self _beginHandleGroup:requestGroup];
    dispatch_group_t group_t = dispatch_group_create();
    dispatch_semaphore_t semaphore = (requestGroup.type == SFRequestGroupTypeChain)?dispatch_semaphore_create(1):nil;
    dispatch_async(self.requestGroupQueue, ^{
        __weak typeof(requestGroup) weak_requestGroup = requestGroup;
        [requestGroup.tasks enumerateObjectsUsingBlock:^(SFRequestTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (semaphore) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_group_enter(group_t);
            [obj setCompleteForGroup:^(SFRequestTask *requestTask, SFResponse *response) {
                __strong typeof (weak_requestGroup) requestGroup = weak_requestGroup;
                if (requestGroup.process) {
                    requestGroup.process(requestGroup, requestTask, response);
                }
                if (requestGroup.type == SFRequestGroupTypeChain) {
                    dispatch_semaphore_signal(semaphore);
                }
                dispatch_group_leave(group_t);
            }];
            [self _sendTask:obj];
        }];
        dispatch_group_notify(group_t, dispatch_get_main_queue(), ^{
            __strong typeof (weak_requestGroup) requestGroup = weak_requestGroup;
            [self _endHandleGroup:requestGroup];
        });
    });
    [self.allRequestGroups addObject:requestGroup];
}

- (void)_beginHandleGroup:(SFRequestGroup *)requestGroup {
    [requestGroup setBeginDate:[NSDate date]];
    [self.allRequestGroups addObject:requestGroup];
}

- (void)_endHandleGroup:(SFRequestGroup *)requestGroup {
    [requestGroup setEndDate:[NSDate date]];
    if (requestGroup.complete) {
        requestGroup.complete(requestGroup);
    }
    [self.allRequestGroups removeObject:requestGroup];
}

@end
