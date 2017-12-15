//
//  SFURLTaskLogger.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskLog.h"

@interface SFURLTaskLogger : NSObject
+ (instancetype)manager;
- (void)printHTTPTaskLog:(SFURLTaskLog *)log;
@end
