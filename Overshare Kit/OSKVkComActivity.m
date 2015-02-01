//
// Created by Sashke on 09/03/14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <GoogleOpenSource/GoogleOpenSource.h>
#import "OSKVkComActivity.h"
#import "OSKShareableContentItem.h"
#import "OSKPresentationManager.h"
#import "OSKApplicationCredential.h"
#import "OSKActivitiesManager.h"
#import "NSString+OSKEmoji.h"
#import "OSKVkComUtility.h"

@interface OSKVkComActivity()
@property (strong, nonatomic) NSTimer *authenticationTimeoutTimer;
@property (assign, nonatomic) BOOL authenticationTimedOut;
@property (copy, nonatomic) OSKGenericAuthenticationCompletionHandler completionHandler;
@end

@implementation OSKVkComActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
    }
    return self;
}

- (void)dealloc {

}

#pragma mark - Generic Authentication

-(BOOL)isAuthenticated {
    return [VKSdk wakeUpSession];
}

-(void)authenticate:(OSKGenericAuthenticationCompletionHandler)completion {
    [self setCompletionHandler:completion];
    [self startAuthenticationTimeoutTimer];
    OSKApplicationCredential *appCredential = [[OSKActivitiesManager sharedInstance] applicationCredentialForActivityType:[self.class activityType]];
    [VKSdk initializeWithDelegate:self andAppId:appCredential.applicationKey];
    [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL] revokeAccess:YES forceOAuth:YES inApp:YES];
}

#pragma mark - Methods for OSKActivity Subclasses

+(NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+(BOOL)isAvailable {
    return YES;
}

+(NSString *)activityType {
    return OSKActivityType_API_VKCom;
}

+(NSString *)activityName {
    return @"Vk.com";
}

+(UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image=nil;
    if (idiom == UIUserInterfaceIdiomPhone)
        image=[UIImage imageNamed:@"VKCom-Icon-60.png"];
    else
        image=[UIImage imageNamed:@"VKCom-Icon-76.png"];
    return image;
}

+ (NSString *)horizontalPullIconName {
    return @"shk-vkcom.png";
}

+(UIImage *)settingsIcon {
    return [UIImage imageNamed:@"VKCom-Icon-29.png"];
}

+(OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_Generic;
}

+(BOOL)requiresApplicationCredential {
    return YES;
}

+(OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_ViewController_Microblogging;
}

-(BOOL)isReadyToPerform {
    return [VKSdk wakeUpSession];
}

-(void)performActivity:(OSKActivityCompletionHandler)completion {
    self.activityCompletionHandler = completion;
    OSKMicroblogPostContentItem *contentItem=(OSKMicroblogPostContentItem *)self.contentItem;
    [OSKVkComUtility postContentItem:contentItem completion:^(BOOL success, NSError *error) {
        if (self.activityCompletionHandler)
            self.activityCompletionHandler(self, success, error);
    }];
}

+(BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - VK SDK

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    OSKPresentationManager *manager=[OSKPresentationManager sharedInstance];
    [manager.presentingViewController presentViewController:controller animated:YES completion:nil];
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    OSKPresentationManager *manager=[OSKPresentationManager sharedInstance];
    [vc presentIn:manager.presentingViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authenticate:self.completionHandler];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
    __weak OSKVkComActivity *weakSelf = self;
    if (self.completionHandler && !weakSelf.authenticationTimedOut) {
        [weakSelf cancelAuthenticationTimeoutTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionHandler(YES, nil);
        });
    }
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Authentication Timeout

- (void)startAuthenticationTimeoutTimer {
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:60*2]
                                              interval:0
                                                target:self
                                              selector:@selector(authenticationTimedOut:)
                                              userInfo:nil
                                               repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)cancelAuthenticationTimeoutTimer {
    [_authenticationTimeoutTimer invalidate];
    _authenticationTimeoutTimer = nil;
}

- (void)authenticationTimedOut:(NSTimer *)timer {
    [self setAuthenticationTimedOut:YES];
    if (self.completionHandler) {
        __weak OSKVkComActivity *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"OSKVkComActivity" code:408 userInfo:@{NSLocalizedFailureReasonErrorKey:@"VkCom authentication timed out."}];
            weakSelf.completionHandler(NO, error);
        });
    }
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return 6000;
}

- (NSInteger)maximumImageCount {
    return 40;
}

- (OSKSyntaxHighlighting)syntaxHighlighting {
    return OSKSyntaxHighlighting_Links;
}

- (NSInteger)maximumUsernameLength {
    return 300;
}

- (NSInteger)updateRemainingCharacterCount:(OSKMicroblogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities {
    NSString *text = contentItem.text;
    NSInteger composedLength = [text osk_lengthAdjustingForComposedCharacters];
    NSInteger remainingCharacterCount = [self maximumCharacterCount] - composedLength;
    return remainingCharacterCount;
}


@end