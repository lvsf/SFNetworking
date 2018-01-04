//
//  SFURLTaskLogger.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskLogger.h"

@implementation SFURLTaskLogger

+ (instancetype)manager {
    static SFURLTaskLogger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

@end
