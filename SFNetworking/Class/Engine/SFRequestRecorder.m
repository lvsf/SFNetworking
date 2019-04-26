//
//  SFRequestRecorder.m
//  SFNetworking
//
//  Created by YunSL on 2019/3/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import "SFRequestRecorder.h"
#import "SFRequestSesssion.h"

@implementation SFRequestRecorder

- (void)recordForRequestTaskSend:(SFRequestTask *)requestTask {
}

- (void)recordForRequestTaskSendComplete:(SFRequestTask *)requestTask withResponse:(SFResponse *)response {
    NSString *method = SFRequestMethodDescription(requestTask.request.method);
    NSTimeInterval cost = 0;
    if (requestTask.requestDate && requestTask.responseDate) {
        cost = [requestTask.responseDate timeIntervalSinceDate:requestTask.requestDate];
    }
    NSString *taskURL = requestTask.requestAttributes.taskURL;
    if (taskURL == nil) {
        taskURL = requestTask.request.taskURL?:requestTask.request.pathURL;
    }
    NSString *success = response.success?@"success":@"failure";
    NSString *message = [NSString stringWithFormat:@"\n====== [%@] %@ \nsession:<%@> %@ URL %@ [%@] \nparams:%@ \nhead:%@ \ncode:%@ \nstatus:%@ \nmessage:%@ \nrequestCost:%.5fs \nresponseObject:%@",
                         NSStringFromClass(self.class),
                         [requestTask.requestDate descriptionWithLocale:[NSLocale currentLocale]],
                         requestTask.session.sessionName,
                         method,
                         taskURL,
                         success,
                         requestTask.requestAttributes.parameters?:requestTask.request.parameters,
                         requestTask.requestAttributes.HTTPHeaders?:requestTask.request.HTTPHeaders,
                         @(response.code),
                         response.status,
                         response.message,
                         cost,
                         response.responseObject];
    NSLog(@"%@\n======",message);
}


@end
