//
//  SFURLTaskInteraction.m
//  SFNetworking
//
//  Created by YunSL on 2018/1/2.
//  Copyright © 2018年 YunSL. All rights reserved.
//

#import "SFURLTaskInteraction.h"

@implementation SFURLTaskInteraction
@synthesize delegate = _delegate;
@synthesize loadingResponder = _loadingResponder;
@synthesize completeResponder = _completeResponder;

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)task:(SFURLTask *)task beginInteractionWithRequest:(SFURLRequest *)request {
    
}

- (void)task:(SFURLTask *)task endInteractionWithResponse:(SFURLResponse *)response {
    
}

- (id<SFURLTaskInteractionResponderProtocol>)task:(SFURLTask *)task loadingResponderForRequest:(SFURLRequest *)request {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return nil;
}

- (id<SFURLTaskInteractionResponderProtocol>)task:(SFURLTask *)task completeResponderForResponse:(SFURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return nil;
}

@end
