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
        return [NSString stringWithFormat:@"%@?%@&%@",
                self.taskURL,
                self.parameters,
                self.builtinParameters];
    } else {
        NSString *baseURL = self.baseURL;
#ifdef DEBUG
        baseURL = self.debugBaseURL;
#endif
        return [NSString stringWithFormat:@"%@/%@?%@&%@",
                baseURL,
                self.pathURL,
                self.parameters,
                self.builtinParameters];
    }
}

@end
