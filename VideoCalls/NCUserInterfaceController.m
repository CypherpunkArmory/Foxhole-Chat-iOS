//
//  NCUserInterfaceController.m
//  VideoCalls
//
//  Created by Ivan Sein on 28.02.18.
//  Copyright © 2018 struktur AG. All rights reserved.
//

#import "NCUserInterfaceController.h"

#import "AFNetworking.h"
#import "AuthenticationViewController.h"
#import "LoginViewController.h"
#import "NCConnectionController.h"
#import "NCSettingsController.h"

@interface NCUserInterfaceController () <LoginViewControllerDelegate, AuthenticationViewControllerDelegate, CallViewControllerDelegate>
{
    LoginViewController *_loginViewController;
    AuthenticationViewController *_authViewController;
    CallViewController *_callViewController;
}

@end

@implementation NCUserInterfaceController

+ (NCUserInterfaceController *)sharedInstance
{
    static dispatch_once_t once;
    static NCUserInterfaceController *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityHasChanged:) name:NCNetworkReachabilityHasChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presentCallsViewController
{
    [self.mainTabBarController setSelectedIndex:0];
}

- (void)presentContactsViewController
{
    [self.mainTabBarController setSelectedIndex:1];
}

- (void)presentSettingsViewController
{
    [self.mainTabBarController setSelectedIndex:2];
}

- (void)presentLoginViewController
{
    _loginViewController = [[LoginViewController alloc] init];
    _loginViewController.delegate = self;
    [self.mainTabBarController presentViewController:_loginViewController animated:YES completion:nil];
}

- (void)presentAuthenticationViewController
{
    _authViewController = [[AuthenticationViewController alloc] init];
    _authViewController.delegate = self;
    _authViewController.serverUrl = [NCSettingsController sharedInstance].ncServer;
    [self.mainTabBarController presentViewController:_authViewController animated:YES completion:nil];
}

- (void)presentAlertForPushNotification:(NCPushNotification *)pushNotification
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[pushNotification bodyForRemoteAlerts]
                                 message:@"Do you want to join this call?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *joinButton = [UIAlertAction
                                 actionWithTitle:@"Join call"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:pushNotification forKey:@"pushNotification"];
                                     [[NSNotificationCenter defaultCenter] postNotificationName:NCPushNotificationJoinCallAcceptedNotification
                                                                                         object:self
                                                                                       userInfo:userInfo];
                                 }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    [alert addAction:joinButton];
    [alert addAction:cancelButton];
    
    // Do not show join call dialog until we don't handle 'hangup current call'/'join new one' properly.
    if (self.mainTabBarController.presentedViewController != _callViewController) {
        [self.mainTabBarController dismissViewControllerAnimated:NO completion:nil];
    }

    [self.mainTabBarController presentViewController:alert animated:YES completion:nil];
}

- (void)presentAlertViewController:(UIAlertController *)alertViewController
{
    [self.mainTabBarController presentViewController:alertViewController animated:YES completion:nil];
}

- (void)presentCallViewController:(CallViewController *)callViewController
{
    _callViewController = callViewController;
    _callViewController.delegate = self;
    [self.mainTabBarController presentViewController:_callViewController animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)networkReachabilityHasChanged:(NSNotification *)notification
{
    AFNetworkReachabilityStatus status = [[notification.userInfo objectForKey:kNCNetworkReachabilityKey] intValue];
    NSLog(@"Network Status:%ld", (long)status);
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewControllerDidFinish:(LoginViewController *)viewController
{
    [self.mainTabBarController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AuthenticationViewControllerDelegate

- (void)authenticationViewControllerDidFinish:(AuthenticationViewController *)viewController
{
    [self.mainTabBarController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CallViewControllerDelegate

- (void)callViewControllerDidFinish:(CallViewController *)viewController {
    if (![viewController isBeingDismissed]) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
