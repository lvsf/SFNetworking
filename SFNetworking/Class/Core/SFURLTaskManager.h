//
//  SFURLTaskManager.h
//  SFNetworking
//
//  Created by YunSL on 2017/10/28.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "SFURLTask.h"
#import "SFURLTaskGroup.h"
#import "SFURLTaskConfiguration.h"

@interface SFURLTaskManager : NSObject

@property (nonatomic,assign) NSInteger requestingsCount;

@property (nonatomic,strong) SFURLTaskConfiguration *configuration;

+ (void)setupTaskConfiguration:(void(^)(SFURLTaskConfiguration *config))configuration
                        forKey:(NSString *)key;
- (void)sendTask:(SFURLTask *)task configurationKey:(NSString *)key;
- (void)sendTask:(SFURLTask *)task;
- (void)sendTaskGroup:(SFURLTaskGroup *)taskGroup;
- (void)cancelAllTasks;

- (void)reloadTask:(SFURLTask *)task;
- (void)loadMoreTask:(SFURLTask *)task;

- (SFURLTaskManager *(^)(SFURLTask *))sendTask;

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;
- (SFURLTask *)objectForKeyedSubscript:(id)key;

@end
