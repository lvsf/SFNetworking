//
//  UIResponder+SFAddNetworking.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskManager.h"

@interface UIResponder (SFAddNetworking)
@property (nonatomic,strong,readonly) SFURLTaskManager *sf_network;
@end
