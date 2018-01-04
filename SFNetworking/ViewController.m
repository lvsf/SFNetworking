//
//  ViewController.m
//  SFNetworking
//
//  Created by YunSL on 2017/12/11.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "ViewController.h"

#import "SFHTTPTask+ZSLYAdd.h"
#import "UIResponder+SFAddNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SFHTTPTask *api = [SFHTTPTask zsly_task];
    api.parameters = @{@"uid":@"123"};
    api.method = SFHTTPMethodPOST;
    api.filter.shouldSend = ^SFURLError *(SFURLTask *task, SFURLRequest *request) {
        return nil;
    };
    api.filter.shouldComplete = ^SFURLError *(SFURLTask *task, SFURLResponse *response) {
        return nil;
    };
    
    api.interaction.loadingResponder = ^id<SFURLTaskInteractionResponderProtocol>(SFURLTask *task, SFURLRequest *request) {
        return [task.interaction task:task loadingResponderForRequest:request];
    };
    api.interaction.completeResponder = ^id<SFURLTaskInteractionResponderProtocol>(SFURLTask *task, SFURLResponse *response) {
        return [task.interaction task:task completeResponderForResponse:response];
    };
    
    api.requestSerializer.appendBuiltinHTTPHeaders = ^NSDictionary *(SFURLTask *task) {
        return nil;
    };
    api.requestSerializer.appendBuiltinParameters = ^NSDictionary *(SFURLTask *task) {
        return [task.requestSerializer taskAppendBuiltinParametersForRequest:task];
    };
    
    self.sf_network[@"testApi"] = api;
    self.sf_network.sendTask(api);
}

@end
