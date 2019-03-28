//
//  NSObject+SFNetworking.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "NSObject+SFNetworking.h"
#import <objc/runtime.h>

@implementation NSObject (SFNetworking)

- (SFRequestSesssion *)requestSession {
    return objc_getAssociatedObject(self, _cmd)?:({
        SFRequestSesssion *session = [SFRequestSesssion new];
        session.sessionName = NSStringFromClass(self.class);
        objc_setAssociatedObject(self, _cmd, session, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        session;
    });
}

@end
