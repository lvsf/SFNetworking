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
    api.taskURL = @"http://itunes.apple.com/lookup";
    api.parameters = @{@"id":@"1135177390"};
    api.method = SFHTTPMethodGET;

    self.sf_network[@"testApi"] = api;
    self.sf_network.sendTask(api);
}

@end
