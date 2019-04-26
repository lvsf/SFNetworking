//
//  SFRequestSesssion.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/19.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequestTask.h"
#import "SFRequestGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestSesssion : NSObject
@property (nonatomic,copy) NSString *sessionName;
@property (nonatomic,assign) BOOL cancelTaskAutomatic;
@property (nonatomic,copy,readonly) NSArray<SFRequestTask *> *tasks;
- (void)cancelAllTasks;
- (void)cancelTaskGroup:(SFRequestGroup *)requestTaskGroup;
- (void)sendTask:(SFRequestTask *)requestTask;
- (void)sendTaskGroup:(SFRequestGroup *)requestTaskGroup;
@end

NS_ASSUME_NONNULL_END
