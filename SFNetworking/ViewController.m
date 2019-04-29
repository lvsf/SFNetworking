//
//  ViewController.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "ViewController.h"

#import "SFReactionHUD.h"
#import "SFNetworkingEngine.h"
#import "NSObject+SFNetworking.h"

@interface ViewController ()
@property (nonatomic,strong) SFRequestTask *listTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *p = @{@"ringthemeId":@"34dfe0b3b8fc409386cb992c095e1aa3",
                        @"status":@(0)};
    NSData *p_data = [NSJSONSerialization dataWithJSONObject:p options:0 error:nil];

    
    SFRequest *listRequest = [SFRequest new];
    listRequest.taskURL = @"http://app.quanyoo.com/userCenter/API/v3/book/clock/getBookClockList.do";
    listRequest.parameters = @{@"bizParms":[[NSString alloc] initWithData:p_data encoding:NSUTF8StringEncoding]};
    listRequest.page = [SFRequestPage new];
    listRequest.page.firstPage = @(1);
    listRequest.page.size = 25;
    listRequest.page.requestPageKey = @"pageNow";
    listRequest.page.requestPageSizeKey = @"pageSize";
    listRequest.page.responsePageObjectKey = @"page";
    listRequest.page.responsePageKey = @"pageNow";
    listRequest.page.responsePageTotalKey = @"totalPage";
    
    self.listTask = [SFRequestTask new];
    self.listTask.request = listRequest;
    self.listTask.requestSerializer.serializerType = SFRequestSerializerTypeHTTP;
    self.listTask.requestSerializer.builtinParameters = @{@"personId":@"0001SX10000000000ENW",
                                                          @"accessToken":@"34a1f1de-c1fa-4a58-96ab-74314b1df546",
                                                          @"terminal":@"1",
                                                          @"terminalIMEI":@"89CC7D48-C645-4329-B14B-59528D0EF2F3",
                                                          @"terminalOS":@"iOS 12.1"
                                                          };
    self.listTask.responseSerializer.successStatuses = @[@"0"];
    self.listTask.responseSerializer.statusKey = @"errcode";
    self.listTask.responseSerializer.messageKey = @"errmsg";
    self.listTask.complete = ^(SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        
    };
    
    [self.networking_session sendTask:self.listTask];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SFRequest *request = [SFRequest new];
    request.taskURL = @"http://app.quanyoo.com/userCenter/API/v3/person/getPersonInfo.do";
    request.parameters = @{@"targetPersonId":@"0001SX10000000000ENW"};
    
    SFRequestTask *task = [SFRequestTask new];
    task.request = request;
    task.requestSerializer.serializerType = SFRequestSerializerTypeHTTP;
    task.requestSerializer.builtinParameters = @{@"personId":@"0001SX10000000000ENW",
                                                 @"accessToken":@"34a1f1de-c1fa-4a58-96ab-74314b1df546",
                                                 @"terminal":@"1",
                                                 @"terminalIMEI":@"89CC7D48-C645-4329-B14B-59528D0EF2F3",
                                                 @"terminalOS":@"iOS 12.1"};
    task.responseSerializer.successStatuses = @[@"0"];
    task.responseSerializer.statusKey = @"errcode";
    task.responseSerializer.messageKey = @"errmsg";
    
    [self.listTask loadNext];
    [self.networking_session sendTask:self.listTask];
    
    //[self.networking_session sendTask:task];
}


@end
