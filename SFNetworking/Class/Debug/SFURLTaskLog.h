//
//  SFURLTaskLog.h
//  HMSSetupApp
//
//  Created by YunSL on 2017/11/21.
//  Copyright © 2017年 HMS. All rights reserved.
//

#import "SFURLRequest.h"
#import "SFURLResponse.h"

@interface SFURLTaskLog : NSObject
@property (nonatomic,strong) NSDate *sendDate;
@property (nonatomic,strong) NSDate *completeDate;
@property (nonatomic,strong) SFURLRequest *request;
@property (nonatomic,strong) SFURLResponse *response;
@end
