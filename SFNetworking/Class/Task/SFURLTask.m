//
//  SFURLTask.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/29.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"

@implementation SFURLTask

- (NSString *)identifier {
    if (self.taskURL) {
        return [NSString stringWithFormat:@"%@",self.taskURL];
    } else {
        NSString *baseURL = self.baseURL;
        return [NSString stringWithFormat:@"%@/%@",baseURL,self.pathURL];
    }
}

@end
