//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKGenericAccountViewController.h"
#import "OSKPresentationManager.h"
#import "PocketAPI.h"
#import "EvernoteSDK.h"
#import "OSKActivitiesManager.h"
#import "OSKApplicationCredential.h"
#import "OSKAlertView.h"

@interface OSKGenericAccountViewController()
@property (strong, nonatomic) Class activityClass;
@end

@implementation OSKGenericAccountViewController

- (instancetype)initWithActivityClass:(Class)activityClass{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = [activityClass activityName];
        self.activityClass=activityClass;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
    UIColor *bgColor = [presentationManager color_groupedTableViewBackground];
    self.view.backgroundColor = bgColor;
    self.tableView.backgroundColor = bgColor;
    self.tableView.backgroundView.backgroundColor = bgColor;
    self.tableView.separatorColor = presentationManager.color_separators;
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
        UIColor *bgColor = [presentationManager color_groupedTableViewCells];
        cell.backgroundColor = bgColor;
        cell.backgroundView.backgroundColor = bgColor;
        cell.textLabel.textColor = [presentationManager color_action];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = presentationManager.color_cancelButtonColor_BackgroundHighlighted;
        cell.tintColor = presentationManager.color_action;
        UIFontDescriptor *descriptor = [[OSKPresentationManager sharedInstance] normalFontDescriptor];
        if (descriptor) {
            [cell.textLabel setFont:[UIFont fontWithDescriptor:descriptor size:17]];
        }
    }

    NSString *title = nil;
    if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_Pocket]){
        if ([[PocketAPI sharedAPI] isLoggedIn]) {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignOut];
        } else {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignIn];
        }
    }else if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_VKCom]){
        if ([VKSdk wakeUpSession]) {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignOut];
        } else {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignIn];
        }
    }else if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_Evernote]){
        if ([[EvernoteSession sharedSession] isAuthenticated]) {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignOut];
        } else {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignIn];
        }
    }

    cell.textLabel.text = title;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_Pocket]){
        [self didSelectPocket];
    } else if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_VKCom]){
       [self didSelectVkCom];
    } else if ([[self.activityClass activityType] isEqualToString:OSKActivityType_API_Evernote]){
        [self didSelectEvernote];
    }
}

#pragma mark - Activities Authorization

- (void)didSelectPocket {
    if ([[PocketAPI sharedAPI] isLoggedIn]) {
        [[PocketAPI sharedAPI] logout];
        [self.tableView reloadData];
    } else {
        __weak OSKGenericAccountViewController *weakSelf = self;
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)didSelectVkCom {
    if ([VKSdk wakeUpSession]){
        [VKSdk forceLogout];
        [self.tableView reloadData];
    } else {
        OSKApplicationCredential *appCredential = [[OSKActivitiesManager sharedInstance] applicationCredentialForActivityType:[self.activityClass activityType]];
        [VKSdk initializeWithDelegate:self andAppId:appCredential.applicationKey];
        [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL] revokeAccess:YES forceOAuth:YES inApp:YES];
    }
}

- (void)didSelectEvernote {
    if ([EvernoteSession sharedSession].isAuthenticated){
        [[EvernoteSession sharedSession] logout];
        [self.tableView reloadData];
    } else {
        EvernoteSession *session=[EvernoteSession sharedSession];
        [session authenticateWithViewController:self
                              completionHandler:^(NSError *error) {
                                  __weak OSKGenericAccountViewController *weakSelf = self;
                                  if (error || !session.isAuthenticated){
                                      [weakSelf showUnableToSignInAlert];
                                  }else{
                                      [weakSelf.tableView reloadData];
                                  }
                              }];
    }
}

#pragma mark - VK SDK

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self.tableView reloadData];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [self showUnableToSignInAlert];
}


- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
   [self.tableView reloadData];
}

#pragma mark - Convenience

- (void)showUnableToSignInAlert {
    OSKPresentationManager *presMan = [OSKPresentationManager sharedInstance];
    OSKAlertViewButtonItem *okay = [OSKAlertView okayItem];
    NSString *title = [presMan localizedText_UnableToSignIn];
    NSString *message = [presMan localizedText_PleaseDoubleCheckYourUsernameAndPasswordAndTryAgain];
    OSKAlertView *alert = [[OSKAlertView alloc] initWithTitle:title message:message cancelButtonItem:okay otherButtonItems:nil];
    [alert show];
}
@end