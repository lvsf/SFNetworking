//
//  SFRequestPage.h
//  Pocket
//
//  Created by YunSL on 2019/4/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SFRequestPageType) {
    SFRequestPageTypeIndex = 0,
    SFRequestPageTypeTimestamp,
};

NS_ASSUME_NONNULL_BEGIN

@protocol SFRequestPageProtocol <NSObject>
@required
- (NSDictionary *)parametersForRequest;
- (void)updateWithResponseObject:(id)responseObject;
@end

@interface SFRequestPage : NSObject<SFRequestPageProtocol>

@property (nonatomic,assign) SFRequestPageType pageType;
@property (nonatomic,assign) NSInteger size;
@property (nonatomic,strong) id firstPage;
@property (nonatomic,strong,readonly) id currentPage;
@property (nonatomic,strong,readonly) id lastPage;
@property (nonatomic,strong,readonly) id nextPage;
@property (nonatomic,strong,readonly) id requestPage;
@property (nonatomic,assign,readonly) BOOL next;
@property (nonatomic,assign,readonly) NSInteger pageTotal;

@property (nonatomic,copy) NSString *requestPageKey;
@property (nonatomic,copy) NSString *requestPageSizeKey;
@property (nonatomic,copy) NSString *responsePageObjectKey;
@property (nonatomic,copy) NSString *responsePageKey;
@property (nonatomic,copy) NSString *responsePageSizeKey;
@property (nonatomic,copy) NSString *responsePageTotalKey;
@property (nonatomic,copy) NSString *responsePageEndKey;
@property (nonatomic,copy) NSString *responseNextPageKey;

- (void)reload;
- (void)loadNext;

@end

NS_ASSUME_NONNULL_END
