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

#import <QuartzCore/QuartzCore.h>

#import "SWRevealViewController.h"


#pragma mark - SWRevealView Class

@interface SWRevealView: UIView
{
    __weak SWRevealViewController *_c;
}

@property (nonatomic, readonly) UIView *rearView;
@property (nonatomic, readonly) UIView *frontView;

@end


@implementation SWRevealView

- (id)initWithFrame:(CGRect)frame controller:(SWRevealViewController*)controller
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        _c = controller;
        CGRect bounds = self.bounds;
	
        _frontView = [[UIView alloc] initWithFrame:bounds];
        _rearView = [[UIView alloc] initWithFrame:bounds];
	
        _frontView.autoresizingMask = UIViewAutoresizingNone;
        _rearView.autoresizingMask = UIViewAutoresizingNone;

        [self addSubview:_rearView];
        [self addSubview:_frontView];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_frontView.bounds];
    
        CALayer *frontViewLayer = _frontView.layer;
        frontViewLayer.masksToBounds = NO;
        frontViewLayer.shadowColor = [UIColor blackColor].CGColor;
        frontViewLayer.shadowOpacity = 1.0f;
        frontViewLayer.shadowOffset = _c.frontViewShadowOffset;
        frontViewLayer.shadowRadius = _c.frontViewShadowRadius;
        frontViewLayer.shadowPath = shadowPath.CGPath;
    }
    
    return self;
}


- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    CGFloat xLocation = [self _frontLocationForPosition:_c.frontViewPosition];
    
    _frontView.frame = CGRectMake(xLocation, 0.0f, bounds.size.width, bounds.size.height);
    _rearView.frame = bounds;
}


- (void)dragFrontViewFromPosition:(FrontViewPosition)position withTranslation:(CGFloat)xTranslation
{
    CGRect bounds = self.bounds;
    CGFloat baseLocation = [self _frontLocationForPosition:position];
    CGFloat xPosition = [self _adjustedDragLocationForLocation:baseLocation+xTranslation];
    _frontView.frame = CGRectMake(xPosition, 0.0f, bounds.size.width, bounds.size.height);
}

# pragma mark private

- (CGFloat)_frontLocationForPosition:(FrontViewPosition)frontViewPosition
{
    CGFloat location = 0.0f;
    CGFloat revealWidth = _c.rearViewRevealWidth;
    CGFloat revealOverdraw = _c.rearViewRevealOverdraw;
    
    if ( frontViewPosition == FrontViewPositionRight )
        location = revealWidth;
    
    else if ( frontViewPosition == FrontViewPositionRightMost || frontViewPosition == FrontViewPositionRightMostHidden )
        location = revealWidth + revealOverdraw;

    return location;
}


- (CGFloat)_adjustedDragLocationForLocation:(CGFloat)x
{
	CGFloat result;
    CGFloat revealWidth = _c.rearViewRevealWidth;
    CGFloat revealOverdraw = _c.rearViewRevealOverdraw;
    
    if ( x <= 0.0 )
        result = 0.0f;      // keep at top left possition
	
	else if (x <= revealWidth)
		result = x;         // Translate linearly.

	else if (x <= revealWidth+2*revealOverdraw)
		result = revealWidth + (x-revealWidth)/2;   // slow down translation by halph the movement.

	else
		result = revealWidth+revealOverdraw;        // keep at the rightMost location.
	
	return result;
}

@end




#pragma mark - SWRevealViewController Class

@interface SWRevealViewController()
{
    FrontViewPosition _frontViewPosition;
    SWRevealView *_contentView;
}
@end

@implementation SWRevealViewController
{
    void (^_panRearCompletion)(void);
    FrontViewPosition _panInitialFrontPosition;
    UIPanGestureRecognizer *_panGestureRecognizer;
}

@synthesize frontViewPosition = _frontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize delegate = _delegate;

@synthesize rearViewRevealWidth = _rearViewRevealWidth;
@synthesize rearViewRevealOverdraw = _rearViewRevealOverdraw;
@synthesize revealViewTriggerOffset = _revealViewTriggerOffset;
@synthesize concealViewTriggerOffset = _concealViewTriggerOffset;
@synthesize quickFlickVelocity = _quickFlickVelocity;
@synthesize toggleAnimationDuration = _toggleAnimationDuration;
@synthesize frontViewShadowRadius = _frontViewShadowRadius;
@synthesize frontViewShadowOffset = _frontViewShadowOffset;

const int FrontViewPositionNone = -1;

#pragma mark - Init

- (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;
{
	self = [super init];
	
	if (nil != self)
	{
		_frontViewController = frontViewController;
		_rearViewController = rearViewController;
        
        _rearViewRevealWidth = 260.0f;
        _rearViewRevealOverdraw = 60.0f;
        _revealViewTriggerOffset = 120.0f;
        _concealViewTriggerOffset = 60.0f;
        _quickFlickVelocity = 250.0f;
        _toggleAnimationDuration = 0.25;
        _frontViewShadowRadius = 2.5f;
        _frontViewShadowOffset = CGSizeMake(0.0f, 2.5f);
	}
	return self;
}


#pragma mark - View lifecycle


- (void)loadView
{
    // Do not call super, to prevent the apis from unfructuously looking for inexistent xibs!
    
    // This is what Apple tells us to set as the initial frame, which is of course totally irrelevant
    // with the modern view controller containment patterns, let's leave it for the sake of it!
    CGRect frame = [[UIScreen mainScreen] applicationFrame];

    // create a custom content view for the controller and assign it to the controller's view
    _contentView = [[SWRevealView alloc] initWithFrame:frame controller:self];
    self.view = _contentView;
    
    // Apple also tells us to do this:
    _contentView.backgroundColor = [UIColor blackColor];
    
    // we set the current frontViewPosition to none before seting the
    // desired initial position, this will force proper controller reload
    FrontViewPosition initialPosition = _frontViewPosition;
    _frontViewPosition = FrontViewPositionNone;
    
    // now set the desired initial position
    [self _setFrontViewPosition:initialPosition withDuration:0.0];
}




- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Public methods and property accessors


- (void)setFrontViewController:(UIViewController *)frontViewController
{
	[self setFrontViewController:frontViewController animated:NO];
}


- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated
{
    if ( ![self isViewLoaded])
    {
        _frontViewController = frontViewController;
        return;
    }

    [self _swapCurrentFrontViewControllerWith:frontViewController animated:animated];
}


- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition
{
    [self setFrontViewPosition:frontViewPosition animated:NO];
}


- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated
{
    if ( ![self isViewLoaded] )
    {
        _frontViewPosition = frontViewPosition;
        return;
    }
    
    NSTimeInterval duration = animated?_toggleAnimationDuration:0.0;
    [self _setFrontViewPosition:frontViewPosition withDuration:duration];
}


- (void)revealToggleAnimated:(BOOL)animated
{    
    FrontViewPosition newFrontViewPosition = [self _toggledFrontViewPossition];
    NSTimeInterval animationDuration = animated?_toggleAnimationDuration:0.0f;
    [self _setFrontViewPosition:newFrontViewPosition withDuration:animationDuration];
}


- (UIPanGestureRecognizer*)panGestureRecognizer
{
    if ( _panGestureRecognizer == nil )
    {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRevealGesture:)];
    }
    return _panGestureRecognizer;
}



#pragma mark - Provided acction methods

- (void)revealToggle:(id)sender
{	
	[self revealToggleAnimated:YES];
}


#pragma mark position setup private methods

- (void)_setFrontViewPosition:(FrontViewPosition)frontViewPosition withDuration:(NSTimeInterval)duration
{
    if ( [_delegate respondsToSelector:@selector(revealController:willMoveToPosition:)] )
        [_delegate revealController:self willMoveToPosition:frontViewPosition];

    void (^rearDeploymentCompletion)() = [self _rearViewDeploymentForNewFrontViewPosition:frontViewPosition];
    void (^frontDeploymentCompletion)() = [self _frontViewDeploymentForNewFrontViewPosition:frontViewPosition];
    _frontViewPosition = frontViewPosition;
    
	[UIView animateWithDuration:duration delay:0.0 options:
    UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut
    animations:^
	{
        [_contentView layoutSubviews];
	}
	completion:^(BOOL finished)
	{
        rearDeploymentCompletion();
        frontDeploymentCompletion();
        if ( [_delegate respondsToSelector:@selector(revealController:didMoveToPosition:)] )
            [_delegate revealController:self didMoveToPosition:_frontViewPosition];
	}];
}


- (void)_swapCurrentFrontViewControllerWith:(UIViewController *)newFrontViewController animated:(BOOL)animated
{
    if ( [_delegate respondsToSelector:@selector(revealController:willMoveToPosition:)] )
        [_delegate revealController:self willMoveToPosition:FrontViewPositionLeft];
    
    NSTimeInterval firstDuration = 0.0;
    
    if ( FrontViewPositionLeft == _frontViewPosition )
        firstDuration = _toggleAnimationDuration;
    else if ( FrontViewPositionRight == _frontViewPosition )
        firstDuration = _toggleAnimationDuration*0.5;
    
    void (^rearDeploymentCompletion)() = [self _rearViewDeploymentForNewFrontViewPosition:FrontViewPositionLeft];
    void (^frontDeploymentCompletionOne)() = [self _frontViewDeploymentForNewFrontViewPosition:FrontViewPositionRightMostHidden];
    _frontViewPosition = FrontViewPositionRightMostHidden;
    
    [UIView animateWithDuration:firstDuration/*0.15f*/ delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        [_contentView layoutSubviews];
    }
    completion:^(BOOL finished)
    {
        
        frontDeploymentCompletionOne();

        _frontViewController = newFrontViewController;
        
        void (^frontDeploymentCompletionTwo)() = [self _frontViewDeploymentForNewFrontViewPosition:FrontViewPositionLeft];
        _frontViewPosition = FrontViewPositionLeft;
        
        NSTimeInterval animationDuration = animated?_toggleAnimationDuration:0.0f;
        [UIView animateWithDuration:animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            [_contentView layoutSubviews];
        }
        completion:^(BOOL finished1)
        {
            rearDeploymentCompletion();
            frontDeploymentCompletionTwo();
            if ( [_delegate respondsToSelector:@selector(revealController:didMoveToPosition:)] )
                [_delegate revealController:self didMoveToPosition:_frontViewPosition];
        }];
    }];
}



#pragma mark view controller deployment

- (void (^)(void))_rearViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    BOOL rearIsAppearing =
        (_frontViewPosition == FrontViewPositionLeft || _frontViewPosition == FrontViewPositionNone) &&
        (newPosition == FrontViewPositionRight || newPosition == FrontViewPositionRightMost
            || newPosition == FrontViewPositionRightMostHidden);
    
    BOOL rearIsDisappearing =
        (newPosition == FrontViewPositionLeft || newPosition == FrontViewPositionNone) &&
        (_frontViewPosition == FrontViewPositionRight || _frontViewPosition == FrontViewPositionRightMost
            || _frontViewPosition == FrontViewPositionRightMostHidden);
    
    void (^completion)() = nil;
    
    if ( rearIsAppearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
            [_delegate revealController:self willRevealRearViewController:_rearViewController];
        
        //completion = [self _deployViewController:_rearViewController inView:_rearView];
        completion = [self _deployViewController:_rearViewController inView:_contentView.rearView];
    }
    
    else if ( rearIsDisappearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
            [_delegate revealController:self willHideRearViewController:_rearViewController];
        
        completion = [self _undeployViewController:_rearViewController];
    }
    
    void (^rearCompletionBlock)() = ^() 
    {
        if ( completion )
            completion();
        
        if ( rearIsAppearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
                [_delegate revealController:self didRevealRearViewController:_rearViewController];
        }
        else if ( rearIsDisappearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
                [_delegate revealController:self didHideRearViewController:_rearViewController];
        }
    };

    return rearCompletionBlock;
}


- (void (^)(void))_frontViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    BOOL frontIsAppearing =
        (_frontViewPosition == FrontViewPositionRightMostHidden || _frontViewPosition == FrontViewPositionNone) &&
        (newPosition == FrontViewPositionLeft || newPosition == FrontViewPositionRight
        || newPosition == FrontViewPositionRightMost);
    
    BOOL frontIsDisappearing =
        (newPosition == FrontViewPositionRightMostHidden || newPosition == FrontViewPositionNone) &&
        (_frontViewPosition == FrontViewPositionLeft || _frontViewPosition == FrontViewPositionRight
            || _frontViewPosition == FrontViewPositionRightMost);
    
    void (^completion)() = nil;
    
    if ( frontIsAppearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willShowFrontViewController:)])
            [_delegate revealController:self willShowFrontViewController:_frontViewController];
        
        //completion = [self _deployViewController:_frontViewController inView:_frontView];
        completion = [self _deployViewController:_frontViewController inView:_contentView.frontView];
    }
    
    else if ( frontIsDisappearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willHideFrontViewController:)])
            [_delegate revealController:self willHideFrontViewController:_frontViewController];
        
        completion = [self _undeployViewController:_frontViewController];
    }
    
    void (^frontCompletionBlock)() = ^()
    {
        if ( completion )
            completion();
        
        if ( frontIsAppearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didShowFrontViewController:)])
                [_delegate revealController:self didShowFrontViewController:_frontViewController];
        }
        else if ( frontIsDisappearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didHideFrontViewController:)])
                [_delegate revealController:self didHideFrontViewController:_frontViewController];
        }
    };

    return frontCompletionBlock;
}


- (void (^)(void))_deployViewController:(UIViewController*)viewController inView:(UIView*)view
{
    if (!viewController)
        return ^(void){};
    
    UIView *controllerView = viewController.view;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controllerView.frame = view.bounds;
    
    [self addChildViewController:viewController];
    [view addSubview:controllerView];
    
    void (^completionBlock)(void) = ^(void)
    {
        [viewController didMoveToParentViewController:self];
    };
    
    return completionBlock;
}


- (void (^)(void))_undeployViewController:(UIViewController*)viewController
{
    if (!viewController)
        return ^(void){};
    
    [viewController willMoveToParentViewController:nil];
    
    void (^completionBlock)(void) = ^(void)
    {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    };
    
    return completionBlock;
}



#pragma mark - Gesture Based Reveal

- (void)_handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
	{
		case UIGestureRecognizerStateBegan:
			[self _handleRevealGestureStateBeganWithRecognizer:recognizer];
			break;
			
		case UIGestureRecognizerStateChanged:
			[self _handleRevealGestureStateChangedWithRecognizer:recognizer];
			break;
			
		case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
			[self _handleRevealGestureStateEndedWithRecognizer:recognizer];
			break;
			
		default:
			break;
	}
}



- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    _panInitialFrontPosition = _frontViewPosition;
}


- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_contentView].x;
    
    if ( _panInitialFrontPosition == FrontViewPositionLeft && translation > 0.0f )
    {
        if ( _panRearCompletion == nil )
            _panRearCompletion = [self _rearViewDeploymentForNewFrontViewPosition:FrontViewPositionRight];
        
        _frontViewPosition = FrontViewPositionRight;
    }
    
    [_contentView dragFrontViewFromPosition:_panInitialFrontPosition withTranslation:translation];
}


- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (_panRearCompletion) _panRearCompletion();
        _panRearCompletion = nil;
    
    UIView *frontView = _contentView.frontView;
    
    CGFloat xPosition = frontView.frame.origin.x;
    CGFloat velocity = [recognizer velocityInView:_contentView].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // initially assume left drag and default duration
    FrontViewPosition frontViewPosition = FrontViewPositionLeft;
    NSTimeInterval duration = _toggleAnimationDuration;

	// Velocity driven change:
	if (fabsf(velocity) > _quickFlickVelocity)
	{
        // we may have to change both the drag position and the animation duration
        CGFloat journey = xPosition;
		if (velocity > 0.0f)
		{
            frontViewPosition = FrontViewPositionRight;
            journey = _rearViewRevealWidth - xPosition;
        }
        duration = fabsf(journey/velocity);
	}
    
	// Position driven change:
	else
	{
        // we may have to change the drag position
        CGFloat dynamicTriggerLevel =
            (velocity > 0.0f) ? _revealViewTriggerOffset : _rearViewRevealWidth-_concealViewTriggerOffset;
                
        if (xPosition >= dynamicTriggerLevel && xPosition < _rearViewRevealWidth)
            frontViewPosition = FrontViewPositionRight;
	}
    
    // now animate to the final position
    [self _setFrontViewPosition:frontViewPosition withDuration:duration];
}




#pragma mark - Other Private methods

- (FrontViewPosition)_toggledFrontViewPossition;
{
    FrontViewPosition toogledFrontViewPosition = FrontViewPositionLeft;
    if (_frontViewPosition == FrontViewPositionLeft)
        toogledFrontViewPosition = FrontViewPositionRight;
    
    return toogledFrontViewPosition;
}

@end


#pragma mark - UIViewController(SWRevealViewController) Category


@implementation UIViewController(SWRevealViewController)

- (SWRevealViewController*)revealViewController
{
    UIViewController *parent = self;
    Class revealClass = [SWRevealViewController class];
    while ( parent && ![parent isKindOfClass:revealClass] )
    {
        parent = [parent parentViewController];
    }
    return (id)parent;
}

@end



