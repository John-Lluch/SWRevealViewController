/* 
 
 Copyright (c) 2012, John Lluch-Zorrilla (joan.lluch@sweetwilliamsl.com)
 Inspired on a similar class by Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 * Neither the name of John Lluch, 'sweetwilliamsl.com' nor the names of its contributors may
 be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL JOHN LLUCH BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */


#import <UIKit/UIKit.h>

@class SWRevealViewController;
@protocol SWRevealViewControllerDelegate;

#pragma mark - SWRevealViewController Class

// Enum values for setFrontViewPosition:animated:
typedef enum
{
    // Left position, rear view is hidden behind front controller
	FrontViewPositionLeft,
    
    // Right possition, front view is presented right-offseted by rearViewRevealWidth
	FrontViewPositionRight,
    
    // Right most possition, front view is presented right-offseted by rearViewRevealWidth+rearViewRevealOverdraw
	FrontViewPositionRightMost,
    
    // Front controller is removed from view. Animated transitioning from this state will cause the same
    // effect than animating from FrontViewPositionRightMost. Use this instead of FrontViewPositionRightMost when
    // you intent to use a width equivalent to rearViewRevealWidth+rearViewRevealOverdraw on
    // the SWRevealViewController view, this will force the front controller to be removed
    // from the controller hierarchy.
    FrontViewPositionRightMostRemoved,
    
} FrontViewPosition;


@interface SWRevealViewController : UIViewController

// Object instance init and rear view setting
- (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;

// Rear view controller, can not be nil, passed on object initialization
@property (readonly, nonatomic) UIViewController *rearViewController;

// Front view controller, can be nil on initialization but must be supplied by the time its view is loaded
@property (strong, nonatomic) UIViewController *frontViewController;
- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

// Front view position, use this to set a particular position state on the controller
// On initialization it is set to FrontViewPositionLeft
@property (assign, nonatomic) FrontViewPosition frontViewPosition;
- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated;

// Toogles the current state of the controller between Left and Right, any right position becomes FrontViewPositionLeft,
// left possition becomes FrontViewPositionRight. Use setFrontViewPosition for a more accurate control
- (void)revealToggleAnimated:(BOOL)animated;

// The following method is meant to be directly connected to the action method of a button
// to perform user triggered postion change of the controller views. This is ussually added to a
// button on top-left of the frontViewController
- (void)revealToggle:(id)sender;

// The following method will provide a panGestureRecognizer suitable to be added to any view on the frontController
// in order to perform usual drag and swipe gestures on the frontViewController to reveal the rear view. This
// is usually added on the top bar of a front controller.
- (UIPanGestureRecognizer*)panGestureRecognizer;

// The following properties are provided for further customization, they are set to default values on initialization,
// you should not generally have to set them

// Defines how much of the rear view is shown, default is 260.
@property (assign, nonatomic) CGFloat rearViewRevealWidth;

// Defines how much of an overdraw can occur when dragging further than 'rearViewRevealWidth', default is 60.
@property (assign, nonatomic) CGFloat rearViewRevealOverdraw;

// If YES (the default) the controller will bounce to the Left position when dragging further than 'rearViewRevealWidth'
@property (assign, nonatomic) BOOL bounceBackOnOverdraw;

// If YES (default is NO) the controller will allow permanent dragging up to the rightMostPosition
@property (assign, nonatomic) BOOL stableDragOnOverdraw;

// Velocity required for the controller to toggle its state based on a swipe movement, default is 300
@property (assign, nonatomic) CGFloat quickFlickVelocity;

// Default duration for the revealToggle: animation, default is 0.25
@property (assign, nonatomic) NSTimeInterval toggleAnimationDuration;

// Defines the radius of the front view's shadow, default is 2.5f
@property (assign, nonatomic) CGFloat frontViewShadowRadius;

// Defines the radius of the front view's shadow offset default is {0.0f,2.5f}
@property (assign, nonatomic) CGSize frontViewShadowOffset;

// The class properly handles all the relevant calls to appearance methods on the rearViewController
// and frontViewController controllers. You can however assign a delegate to let the class inform you
// of the same. Note that appearance method calls and delegate method calls may not occur at exactly
// the same times or run loops, but they are all guaranteed to be consistent and to be always delivered
// at the right order

// Delegate
@property (weak, nonatomic) id<SWRevealViewControllerDelegate> delegate;

@end

#pragma mark - SWRevealViewControllerDelegate Protocol

@protocol SWRevealViewControllerDelegate<NSObject>

@optional

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position;
- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position;
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position;

- (void)revealController:(SWRevealViewController *)revealController willRevealRearViewController:(UIViewController *)viewController;
- (void)revealController:(SWRevealViewController *)revealController didRevealRearViewController:(UIViewController *)viewController;

- (void)revealController:(SWRevealViewController *)revealController willHideRearViewController:(UIViewController *)viewController;
- (void)revealController:(SWRevealViewController *)revealController didHideRearViewController:(UIViewController *)viewController;

- (void)revealController:(SWRevealViewController *)revealController willShowFrontViewController:(UIViewController *)viewController;
- (void)revealController:(SWRevealViewController *)revealController didShowFrontViewController:(UIViewController *)viewController;

- (void)revealController:(SWRevealViewController *)revealController willHideFrontViewController:(UIViewController *)viewController;
- (void)revealController:(SWRevealViewController *)revealController didHideFrontViewController:(UIViewController *)viewController;

@end


#pragma mark - UIViewController(SWRevealViewController) Category

// We add a category of UIViewController to let childViewControllers easily access their parent SWRevealViewController
@interface UIViewController(SWRevealViewController)

- (SWRevealViewController*)revealViewController;

@end
