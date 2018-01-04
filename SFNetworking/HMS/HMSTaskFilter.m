//
//  HMSTaskFilter.m
//  SFNetworking
//
//  Created by YunSL on 2017/12/15.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "HMSURLTaskFilter.h"

@implementation HMSURLTaskFilter

- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request {
    return nil;
}

- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response {
    return nil;
}

@end
