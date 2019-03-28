//
//  SFReactionHUD.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFReactionHUD.h"
#import <MBProgressHUD.h>

@interface SFReactionHUD()
@property (nonatomic,strong) MBProgressHUD *HUD;
@end

@implementation SFReactionHUD
@synthesize reactionView = _reactionView;

- (void)reactionBeginForRequstTask:(SFRequestTask *)requestTask {
    NSLog(@"[SFReactionHUD] 开始请求");
    _HUD = [MBProgressHUD showHUDAddedTo:self.reactionView animated:YES];
}

- (void)reactionEndForRequstTask:(SFRequestTask *)requestTask {
    [_HUD hideAnimated:YES];
    NSLog(@"[SFReactionHUD] 请求完成");
}

@end
