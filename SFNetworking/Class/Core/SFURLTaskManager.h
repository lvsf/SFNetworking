//
//  SFURLTaskManager.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"
#import "SFHTTPTask.h"
#import "SFURLTaskGroup.h"

@interface SFURLTaskManager : NSObject

@property (nonatomic,assign,readonly) NSInteger requestingTasksNumber;

- (void)sendTask:(SFURLTask *)task;
- (void)sendTaskGroup:(SFURLTaskGroup *)taskGroup;
- (void)cancelAllTasks;

- (void)reloadTask:(SFHTTPTask *)task;
- (void)loadMoreTask:(SFHTTPTask *)task;

- (SFURLTaskManager *(^)(SFURLTask *))sendTask;

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;
- (SFURLTask *)objectForKeyedSubscript:(id)key;

@end
