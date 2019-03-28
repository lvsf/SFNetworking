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
    //r.parameters = @{@"id":@"1135177390"};
    r.responseSerializer.successReformer = ^BOOL(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
        NSDictionary *d = responseObject;
        return ([d[@"resultCount"] integerValue] > 0);
    };
    r.responseSerializer.messageReformer = ^NSString * _Nullable(SFResponse * _Nonnull response, id  _Nonnull responseObject) {
        NSDictionary *d = responseObject;
        return ([d[@"resultCount"] integerValue] > 0)?response.message:@"返回结果为空";
    };
    return r;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
    SFRequest *login = [self loginRequestWithUid:@"a123"];
    
    SFRequest *app = [self appRequest];
    

    SFRequestTaskConfiguration *configuration = [SFRequestTaskConfiguration new];
//    configuration.baseURL = @"http://www.baidu.com";
//    configuration.builtinParameters = @{@"uid":@"a123"};

    SFRequestTask *task = [SFRequestTask taskWithRequest:login configuration:configuration];
    [task setComplete:^(SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        
    }];
    //[self.requestSession sendTask:task];
    //构造请求request 路径 参数 解析方式

    SFRequestTask *app_task = [SFRequestTask taskWithRequest:app configuration:configuration];
    app_task.key = @"1";
    [app_task setReaction:[SFReactionHUD new]];
    [app_task.reaction setReactionView:self.view];
 
    [app_task setCompleteFromCache:^(SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        if (response.success) {
            NSLog(@"缓存数据:%@",response.responseObject);
        }
    }];
    
    [self.requestSession sendTask:app_task];

    __block NSInteger i = 0;
    SFRequestGroup *g = [SFRequestGroup requestGroupWithType:SFRequestGroupTypeBatch];
    g.tasks = @[task,app_task,[SFRequestTask new]];
    g.process = ^(SFRequestGroup * _Nonnull requestGroup, SFRequestTask * _Nonnull requestTask, SFResponse * _Nonnull response) {
        if (i == 0) {
            [requestTask.session cancelTaskGroup:requestGroup];
        }
        i++;
        NSLog(@"SFRequestGroup process:%@",requestTask.requestAttributes.taskURL);
    };
    g.complete = ^(SFRequestGroup * _Nonnull requestGroup) {
        NSLog(@"SFRequestGroup complete");
    };
    //[[UIApplication sharedApplication].requestSession sendTaskGroup:g];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}


@end
