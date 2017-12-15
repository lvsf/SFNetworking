//
//  UIResponder+SFAddNetworking.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "UIResponder+SFAddNetworking.h"
#import <objc/runtime.h>

@implementation UIResponder (SFAddNetworking)

- (SFURLTaskManager *)sf_network {
    return objc_getAssociatedObject(self, _cmd)?:({
        SFURLTaskManager *manager = [SFURLTaskManager new];
        objc_setAssociatedObject(self, _cmd, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        manager;
    });
}

@end
