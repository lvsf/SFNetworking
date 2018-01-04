//
//  ZSHTTPTaskConfiguration.h
//  SFNetworking
//
//  Created by YunSL on 2018/1/2.
//  Copyright © 2018年 YunSL. All rights reserved.
//

#import "SFHTTPTask.h"

@interface ZSHTTPTaskConfiguration : NSObject<SFURLTaskRequestSerializerProtocol,SFURLTaskResponseSerializerProtocol,SFURLTaskFilterProtocol,SFURLTaskInteractionProtocol,SFURLTaskDebugDelegate>

@end
