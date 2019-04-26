//
//  SFRequestReactionProtocol.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SFRequestTask;

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestReactionProtocol <NSObject>
@property (nonatomic,weak) UIView *reactionView;
- (void)requestReactionToRequestTask:(SFRequestTask *)requestTask;
- (void)respondReactionToRequestTask:(SFRequestTask *)requestTask;
@end

NS_ASSUME_NONNULL_END
