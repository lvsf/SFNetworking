//
//  SFRequestGroup.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/20.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestGroup.h"

@implementation SFRequestGroup

+ (instancetype)requestGroupWithType:(SFRequestGroupType)groupType {
    SFRequestGroup *group = [self new];
    group.type = groupType;
    return group;
}

@end
