//
//  SFURLTaskConfiguration.h
//  SFNetworking
//
//  Created by YunSL on 2018/1/2.
//  Copyright © 2018年 YunSL. All rights reserved.
//

#import "SFURLTask.h"

@interface SFURLTaskConfiguration : NSObject
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,assign) SFURLSerializerType responseSerializerType;
@end

@interface SFURLTaskConfiguration(SFAddHTTPTaskConfiguration)
@property (nonatomic,copy) NSDictionary *HTTPRequestHeaders;
@end
