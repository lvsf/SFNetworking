//
//  SFRequestPage.h
//  Pocket
//
//  Created by YunSL on 2019/4/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SFHTTPRequestPageProtocol <NSObject>
@required
- (NSDictionary *)requestPageParameters;
@end

@interface SFRequestPage : NSObject<SFHTTPRequestPageProtocol>
@property (nonatomic,copy) NSString *pageKey;
@property (nonatomic,copy) NSString *pageKeyForResponseSerializer;
@property (nonatomic,copy) NSString *pageTotalKey;
@property (nonatomic,copy) NSString *pageSizeKey;
@end

NS_ASSUME_NONNULL_END
