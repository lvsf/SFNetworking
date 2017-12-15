//
//  SFURLTaskPage.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"

typedef NS_ENUM(NSInteger,SFURLTaskPageType) {
    SFURLTaskPageTypeIndex = 0,
    SFURLTaskPageTypeTimestamp,
};

@interface SFURLTaskPage : NSObject<SFURLTaskPageProtocol>
@property (nonatomic,assign) SFURLTaskPageType pageType;
@property (nonatomic,copy) NSString *pageKey;
@property (nonatomic,copy) NSString *pageTotalKey;
@property (nonatomic,copy) NSString *pageSizeKey;
@end
