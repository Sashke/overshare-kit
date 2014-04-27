//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EDAMNote;


@interface OSKEvernoteUtility : NSObject
+ (NSMutableArray *)createResourcesForImages:(NSArray *)images;

+ (EDAMNote *)createNoteWithTitle:(NSString *)title text:(NSString *)text images:(NSArray *)images;
@end