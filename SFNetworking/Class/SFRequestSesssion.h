//
//  SFRequestSesssion.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"
#import "SFRequestTask.h"
#import "SFRequestTaskConfiguration.h"
#import "SFRequestGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestSesssion : NSObject
@property (nonatomic,copy) NSString *sessionName;
@property (nonatomic,assign) BOOL cancelTaskAutomatic;
@property (nonatomic,copy,readonly) NSArray<SFRequestTask *> *tasks;
- (void)cancelAllTasks;
- (void)cancelTask:(SFRequestTask *)requestTask;
- (void)sendTask:(SFRequestTask *)requestTask;
- (void)sendTaskGroup:(SFRequestGroup *)requestTaskGroup;
- (void)cancelTaskGroup:(SFRequestGroup *)requestTaskGroup;
@end

NS_ASSUME_NONNULL_END
