//
//  SFURLTaskInteraction.m
//  ZSLYApp
//
//  Created by YunSL on 2018/1/4.
//  Copyright © 2018年 ZSLY. All rights reserved.
//

#import "SFURLTaskInteraction.h"

@interface SFURLTaskInteraction()<SFURLTaskInteractionDelegate>
@end

@implementation SFURLTaskInteraction
@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize respond = _respond;

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)task:(SFURLTask *)task beginInteractionWithRequest:(SFURLRequest *)request {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ([self.respond respondsToSelector:@selector(taskEndResponseInteraction:)]) {
        [self.respond taskEndResponseInteraction:task];
    }
    if ([self.request respondsToSelector:@selector(task:beginInteractionWithRequest:)]) {
        [self.request task:task beginInteractionWithRequest:request];
    }
}

- (void)task:(SFURLTask *)task endInteractionWithResponse:(SFURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([self.request respondsToSelector:@selector(taskEndRequestInteraction:)]) {
        [self.request taskEndRequestInteraction:task];
    }
    if (self.respond.container == nil) {
        self.respond.container = self.request.container;
    }
    if ([self.respond respondsToSelector:@selector(task:beginInteractionWithResponse:)]) {
        [self.respond task:task beginInteractionWithResponse:response];
    }
}

@end
