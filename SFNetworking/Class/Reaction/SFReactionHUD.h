//
//  SFReactionHUD.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestReactionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFReactionHUD : NSObject<SFRequestReactionProtocol>
+ (instancetype)reactionWithReactionView:(UIView *)reactionView;
@end

NS_ASSUME_NONNULL_END
