//
//  SFNetworkingEngine.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFNetworkingEngine.h"
#import "SFRequestRecorder.h"
#import "SFRequestProcessController.h"
#import "SFRequestReactionTrigger.h"
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
@property (nonatomic,strong) NSURLSessionTask *sessionTask;
@property (nonatomic,copy) void(^completeForGroup)(SFRequestTask *requestTask, SFResponse *response);
@end

@implementation SFRequestTask(SFNetworkingEngine)

- (void)setSessionTask:(NSURLSessionTask *)sessionTask {
    objc_setAssociatedObject(self, @selector(requestSerializer), sessionTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCompleteForGroup:(void (^)(SFRequestTask *, SFResponse *))completeForGroup {
    objc_setAssociatedObject(self, @selector(completeForGroup), completeForGroup, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURLSessionTask *)sessionTask {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(SFRequestTask *, SFResponse *))completeForGroup {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@interface SFNetworkingEngine()
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFRequestTask *> *sendingRequestTasks;
@property (nonatomic,strong) NSMutableDictionary<NSString *, SFRequestTask *> *allRequestTasks;
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

- (instancetype)init {
    if (self = [super init]) {
        _recorder = [SFRequestRecorder new];
        _processController = [SFRequestProcessController new];
        _reactionTrigger = [SFRequestReactionTrigger new];
        [self addObserver:[SFRequestCache cache]];
    }
    return self;
}

- (void)addObserver:(id<SFRequestTaskDelegate>)observer {
    if (observer && [self.observers.allObjects indexOfObject:observer] == NSNotFound) {
        [self.observers addPointer:(__bridge void * _Nullable)(observer)];
    }
}

- (void)removeObserver:(id<SFRequestTaskDelegate>)observer {
    NSInteger index = [self.observers.allObjects indexOfObject:observer];
    if (index != NSNotFound) {
        [self.observers removePointerAtIndex:index];
    }
}

- (SFRequestTask *)containTask:(SFRequestTask *)requestTask {
    NSString *identifier = requestTask.identifier;
    if (identifier == nil) {
        identifier = SFRequestTaskIdentifier(requestTask);
    }
    return [self.sendingRequestTasks objectForKey:identifier];
}

- (void)cancelTask:(SFRequestTask *)requestTask {
    if (requestTask.status == SFRequestTaskStatusPrepare || requestTask.status == SFRequestTaskStatusSending) {
        [requestTask setStatus:SFRequestTaskStatusCancelling];
        [requestTask.sessionTask cancel];
        [self _abandonRequestTask:requestTask withError:[SFRequestError errorWithCode:SFURLErrorCancelled
                                                                              message:@"SFURLErrorCancelled"]];
    }
}

- (void)completeTask:(SFRequestTask *)requestTask response:(SFResponse *)response {
    [requestTask setResponse:response];
    [self completeTask:requestTask];
}

- (void)completeTask:(SFRequestTask *)requestTask {
    _dispatch_async_on_main_queue(^{
        [requestTask setEndDate:[NSDate date]];
        [requestTask setStatus:SFRequestTaskStatusComplete];
        if (requestTask.complete) {
            requestTask.complete(requestTask, requestTask.response);
        }
        [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(requestTask:completeWithResponse:)]) {
                [obj requestTask:requestTask completeWithResponse:requestTask.response];
            }
        }];
        if (requestTask.configuration.record &&
            [self.recorder respondsToSelector:@selector(recordForRequestTaskEndHandle:)]) {
            [self.recorder recordForRequestTaskEndHandle:requestTask];
        }
        if ([self.reactionTrigger respondsToSelector:@selector(triggerReactionForRequestTaskEndHandle:)]) {
            [self.reactionTrigger triggerReactionForRequestTaskEndHandle:requestTask];
        }
        if (requestTask.completeForGroup) {
            requestTask.completeForGroup(requestTask, requestTask.response);
            requestTask.completeForGroup = nil;
        }
        requestTask.requestAttributes = nil;
        requestTask.response = nil;
        requestTask.sessionTask = nil;
        requestTask.beginDate = nil;
        requestTask.endDate = nil;
        requestTask.requestDate = nil;
        requestTask.responseDate = nil;
        if (requestTask.identifier) {
            [self.sendingRequestTasks removeObjectForKey:requestTask.identifier];
            [self.allRequestTasks removeObjectForKey:requestTask.identifier];
        }
    });
}

- (void)sendTask:(SFRequestTask *)requestTask {
    dispatch_async(self.requestQueue, ^{
        [self _sendTask:requestTask];
    });
}

- (void)_sendTask:(SFRequestTask *)requestTask {
    if (requestTask.identifier == nil) {
        requestTask.identifier = SFRequestTaskIdentifier(requestTask);
    }
    if ([requestTask isEqual:[self.allRequestTasks objectForKey:requestTask.identifier]]) {
        return;
    }
    if (requestTask.status != SFRequestTaskStatusPrepare) {
        return;
    }
    [requestTask setBeginDate:[NSDate date]];
    [requestTask setStatus:SFRequestTaskStatusSending];
    [self.allRequestTasks setObject:requestTask forKey:requestTask.identifier];
    _dispatch_async_on_main_queue(^{
        if ([self.reactionTrigger respondsToSelector:@selector(triggerReactionForRequestTaskBeginHandle:)]) {
            [self.reactionTrigger triggerReactionForRequestTaskBeginHandle:requestTask];
        }
        if ([self.recorder respondsToSelector:@selector(recordForRequestTaskBeginHandle:)]) {
            [self.recorder recordForRequestTaskBeginHandle:requestTask];
        }
    });
    SFRequestError *error = nil;
    if ([self.processController respondsToSelector:@selector(shouldSendRequestTask:withRequest:withConfiguration:)]) {
        error = [self.processController shouldSendRequestTask:requestTask withRequest:requestTask.request withConfiguration:requestTask.configuration];
    }
    if (error) {
        [self _abandonRequestTask:requestTask withError:error];
        return;
    }
    [self.sendingRequestTasks setObject:requestTask forKey:requestTask.identifier];
    [requestTask setRequestAttributes:[self _reformRequest:requestTask.request
                                         withConfiguration:requestTask.configuration]];
    [requestTask setRequestDate:[NSDate date]];
    _dispatch_async_on_main_queue(^{
        [self.observers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(requestTask:willSendWithRequestAttributes:)]) {
                [obj requestTask:requestTask willSendWithRequestAttributes:requestTask.requestAttributes];
            }
        }];
    });
    switch (requestTask.requestAttributes.kind) {
        case SFRequestKindHTTP:{
            [self _sendHTTPTask:requestTask withRequestAttributes:requestTask.requestAttributes];
        }
            break;
        default:
            break;
    }
}

- (void)_abandonRequestTask:(SFRequestTask *)requestTask withError:(SFRequestError *)error {
    SFResponse *response = [SFResponse responseWithError:error];
    [self _prepareCompleteRequestTask:requestTask withResponse:response];
}

- (void)_sendHTTPTask:(SFRequestTask *)httpTask withRequestAttributes:(SFRequestAttributes *)requestAttributes {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = requestAttributes.requestSerializer;
    sessionManager.responseSerializer = requestAttributes.responseSerializer;
    __weak SFNetworkingEngine *weak_self = self;
    void (^responseBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error){
        __strong SFNetworkingEngine *strong_self = weak_self;
        [strong_self _respondToHTTPSendTask:httpTask withResponseObject:responseObject error:error];
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

- (void)_respondToHTTPSendTask:(SFRequestTask *)requestTask withResponseObject:(id)responseObject error:(NSError *)error  {
    if (requestTask.status == SFRequestTaskStatusSending) {
        [requestTask setResponseDate:[NSDate date]];
        [self _prepareCompleteRequestTask:requestTask
                             withResponse:[requestTask.request.responseSerializer responseWithResponseObject:responseObject
                                                                                                       error:error]];
    }
}

- (void)_prepareCompleteRequestTask:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    if (requestTask.identifier && [self.sendingRequestTasks.allKeys containsObject:requestTask.identifier]) {
        [self.sendingRequestTasks removeObjectForKey:requestTask.identifier];
    }
    [requestTask setResponse:response];
    BOOL shouldComplete = YES;
    if ([self.processController respondsToSelector:@selector(shouldCompleteRequestTask:withResponse:)]) {
        shouldComplete = [self.processController shouldCompleteRequestTask:requestTask
                                                              withResponse:requestTask.response];
    }
    if (shouldComplete) {
        [self completeTask:requestTask];
    }
}

- (SFRequestAttributes *)_reformRequest:(SFRequest *)request withConfiguration:(SFRequestTaskConfiguration *)configuration {
    SFRequestAttributes *requestAttributes = [SFRequestAttributes new];
    [requestAttributes setKind:({
        SFRequestKind kind = SFRequestKindHTTP;
        kind;
    })];
    [requestAttributes setTaskURL:({
        NSString *taskURL = request.taskURL;
        if (taskURL == nil) {
            NSString *baseURL = request.baseURL?:configuration.baseURL;
            NSString *pathURL = request.pathURL;
            pathURL = ([pathURL hasPrefix:@"/"])?[pathURL substringFromIndex:1]:pathURL;
            taskURL = [[NSURL URLWithString:pathURL?:@""
                              relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
        }
        taskURL;
    })];
    [requestAttributes setParameters:({
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        [parameters addEntriesFromDictionary:request.parameters];
        [parameters addEntriesFromDictionary:configuration.builtinParameters];
        parameters;
    })];
    [requestAttributes setAcceptableContentTypes:({
        NSMutableArray *types = [NSMutableArray new];
        [types addObjectsFromArray:configuration.acceptableContentTypes];
        [types addObjectsFromArray:request.acceptableContentTypes];
        [NSSet setWithArray:[types valueForKeyPath:@"@distinctUnionOfObjects.self"]];
    })];
    [requestAttributes setRequestSerializer:({
        AFHTTPRequestSerializer *serializer = nil;
        switch (request.requestSerializer.serializerType) {
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
        [request.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [serializer setValue:obj forHTTPHeaderField:key];
        }];
        serializer.timeoutInterval = configuration.timeoutInterval;
        serializer;
    })];
    [requestAttributes setResponseSerializer:({
        AFHTTPResponseSerializer *serializer = nil;
        switch (request.responseSerializer.serializerType) {
            case SFResponseSerializerTypeHTTP:
            case SFResponseSerializerTypeXML:
                serializer = [AFHTTPResponseSerializer serializer];
                break;
            case SFResponseSerializerTypePropertyList:
                serializer = [AFPropertyListResponseSerializer serializer];
                break;
            case SFResponseSerializerTypeJSON:{
                AFJSONResponseSerializer *JSONResponseSerializer = [AFJSONResponseSerializer serializer];
                JSONResponseSerializer.removesKeysWithNullValues = YES;
                serializer = JSONResponseSerializer;
            }
                break;
        }
        serializer.acceptableContentTypes = requestAttributes.acceptableContentTypes;
        serializer;
    })];
    if (requestAttributes.kind == SFRequestKindHTTP) {
        [requestAttributes setHTTPHeaders:({
            NSMutableDictionary *HTTPHeaders = [NSMutableDictionary new];
            [HTTPHeaders addEntriesFromDictionary:request.HTTPHeaders];
            [HTTPHeaders addEntriesFromDictionary:configuration.HTTPHeaders];
            HTTPHeaders;
        })];
    }
    return requestAttributes;
}

- (NSPointerArray *)observers {
    return _observers?:({
        _observers = [NSPointerArray weakObjectsPointerArray];
        _observers;
    });
}

- (NSMutableDictionary<NSString *,SFRequestTask *> *)sendingRequestTasks {
    return _sendingRequestTasks?:({
        _sendingRequestTasks = [NSMutableDictionary new];
        _sendingRequestTasks;
    });
}

- (NSMutableDictionary<NSString *,SFRequestTask *> *)allRequestTasks {
    return _allRequestTasks?:({
        _allRequestTasks = [NSMutableDictionary new];
        _allRequestTasks;
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
    [requestGroup setBeginDate:[NSDate date]];
    [self.allRequestGroups addObject:requestGroup];
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
            [requestGroup setEndDate:[NSDate date]];
            if (requestGroup.complete) {
                requestGroup.complete(requestGroup);
            }
            [self.allRequestGroups removeObject:requestGroup];
        });
    });
    [self.allRequestGroups addObject:requestGroup];
    
}

@end
