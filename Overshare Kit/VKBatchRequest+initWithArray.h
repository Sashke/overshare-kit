//
// Created by Sashke on 09/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKBatchRequest.h"

@interface VKBatchRequest (initWithArray)
- (instancetype)initWithArrayOfRequests:(NSMutableArray *)requests;
@end