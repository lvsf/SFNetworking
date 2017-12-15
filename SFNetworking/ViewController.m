//
//  ViewController.m
//  SFNetworking
//
//  Created by YunSL on 2017/12/11.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "ViewController.h"
#import "SFHTTPTask.h"
#import "SFURLError.h"

#import "UIResponder+SFAddNetworking.h"

//1.可以统一在一个对象设置/strong
//2.可以分别在各个对象里单独设置/weak
//3.可以选择继不继承统一设置

@interface ViewController ()<SFURLTaskFilterDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    SFHTTPTask *api = [SFHTTPTask new];
    api.filter.shouldSend = ^SFURLError *(SFURLTask *task, SFURLRequest *request) {
        return nil;
    };
    api.filter.shouldComplete = ^SFURLError *(SFURLTask *task, SFURLResponse *response) {
        return nil;
    };
    api.filter = self;
}

- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request {
    return nil;
}

- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response {
    return nil;
}

@end
