//
//  SFURLTaskPage.m
//  SFNetworking
//
//  Created by YunSL on 2017/10/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTaskPage.h"

@implementation SFURLTaskPage
@synthesize size = _size;
@synthesize firstPage = _firstPage;
@synthesize currentPage = _currentPage;
@synthesize nextPage = _nextPage;
@synthesize lastPage = _lastPage;
@synthesize requestPage = _requestPage;
@synthesize pageTotal = _pageTotal;
@synthesize next = _next;
@synthesize lastLoadOperation = _lastLoadOperation;

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
        self.size = 25;
        self.pageType = SFURLTaskPageTypeIndex;
    }
    return self;
}

- (void)reset {
    _lastLoadOperation = SFURLTaskPageOperationFirstLoad;
    _requestPage = self.firstPage;
    _currentPage = nil;
    _nextPage = nil;
    _next = NO;
    _pageTotal = 0;
}

- (void)reload {
    _lastLoadOperation = SFURLTaskPageOperationReload;
    _requestPage = self.firstPage;
}

- (void)loadNext {
    _lastLoadOperation = SFURLTaskPageOperationLoadMore;
    _requestPage = self.nextPage?:self.firstPage;
}

- (void)updateWithResponseObject:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = responseObject;
        _lastPage = _currentPage;
        _currentPage = _requestPage;
        _next = NO;
        if ([responseDict.allKeys containsObject:self.pageSizeKey]) {
            _size = [responseDict[self.pageSizeKey] integerValue];
        }
        if ([responseDict.allKeys containsObject:self.pageTotalKey]) {
            _pageTotal = [responseDict[self.pageTotalKey] integerValue];
            switch (self.pageType) {
                case SFURLTaskPageTypeIndex:
                {
                    _nextPage = @([_currentPage integerValue] + 1);
                    if ([_currentPage integerValue] < _pageTotal - 1) {
                        _next = YES;
                    }
                    else {
                        _next = NO;
                    }
                }
                    break;
                case SFURLTaskPageTypeTimestamp:
                {
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (NSDictionary *)parametersForRequest {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (_pageKey && _requestPage) {
        [parameters setObject:_requestPage forKey:_pageKey];
    }
    if (_pageSizeKey) {
        [parameters setObject:@(_size) forKey:_pageSizeKey];
    }
    return parameters.copy;
}

- (void)setFirstPage:(id)firstPage {
    _firstPage = firstPage;
    if (_requestPage == nil) {
        _requestPage = firstPage;
    }
}

@end
