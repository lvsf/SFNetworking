//
//  SFURLTaskConfiguration.h
//  SFNetworking
//
//  Created by YunSL on 2017/12/14.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"

@interface SFURLTaskConfiguration : NSObject
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSDictionary *parameters;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,weak) id<SFURLTaskFilterProtocol> filter;
@property (nonatomic,strong) id<SFURLTaskRequestInteractionDelegate> interaction;
@property (nonatomic,strong) id<SFURLTaskResponseSerializerDelegate> responseSerializer;
@end
