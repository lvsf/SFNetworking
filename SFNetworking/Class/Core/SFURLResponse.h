//
//  SFURLResponse.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLError.h"

@interface SFURLResponse : NSObject
@property (nonatomic,assign) BOOL success;
@property (nonatomic,assign) SFURLErrorCode code;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,strong) id responseObject;
@property (nonatomic,strong) id reformerObject;
@property (nonatomic,strong) NSURLSessionTask *sessionTask;
+ (instancetype)responseWithURLSessionDataTask:(NSURLSessionTask *)dataTask
                                responseObject:(id)responseObject
                                         error:(SFURLError *)error;
@end
