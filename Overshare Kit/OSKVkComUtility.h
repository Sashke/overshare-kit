//
// Created by Sashke on 10/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSKMicroblogPostContentItem;


@interface OSKVkComUtility : NSObject
+(void)postContentItem:(OSKMicroblogPostContentItem *)contentItem
        completion:(void(^)(BOOL success, NSError *error))completion;
@end