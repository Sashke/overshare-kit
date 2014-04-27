//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSKActivity_GenericAuthentication.h"
#import "OSKActivity.h"


@interface OSKEvernoteActivity : OSKActivity<OSKActivity_GenericAuthentication>
@property(nonatomic, copy) OSKActivityCompletionHandler activityCompletionHandler;
@end