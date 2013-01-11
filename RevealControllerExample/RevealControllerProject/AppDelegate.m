/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "AppDelegate.h"

#import "SWRevealViewController.h"
#import "FrontViewController.h"
#import "RearViewController.h"

@interface AppDelegate()<SWRevealViewControllerDelegate>
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window = window;
	
	FrontViewController *frontViewController = [[FrontViewController alloc] init];
	RearViewController *rearViewController = [[RearViewController alloc] init];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
	
	SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:navigationController];
    revealController.delegate = self;
    
	self.viewController = revealController;
	
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	return YES;
}


- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}


- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController willRevealRearViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController didRevealRearViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController willHideRearViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController didHideRearViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController willShowFrontViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController didShowFrontViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController willHideFrontViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}

- (void)revealController:(SWRevealViewController *)revealController didHideFrontViewController:(UIViewController *)viewController
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), viewController);
}










@end