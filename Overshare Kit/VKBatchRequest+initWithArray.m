//
// Created by Sashke on 09/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "VKBatchRequest+initWithArray.h"


@implementation VKBatchRequest (initWithArray)
- (instancetype)initWithArrayOfRequests:(NSMutableArray *)requests{
    self=[super init];
    _requests=requests;
    return self;
}
@end