//
//  SFRequestTaskConfiguration.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestSerializer.h"
#import "SFResponseSerializer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestTaskConfiguration : NSObject<NSCopying>
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSDictionary *builtinParameters;
@property (nonatomic,copy) NSArray<NSString *> *acceptableContentTypes;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,assign) BOOL record;
- (SFRequestTaskConfiguration *(^)(BOOL record))record_;
- (SFRequestTaskConfiguration *(^)(NSTimeInterval timeoutInterval))timeoutInterval_;
- (SFRequestTaskConfiguration *)duplicate;
@end

NS_ASSUME_NONNULL_END
