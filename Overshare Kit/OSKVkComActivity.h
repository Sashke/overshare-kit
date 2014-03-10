//
// Created by Sashke on 09/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKActivity_GenericAuthentication.h"
#import "OSKActivity.h"
#import "VKSdk.h"
#import "OSKMicrobloggingActivity.h"


@interface OSKVkComActivity : OSKActivity <OSKActivity_GenericAuthentication, VKSdkDelegate, OSKMicrobloggingActivity>
@property(nonatomic, copy) OSKActivityCompletionHandler activityCompletionHandler;

@end