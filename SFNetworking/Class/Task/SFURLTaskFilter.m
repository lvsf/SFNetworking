//
//  SFURLTaskFilter.m
//  SFNetworking
//
//  Created by YunSL on 2017/12/14.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskFilter.h"

@implementation SFURLTaskFilter
@synthesize shouldSend = _shouldSend;
@synthesize shouldComplete = _shouldComplete;

- (SFURLError *)task:(SFURLTask *)task shouldSendWithRequest:(SFURLRequest *)request {
    return nil;
}

- (SFURLError *)task:(SFURLTask *)task shouldCompleteResponse:(SFURLResponse *)response {
    return nil;
}

@end
