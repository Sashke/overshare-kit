//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk.h"


@interface OSKGenericAccountViewController : UITableViewController<VKSdkDelegate>
- (instancetype)initWithActivityClass:(Class)activityClass;
@end