//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKEvernoteActivity.h"
#import "EvernoteSDK.h"
#import "OSKPresentationManager.h"
#import "OSKShareableContentItem.h"
#import "OSKEvernoteUtility.h"

@interface OSKEvernoteActivity()
@property (strong, nonatomic) NSTimer *authenticationTimeoutTimer;
@property (assign, nonatomic) BOOL authenticationTimedOut;
@property (copy, nonatomic) OSKGenericAuthenticationCompletionHandler completionHandler;
@end

@implementation OSKEvernoteActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
    }
    return self;
}

#pragma mark - Generic Authentication

- (BOOL)isAuthenticated {
    return [EvernoteSession sharedSession].isAuthenticated;
}

- (void)authenticate:(OSKGenericAuthenticationCompletionHandler)completion {
    [self setCompletionHandler:completion];
    [self startAuthenticationTimeoutTimer];

    EvernoteSession *session=[EvernoteSession sharedSession];
    OSKPresentationManager* presentationManager=[OSKPresentationManager sharedInstance];
    [session authenticateWithViewController:presentationManager.presentingViewController
                          completionHandler:^(NSError *error) {
                              __weak OSKEvernoteActivity *weakSelf = self;
                              if (error || !session.isAuthenticated){
                                  if (self.completionHandler && !weakSelf.authenticationTimedOut){
                                      [self cancelAuthenticationTimeoutTimer];
                                      self.completionHandler(NO,error);
                                  }
                              }else{
                                      [self cancelAuthenticationTimeoutTimer];
                                      self.completionHandler(YES,error);
                              }
                          }];

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
        __weak OSKEvernoteActivity *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"OSKEvernoteActivity" code:408 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Evernote authentication timed out."}];
            weakSelf.completionHandler(NO, error);
        });
    }
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_TextEditing;
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSString *)activityType {
    return OSKActivityType_API_Evernote;
}

+ (NSString *)activityName {
    return @"Evernote";
}

+(UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-evernoteIcon-60@2x.png"];
    } else {
        image = [UIImage imageNamed:@"osk-evernoteIcon-76.png"];
    }
    return image;
}

+ (NSString *)horizontalPullIconName {
    return @"shk-evernote.png";
}

+ (UIImage *)settingsIcon {
    return [UIImage imageNamed:@"osk-evernoteIcon-29@2x.png"];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_Generic;
}

+ (BOOL)requiresApplicationCredential {
    return NO;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_None;
}

- (BOOL)isReadyToPerform {
    return [EvernoteSession sharedSession].isAuthenticated;
}


- (void)performActivity:(OSKActivityCompletionHandler)completion {
    self.activityCompletionHandler = completion;
    OSKTextEditingContentItem *item = (OSKTextEditingContentItem *)self.contentItem;
    EDAMNote *newNote=[OSKEvernoteUtility createNoteWithTitle:item.title
                                                         text:item.text
                                                    images:item.images];
    [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
        if (self.activityCompletionHandler)
            self.activityCompletionHandler(self, YES, nil);
    } failure:^(NSError *error) {
        if (self.activityCompletionHandler)
            self.activityCompletionHandler(self, NO, error);
    }];
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

@end