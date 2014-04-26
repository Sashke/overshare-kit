//
// Created by Sashke on 10/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKVkComUtility.h"
#import "OSKShareableContentItem.h"
#import "VKSdk.h"
#import "VKBatchRequest+initWithArray.h"


@implementation OSKVkComUtility
+(void)postContentItem:(OSKMicroblogPostContentItem *)contentItem
            completion:(void(^)(BOOL success, NSError *error))completion{
    NSString *stringUserId = [VKSdk getAccessToken].userId;
    NSInteger userId=[stringUserId integerValue];
    if (contentItem.images!=nil && contentItem.images.count>0)
    {
        NSMutableArray *requests=[NSMutableArray new];
        for (UIImage *image in contentItem.images){
            VKRequest *request=[VKApi uploadWallPhotoRequest:image
                                                  parameters:[VKImageParameters pngImage]
                                                      userId:userId
                                                     groupId:0];
            [requests addObject:request];
        }
        VKBatchRequest *batch= [[VKBatchRequest alloc] initWithArrayOfRequests:requests];
        [batch executeWithResultBlock:^(NSArray *responses) {
            NSMutableArray *photosAttachments=[NSMutableArray new];
            for (VKResponse *resp in responses){
                VKPhoto *photoInfo=[(VKPhotoArray *)resp.parsedModel objectAtIndex:0];
                [photosAttachments addObject:[NSString stringWithFormat:@"photo%@_%@",photoInfo.owner_id, photoInfo.id]];
            }
            if (contentItem.canonicalURL)
                [photosAttachments addObject:contentItem.canonicalURL];
            VKRequest *post=[[VKApi wall] post:@{VK_API_MESSAGE : contentItem.text,
                    VK_API_ATTACHMENTS : [photosAttachments componentsJoinedByString:@","],
                    VK_API_FRIENDS_ONLY : @(0),
                    VK_API_OWNER_ID : [NSString stringWithFormat:@"%d",userId]}];
            [post executeWithResultBlock:^(VKResponse *response) {
                if (completion)
                    completion(YES, nil);
            } errorBlock:^(NSError *error) {
                NSLog(@"Error: %@", error);
                if (completion)
                    completion(NO, error);
            }];
        } errorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
            if (completion)
                completion(NO, error);
        }];
    }
    else{
        VKRequest *post;
        if (contentItem.canonicalURL)
            post=[[VKApi wall] post:@{VK_API_MESSAGE : contentItem.text,
                    VK_API_ATTACHMENTS: contentItem.canonicalURL,
                    VK_API_FRIENDS_ONLY : @(0),
                    VK_API_OWNER_ID : [NSString stringWithFormat:@"%d",userId]}];
        else
            post=[[VKApi wall] post:@{VK_API_MESSAGE : contentItem.text,
                    VK_API_FRIENDS_ONLY : @(0),
                    VK_API_OWNER_ID : [NSString stringWithFormat:@"%d",userId]}];
        [post executeWithResultBlock:^(VKResponse *response) {
            if (completion)
                completion(YES, nil);
        } errorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
            if (completion)
                completion(NO, error);

        }];
    }
}
@end