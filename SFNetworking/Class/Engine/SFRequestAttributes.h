//
//  SFRequestAttributes.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/24.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFRequestTask,SFResponse;

typedef NS_ENUM(NSInteger,SFRequestKind) {
    SFRequestKindHTTP = 0,
    SFRequestKindLoad,
    SFRequestKindSocket
};

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestAttributes : NSObject
@property (nonatomic,assign) SFRequestKind kind;
@property (nonatomic,copy) NSString *taskURL;
@property (nonatomic,copy) NSDictionary *parameters;
@property (nonatomic,copy) NSDictionary *HTTPHeaders;
@property (nonatomic,copy) NSSet<NSString *> *acceptableContentTypes;
@property (nonatomic,copy,nullable) void (^complete)(SFRequestTask *requestTask, SFResponse *response);
@end

NS_ASSUME_NONNULL_END
