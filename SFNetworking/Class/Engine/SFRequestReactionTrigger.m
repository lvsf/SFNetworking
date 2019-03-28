//
//  SFRequestReactionTrigger.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/22.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestReactionTrigger.h"
#import "SFRequestTask.h"

@implementation SFRequestReactionTrigger

- (void)triggerReactionForRequestTaskBeginHandle:(SFRequestTask *)requestTask {
    [requestTask.reaction reactionBeginForRequstTask:requestTask];
}

- (void)triggerReactionForRequestTaskEndHandle:(SFRequestTask *)requestTask {
    [requestTask.reaction reactionEndForRequstTask:requestTask];
}

@end
