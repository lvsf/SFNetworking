//
//  ViewController.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/15.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+SFNetworking.h"

#import "SFRequestGroup.h"

#import "SFReactionHUD.h"

@interface ViewController ()
@property (nonatomic,strong) id task;
@property (nonatomic,strong) id lanuncher;
@end

@implementation ViewController

- (SFRequest *)loginRequestWithUid:(NSString *)request {
    SFRequest *r = [SFRequest new];
    r.taskURL = @"http://www.baidu.com";
    r.parameters = @{@"test":@"123456"};
    r.HTTPHeaders = @{@"token":@"abc123"};
    r.method = SFRequestMethodPOST;
    return r;
}

- (SFRequest *)appRequest {
    SFRequest *r = [SFRequest new];
    r.method = SFRequestMethodGET;
    r.taskURL = @"https://itunes.apple.com/lookup?id=1135177390";
    return r;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
    SFRequest *login = [self loginRequestWithUid:@"a123"];
    SFRequestTask *loginTask = [SFRequestTask new];
    [loginTask setRequest:login];
    [loginTask setComplete:^(SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        
    }];
    
    SFRequest *app = [self appRequest];
    SFRequestTask *appTask = [SFRequestTask new];
    [appTask setRecord:YES];
    [appTask setRequest:app];
    [appTask setReaction:[SFReactionHUD reactionWithReactionView:self.view]];
    [appTask setCompleteFromCache:^(SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        if (response.success) {
            NSLog(@"缓存数据:%@",response.responseObject);
        }
    }];
    appTask.responseSerializer.successReformer = ^BOOL(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
        NSDictionary *d = responseObject;
        return ([d[@"resultCount"] integerValue] > 0);
    };
    appTask.responseSerializer.messageReformer = ^NSString * _Nullable(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
        NSDictionary *d = responseObject;
        return ([d[@"resultCount"] integerValue] > 0)?response.message:@"返回结果为空";
    };
    //[self.networking_session sendTask:appTask];

    __block NSInteger i = 0;
    SFRequestGroup *g = [SFRequestGroup requestGroupWithType:SFRequestGroupTypeBatch];
    g.tasks = @[loginTask,appTask];
    g.process = ^(SFRequestGroup * _Nonnull requestGroup, SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        if (i == 0) {
        }
        i++;
        NSLog(@"SFRequestGroup process:%@",requestTask.requestAttributes.taskURL);
    };
    g.complete = ^(SFRequestGroup * _Nonnull requestGroup) {
        NSLog(@"SFRequestGroup complete");
    };
    
    [self.networking_session sendTaskGroup:g];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}


@end
