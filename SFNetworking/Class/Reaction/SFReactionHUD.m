//
//  SFReactionHUD.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFReactionHUD.h"
#import <MBProgressHUD.h>
#import "SFRequestTask.h"

@interface SFReactionHUD()
@property (nonatomic,strong) MBProgressHUD *HUD;
@end

@implementation SFReactionHUD
@synthesize reactionView = _reactionView;

+ (instancetype)reactionWithReactionView:(UIView *)reactionView {
    SFReactionHUD *reaction = [SFReactionHUD new];
    reaction.reactionView = reactionView;
    return reaction;
}

- (void)requestReactionToRequestTask:(SFRequestTask *)requestTask {
    NSLog(@"[SFReactionHUD] 开始请求");
    _HUD = [MBProgressHUD showHUDAddedTo:self.reactionView animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)respondReactionToRequestTask:(SFRequestTask *)requestTask {
    NSLog(@"[SFReactionHUD] 请求完成");
    if (requestTask.response.message.length > 0) {
        [_HUD setMode:MBProgressHUDModeText];
        [_HUD.label setText:requestTask.response.message];
        [_HUD.label setNumberOfLines:0];
        [_HUD.label setFont:[UIFont boldSystemFontOfSize:16]];
        [_HUD hideAnimated:YES afterDelay:1.5];
    }
    else {
        [_HUD hideAnimated:YES];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
