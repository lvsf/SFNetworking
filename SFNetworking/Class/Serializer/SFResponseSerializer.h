//
//  SFResponseSerializer.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SFResponseSerializerType) {
    SFResponseSerializerTypeHTTP = 0,
    SFResponseSerializerTypeJSON,
    SFResponseSerializerTypeXML,
    SFResponseSerializerTypePropertyList
};

NS_ASSUME_NONNULL_BEGIN

@class SFRequestTask,SFResponse;
@protocol SFResponseSerializerProtocol <NSObject>
@required
@property (nonatomic,copy) NSArray<NSString *> *codeKeys;
@property (nonatomic,copy) NSArray<NSString *> *messageKeys;
@property (nonatomic,copy) NSArray<NSNumber *> *successStatusVaules;
@property (nonatomic,copy) BOOL (^successReformer)(SFResponse *response, id responseObject);
@property (nonatomic,copy) NSString *_Nullable (^messageReformer)(SFResponse *response, id responseObject);

- (SFResponse *)responseWithResponseObject:(id)responseObject error:(NSError * _Nullable)error;
@end

@interface SFResponseSerializer : NSObject<SFResponseSerializerProtocol>
@property (nonatomic,assign) SFResponseSerializerType serializerType;
@end

NS_ASSUME_NONNULL_END
