//
//  SFURLRequest.h
//  HMSSetupApp
//
//  Created by YunSL on 2017/11/20.
//  Copyright © 2017年 HMS. All rights reserved.
//

#import "SFHTTPTask.h"

@protocol AFURLRequestSerialization,AFURLResponseSerialization;
@interface SFURLRequest : NSObject
@property (nonatomic,copy) NSString *URL;
@property (nonatomic,copy) NSDictionary *parameters;
@property (nonatomic,strong) id<AFURLRequestSerialization> requestSerializer;
@property (nonatomic,strong) id<AFURLResponseSerialization> responseSerializer;
@property (nonatomic,strong) NSDate *sendDate;
@property (nonatomic,strong) NSDate *completeDate;
@end

@interface SFURLRequest(SFAddHTTPTask)
@property (nonatomic,assign) SFHTTPMethod HTTPMethod;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@end
