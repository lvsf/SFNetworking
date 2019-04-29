//
//  SFRequestPage.m
//  Pocket
//
//  Created by YunSL on 2019/4/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestPage.h"

@implementation SFRequestPage

- (instancetype)init {
    if (self = [super init]) {
        _pageType = SFRequestPageTypeIndex;
    }
    return self;
}

- (void)reload {
    _requestPage = _firstPage;
}

- (void)loadNext {
    if (_nextPage) {
        _requestPage = _nextPage;
    }
}

- (NSDictionary *)parametersForRequest {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (_requestPageKey && _requestPage) {
        [parameters setObject:_requestPage forKey:_requestPageKey];
    }
    if (_requestPageSizeKey && _size >= 0) {
        [parameters setObject:@(_size) forKey:_requestPageSizeKey];
    }
    return parameters.copy;
}

- (void)updateWithResponseObject:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        _lastPage = _currentPage;
        _next = NO;
        _nextPage = nil;
        NSDictionary *pageObject = responseObject;
        if (_responsePageObjectKey) {
            if ([_responsePageObjectKey containsString:@"."]) {
                pageObject = [pageObject valueForKey:_responsePageObjectKey];
            }
            else if ([pageObject.allKeys containsObject:_responsePageObjectKey]) {
                pageObject = [pageObject objectForKey:_responsePageObjectKey];
            }
        }
        
        if (_responsePageSizeKey) {
            if ([_responsePageSizeKey containsString:@"."]) {
                _size = [[pageObject valueForKey:_responsePageSizeKey] integerValue];
            }
            else if ([pageObject.allKeys containsObject:_responsePageSizeKey]) {
                _size = [[pageObject objectForKey:_responsePageSizeKey] integerValue];
            }
        }
        if (_responsePageTotalKey) {
            if ([_responsePageTotalKey containsString:@"."]) {
                _pageTotal = [[pageObject valueForKey:_responsePageTotalKey] integerValue];
            }
            else if ([pageObject.allKeys containsObject:_responsePageTotalKey]) {
                _pageTotal = [[pageObject objectForKey:_responsePageTotalKey] integerValue];
            }
        }
        
        _currentPage = nil;
        if (_responsePageKey) {
            if ([_responsePageKey containsString:@"."]) {
                _currentPage = [pageObject valueForKey:_responsePageKey];
            }
            else if ([pageObject.allKeys containsObject:_responsePageKey]) {
                _currentPage = [pageObject objectForKey:_responsePageKey];
            }
        }
        if (_currentPage == nil) {
            _currentPage = _requestPage;
        }
        
        if (_responseNextPageKey) {
            if ([_responseNextPageKey containsString:@"."]) {
                _nextPage = [pageObject valueForKey:_responseNextPageKey];
            }
            else if ([pageObject.allKeys containsObject:_responseNextPageKey]) {
                _nextPage = [pageObject objectForKey:_responseNextPageKey];
            }
        }
        id nextValue = nil;
        if (_responsePageEndKey) {
            if ([_responsePageEndKey containsString:@"."]) {
                nextValue = [pageObject valueForKey:_responsePageEndKey];
            }
            else if ([pageObject.allKeys containsObject:_responsePageEndKey]) {
                nextValue = [pageObject objectForKey:_responsePageEndKey];
            }
        }
        switch (_pageType) {
            case SFRequestPageTypeIndex:{
                if (nextValue) {
                    _next = [nextValue boolValue];
                }
                else {
                    _next = ([_currentPage integerValue] < _pageTotal);
                }
                if (_next && _nextPage == nil) {
                    _nextPage = @([_currentPage integerValue] + 1);
                }
            }
                break;
            case SFRequestPageTypeTimestamp:{
                if (nextValue) {
                    _next = [nextValue boolValue];
                }
                else {
                    _next = YES;
                }
                if (_next && _nextPage == nil) {
                    // 下一页的时间戳
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)setFirstPage:(id)firstPage {
    _firstPage = firstPage;
    if (_currentPage == nil) {
        _currentPage = firstPage;
    }
    if (_requestPage == nil) {
        _requestPage = firstPage;
    }
}

@end
