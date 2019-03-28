//
//  SFRequestSerializer.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SFRequestSerializerType) {
    SFRequestSerializerTypeHTTP = 0,
    SFRequestSerializerTypeJSON,
    SFRequestSerializerTypeXML,
    SFRequestSerializerTypePropertyList
};

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestSerializerProtocol <NSObject>
@end

@interface SFRequestSerializer : NSObject<SFRequestSerializerProtocol>
@property (nonatomic,assign) SFRequestSerializerType serializerType;
@end

NS_ASSUME_NONNULL_END
