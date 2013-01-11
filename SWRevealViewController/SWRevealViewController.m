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
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "SWRevealViewController.h"

#pragma mark - SWDirectionPanGestureRecognizer

typedef enum
{
    SWDirectionPanGestureRecognizerVertical,
    SWDirectionPanGestureRecognizerHorizontal

} SWDirectionPanGestureRecognizerDirection;

@interface SWDirectionPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) SWDirectionPanGestureRecognizerDirection direction;

@end


@implementation SWDirectionPanGestureRecognizer
{
    BOOL _dragging;
    CGPoint _init;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
   
    UITouch *touch = [touches anyObject];
    _init = [touch locationInView:self.view];
    _dragging = NO;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed)
        return;
    
    if ( _dragging )
        return;
    
    const int kDirectionPanThreshold = 5;
    
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.view];
    
    CGFloat moveX = nowPoint.x - _init.x;
    CGFloat moveY = nowPoint.y - _init.y;
    
    if (abs(moveX) > kDirectionPanThreshold)
    {
        if (_direction == SWDirectionPanGestureRecognizerHorizontal)
            _dragging = YES;
        else
            self.state = UIGestureRecognizerStateFailed;
    }
    else if (abs(moveY) > kDirectionPanThreshold)
    {
        if (_direction == SWDirectionPanGestureRecognizerVertical)
            _dragging = YES ;
        else
            self.state = UIGestureRecognizerStateFailed;
    }
}

@end


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
    CGFloat revealWidth = _c.rearViewRevealWidth;
    CGFloat revealOverdraw = _c.rearViewRevealOverdraw;
    CGFloat xLocation = [self _frontLocationForPosition:_c.frontViewPosition];
    
    CGFloat rearWidth = revealWidth;
    //FrontViewPosition frontPosition = _c.frontViewPosition;
    //if ( frontPosition == FrontViewPositionRightMost || frontPosition == FrontViewPositionRightMostRemoved)
        rearWidth += revealOverdraw;
    
    _frontView.frame = CGRectMake(xLocation, 0.0f, bounds.size.width, bounds.size.height);
    _rearView.frame = CGRectMake(0.0f, 0.0f, rearWidth, bounds.size.height);
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
    
    else if ( frontViewPosition == FrontViewPositionRightMost || frontViewPosition == FrontViewPositionRightMostRemoved )
        location = revealWidth + revealOverdraw;

    return location;
}


- (CGFloat)_adjustedDragLocationForLocation:(CGFloat)x
{
    CGFloat result;
    CGFloat efRevealWidth = _c.rearViewRevealWidth;
    CGFloat revealOverdraw = _c.rearViewRevealOverdraw;
    BOOL stableTrack = !_c.bounceBackOnOverdraw || _c.stableDragOnOverdraw || _c.frontViewPosition==FrontViewPositionRightMost;
    if ( stableTrack )
    {
        efRevealWidth += revealOverdraw;
        revealOverdraw = 0.0f;
    }
    
    if ( x <= 0.0 )
        result = 0.0f;      // keep at top left possition
    
    else if (x <= efRevealWidth)
        result = x;         // Translate linearly.

    else if (x <= efRevealWidth+2*revealOverdraw)
        result = efRevealWidth + (x-efRevealWidth)/2;   // slow down translation by halph the movement.

    else
        result = efRevealWidth+revealOverdraw;        // keep at the rightMost location.
    
    return result;
}

@end


#pragma mark - SWRevealViewController Class

@interface SWRevealViewController()<UIGestureRecognizerDelegate>
{
    SWRevealView *_contentView;
    UIPanGestureRecognizer *_panGestureRecognizer;
    FrontViewPosition _frontViewPosition;
    FrontViewPosition _rearViewPosition;
}
@end

@implementation SWRevealViewController
{
    void (^_panRearCompletion)(void);
    FrontViewPosition _panInitialFrontPosition;
    NSMutableArray *_animationQueue;
    BOOL _userInteractionStore;
}

@synthesize frontViewPosition = _frontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize delegate = _delegate;

@synthesize rearViewRevealWidth = _rearViewRevealWidth;
@synthesize rearViewRevealOverdraw = _rearViewRevealOverdraw;
@synthesize bounceBackOnOverdraw = _bounceBackOnOverdraw;
@synthesize quickFlickVelocity = _quickFlickVelocity;
@synthesize toggleAnimationDuration = _toggleAnimationDuration;
@synthesize frontViewShadowRadius = _frontViewShadowRadius;
@synthesize frontViewShadowOffset = _frontViewShadowOffset;

const int FrontViewPositionNone = -1;

#pragma mark - Init


- (void)_initDefaultProperties
{
    _frontViewPosition = FrontViewPositionLeft;
    _rearViewPosition = FrontViewPositionLeft;
    _rearViewRevealWidth = 260.0f;
    _rearViewRevealOverdraw = 60.0f;
    _bounceBackOnOverdraw = YES;
    _quickFlickVelocity = 250.0f;
    _toggleAnimationDuration = 0.25;
    _frontViewShadowRadius = 2.5f;
    _frontViewShadowOffset = CGSizeMake(0.0f, 2.5f);
    _animationQueue = [NSMutableArray array];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if ( self )
	{
        [self _initDefaultProperties];
	}
    
    return self;
}

- (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;
{
    self = [super init];
    
    if ( self )
    {
        _frontViewController = frontViewController;
        _rearViewController = rearViewController;
        
        [self _initDefaultProperties];
    }
    return self;
}


#pragma mark storyboard support

static NSString * const SWSegueRearIdentifier = @"sw_rear";
static NSString * const SWSegueFrontIdentifier = @"sw_front";

- (void)prepareForSegue:(SWRevealViewControllerSegue *)segue sender:(id)sender
{
    // $ using a custom segue we can get access to the storyboard-loaded rear/front view controllers
    // the trick is to define segues of type SWRevealViewControllerSegue on the storyboard
    // connecting the SWRevealViewController to the desired front/rear controllers,
    // and setting the identifiers to "sw_rear" and "sw_front"
    
    // $ these segues are invoked manually in the loadView method if a storyboard
    // was used to instantiate the SWRevealViewController
    
    // $ none of this would be necessary if Apple exposed "relationship" segues for container view controllers.

    NSString *identifier = segue.identifier;
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class] ] && sender == nil )
    {
        if ( [identifier isEqualToString:SWSegueRearIdentifier] )
        {
            segue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
            {
                _rearViewController = dvc;
            };
        }
        else if ( [identifier isEqualToString:SWSegueFrontIdentifier] )
        {
            segue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
            {
                _frontViewController = dvc;
            };
        }
    }
}



#pragma mark - View lifecycle

- (void)loadView
{
    // Do not call super, to prevent the apis from unfruitful looking for inexistent xibs!
    
    // This is what Apple tells us to set as the initial frame, which is of course totally irrelevant
    // with the modern view controller containment patterns, let's leave it for the sake of it!
    CGRect frame = [[UIScreen mainScreen] applicationFrame];

    // create a custom content view for the controller
    _contentView = [[SWRevealView alloc] initWithFrame:frame controller:self];
    
    // set the content view to resize along with its superview
     [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    // set our contentView to the controllers view
    self.view = _contentView;
    
    // load any defined front/rear controllers from the storyboard
    if ( self.storyboard && _rearViewController == nil )
    {
        [self performSegueWithIdentifier:SWSegueRearIdentifier sender: nil];
        [self performSegueWithIdentifier:SWSegueFrontIdentifier sender: nil];
    }
    
    // Apple also tells us to do this:
    _contentView.backgroundColor = [UIColor blackColor];
    
    // we set the current frontViewPosition to none before seting the
    // desired initial position, this will force proper controller reload
    FrontViewPosition initialPosition = _frontViewPosition;
    _frontViewPosition = FrontViewPositionNone;
    _rearViewPosition = FrontViewPositionNone;
    
    // now set the desired initial position
    [self _setFrontViewPosition:initialPosition withDuration:0.0];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Uncomment the following code if you want the child controllers
    // be loaded at this point.
    //
    // We leave this commented out because we think loading childs here is conceptually wrong.
    // Instead, we refrain view loads until necesary, for example we may never load
    // the rear controller view -or the front controller view- if it is never displayed.
    //
    // If you need to manipulate views of any of your child controllers in an override
    // of this method, you can load yourself the views explicitly on your overriden method.
    // However we discourage it as an app following the MVC principles should never need to do so
        
//  [_frontViewController view];
//  [_rearViewController view];
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
    
    [self _dispatchSetFrontViewController:frontViewController animated:animated];
}


- (void)revealToggleAnimated:(BOOL)animated
{
    FrontViewPosition toogledFrontViewPosition = FrontViewPositionLeft;
    if (_frontViewPosition == FrontViewPositionLeft)
        toogledFrontViewPosition = FrontViewPositionRight;
    
    [self setFrontViewPosition:toogledFrontViewPosition animated:animated];
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
        _rearViewPosition = frontViewPosition;
        return;
    }
    
    [self _dispatchSetFrontViewPosition:frontViewPosition animated:animated];
}


- (UIPanGestureRecognizer*)panGestureRecognizer
{
    if ( _panGestureRecognizer == nil )
    {
        SWDirectionPanGestureRecognizer *customRecognizer =
            [[SWDirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRevealGesture:)];
        
        customRecognizer.direction = SWDirectionPanGestureRecognizerHorizontal;
        customRecognizer.delegate = self;
        _panGestureRecognizer = customRecognizer ;
    }
    return _panGestureRecognizer;
}


#pragma mark - Provided acction methods

- (void)revealToggle:(id)sender
{    
    [self revealToggleAnimated:YES];
}


#pragma mark - Gesture Delegate


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // only allow gesture if no previous request is in process
    return ( gestureRecognizer == _panGestureRecognizer && _animationQueue.count == 0) ;
}

#pragma mark - UserInteractionEnabling

// disable userInteraction on the entire control
- (void)_disableUserInteraction
{
    _userInteractionStore = _contentView.userInteractionEnabled;
    [_contentView setUserInteractionEnabled:NO];
}

// restore userInteraction on the control
- (void)_restoreUserInteraction
{
    // we use the stored userInteraction state just in case a developer decided
    // to have our view interaction disabled beforehand
    [_contentView setUserInteractionEnabled:_userInteractionStore];
}


#pragma mark - Gesture Based Reveal

- (void)_handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
        {
            [self _handleRevealGestureStateBeganWithRecognizer:recognizer];
            break;
        }
        case UIGestureRecognizerStateChanged:
            [self _handleRevealGestureStateChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self _handleRevealGestureStateEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self _handleRevealGestureStateCancelledWithRecognizer:recognizer];
            break;
            
        default:
            break;
    }
}


- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    // we know that we will not get here unless the animationQueue is empty because the recognizer
    // delegate prevents it, however we do not want any forthcoming programatic actions to disturb
    // the gesture, so we just enqueue a dummy block to ensure any programatic acctions will be
    // scheduled after the gesture is completed
    [self _enqueueBlock:^{}]; // <-- dummy block

    // we store the initial position
    _panInitialFrontPosition = _frontViewPosition;

    // we disable user interactions on the views, however programatic accions will still be
    // enqueued to be performed after the gesture completes
    [self _disableUserInteraction];
}


- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_contentView].x;
    
    if ( _panInitialFrontPosition == FrontViewPositionLeft && translation > 0.0f )
    {
        if ( _panRearCompletion == nil )
            _panRearCompletion = [self _rearViewDeploymentForNewFrontViewPosition:FrontViewPositionRight];
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
    
    // initially we assume drag to left and default duration
    FrontViewPosition frontViewPosition = FrontViewPositionLeft;
    NSTimeInterval duration = _toggleAnimationDuration;

    // Velocity driven change:
    if (fabsf(velocity) > _quickFlickVelocity)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = xPosition;
        if (velocity > 0.0f)
        {
            frontViewPosition = FrontViewPositionRight;
            journey = _rearViewRevealWidth - xPosition;
            if (xPosition > _rearViewRevealWidth)
            {
                if (!_bounceBackOnOverdraw && _stableDragOnOverdraw /*&& xPosition > _rearViewRevealWidth+_rearViewRevealOverdraw*0.5f*/)
                {
                    frontViewPosition = FrontViewPositionRightMost;
                    journey = _rearViewRevealWidth+_rearViewRevealOverdraw - xPosition;
                }
            }
        }
        
        duration = fabsf(journey/velocity);
    }
    
    // Position driven change:
    else
    {
        // we may need to set the drag position        
        if (xPosition > _rearViewRevealWidth*0.5f)
        {
            frontViewPosition = FrontViewPositionRight;
            if (xPosition > _rearViewRevealWidth)
            {
                if (_bounceBackOnOverdraw)
                    frontViewPosition = FrontViewPositionLeft;

                else if (_stableDragOnOverdraw && xPosition > _rearViewRevealWidth+_rearViewRevealOverdraw*0.5f)
                    frontViewPosition = FrontViewPositionRightMost;
            }
        }
    }
    
    // restore user interaction and animate to the final position
    [self _restoreUserInteraction];
    [self _setFrontViewPosition:frontViewPosition withDuration:duration];

}


- (void)_handleRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (_panRearCompletion) _panRearCompletion();
        _panRearCompletion = nil;
    
    [self _restoreUserInteraction];
    [self _dequeue];
}

#pragma mark deferred position and controller setup private methods


- (void)_dispatchSetFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated
{
    NSTimeInterval duration = animated?_toggleAnimationDuration:0.0;
    [self _enqueueBlock:^
    {
        [self _setFrontViewPosition:frontViewPosition withDuration:duration];
    }];
}


- (void)_dispatchSetFrontViewController:(UIViewController *)newFrontViewController animated:(BOOL)animated
{
    NSTimeInterval duration = animated?_toggleAnimationDuration:0.0;
    
//    NSTimeInterval firstDuration = 0.0;
//    if ( _frontViewPosition == FrontViewPositionLeft )
//        firstDuration = duration;
//    else if ( _frontViewPosition == FrontViewPositionRight )
//        firstDuration = duration*0.5;

    if ( animated )
    {
        [self _enqueueBlock:^
        {
            [self _setFrontViewPosition:FrontViewPositionRightMostRemoved withDuration:duration];
        }];
    
        [self _enqueueBlock:^
        {
            [self _setFrontViewController:newFrontViewController];
        }];
    
        [self _enqueueBlock:^
        {
            [self _setFrontViewPosition:FrontViewPositionLeft withDuration:duration];
        }];
    }
    else
    {
        [self _enqueueBlock:^
        {
            [self _setFrontViewController:newFrontViewController];
        }];
    }
}


#pragma mark - deferred block execution queue

// Defers the execution of the passed in block until a paired _dequeue call is received,
// or executes the block right away if no pending requests are present.
- (void)_enqueueBlock:(void (^)(void))block
{
    [_animationQueue insertObject:block atIndex:0];
    if ( _animationQueue.count == 1)
    {
        block();
    }
}

// Removes the top most block in the queue and executes the following one if any.
// Calls to this method must be paired with calls to _enqueueBlock, particularly it may be called
// from within a block passed to _enqueueBlock to remove itself when done with animations.  
- (void)_dequeue
{
    [_animationQueue removeLastObject];

    if ( _animationQueue.count > 0 )
    {
        void (^block)(void) = [_animationQueue lastObject];
        block();
    }
}


#pragma mark animated view controller deployment and layout

// Basic method for view controller deployment and animated layout to the given position.
- (void)_setFrontViewPosition:(FrontViewPosition)frontViewPosition withDuration:(NSTimeInterval)duration
{
    void (^rearDeploymentCompletion)() = [self _rearViewDeploymentForNewFrontViewPosition:frontViewPosition];
    void (^frontDeploymentCompletion)() = [self _frontViewDeploymentForNewFrontViewPosition:frontViewPosition];
    
    void (^animations)() = ^()
    {
        [self _layoutControllerViews];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        rearDeploymentCompletion();
        frontDeploymentCompletion();
        [self _dequeue];
    };
    
    if ( duration > 0.0f )
    {
        [UIView animateWithDuration:duration delay:0.0
        options:UIViewAnimationOptionBeginFromCurrentState/*|UIViewAnimationOptionAllowUserInteraction*/|UIViewAnimationOptionCurveEaseOut
        animations:animations completion:completion];
    }
    else
    {
        // in case of no animation we do not want to execute the completion block on the next run loop iteration
        // so we check this case to invoke directly the blocks instead
        animations();
        completion(YES);
    }
}

// Basic method for front controller deployment with no layout or position change
- (void)_setFrontViewController:(UIViewController*)newFrontViewController
{
    FrontViewPosition endPosition = _frontViewPosition;
    [self _frontViewDeploymentForNewFrontViewPosition:FrontViewPositionRightMostRemoved]();
    _frontViewController = newFrontViewController;
    [self _frontViewDeploymentForNewFrontViewPosition:endPosition]();
    [self _dequeue];
}




#pragma mark view controller deployment and layout

// Calls the layoutSubviews method on the contentView view and sends a delegate call, which will
// occur inside of an animation block if any animated transition is being performed
- (void)_layoutControllerViews
{
    [_contentView layoutSubviews];
    
    if ([_delegate respondsToSelector:@selector(revealController:animateToPosition:)])
            [_delegate revealController:self animateToPosition:_frontViewPosition];

}


// Deploy/Undeploy of the rear view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rearViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    BOOL rearIsAppearing =
        (_rearViewPosition == FrontViewPositionLeft || _rearViewPosition == FrontViewPositionNone) &&
        (newPosition == FrontViewPositionRight || newPosition == FrontViewPositionRightMost
            || newPosition == FrontViewPositionRightMostRemoved);
    
    BOOL rearIsDisappearing =
        (newPosition == FrontViewPositionLeft || newPosition == FrontViewPositionNone) &&
        (_rearViewPosition == FrontViewPositionRight || _rearViewPosition == FrontViewPositionRightMost
            || _rearViewPosition == FrontViewPositionRightMostRemoved);
    
    UIViewController* (^completion)() = nil;
    
    _rearViewPosition = newPosition;
    
    if ( rearIsAppearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
            [_delegate revealController:self willRevealRearViewController:_rearViewController];
        
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
        UIViewController* viewController = nil;
        
        if ( completion )
            viewController = completion();
        
        if ( rearIsAppearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
                [_delegate revealController:self didRevealRearViewController:viewController];
        }
        else if ( rearIsDisappearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
                [_delegate revealController:self didHideRearViewController:viewController];
        }
    };

    return rearCompletionBlock;
}

// Deploy/Undeploy of the front view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_frontViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    BOOL positionIsChanging = (_frontViewPosition != newPosition);

    BOOL frontIsAppearing =
        (_frontViewPosition == FrontViewPositionRightMostRemoved || _frontViewPosition == FrontViewPositionNone) &&
        (newPosition == FrontViewPositionLeft || newPosition == FrontViewPositionRight
        || newPosition == FrontViewPositionRightMost);
    
    BOOL frontIsDisappearing =
        (newPosition == FrontViewPositionRightMostRemoved || newPosition == FrontViewPositionNone) &&
        (_frontViewPosition == FrontViewPositionLeft || _frontViewPosition == FrontViewPositionRight
            || _frontViewPosition == FrontViewPositionRightMost);
    
    UIViewController* (^completion)() = nil;
    
    if ( positionIsChanging )
    {
        if ( [_delegate respondsToSelector:@selector(revealController:willMoveToPosition:)] )
            [_delegate revealController:self willMoveToPosition:newPosition];
    }
    
    _frontViewPosition = newPosition;
    
    if ( frontIsAppearing )
    {
        if ([_delegate respondsToSelector:@selector(revealController:willShowFrontViewController:)])
            [_delegate revealController:self willShowFrontViewController:_frontViewController];
        
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
        UIViewController *viewController = nil;
        
        if ( completion )
            viewController = completion();
        
        if ( frontIsAppearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didShowFrontViewController:)])
                [_delegate revealController:self didShowFrontViewController:viewController];
        }
        
        else if ( frontIsDisappearing )
        {
            if ([_delegate respondsToSelector:@selector(revealController:didHideFrontViewController:)])
                [_delegate revealController:self didHideFrontViewController:viewController];
        }
        
        if ( positionIsChanging )
        {
            if ( [_delegate respondsToSelector:@selector(revealController:didMoveToPosition:)] )
                [_delegate revealController:self didMoveToPosition:newPosition];
        }
    };

    return frontCompletionBlock;
}

// Deploy method. Returns a block (returning the affected controller) to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (UIViewController* (^)(void))_deployViewController:(UIViewController*)viewController inView:(UIView*)view
{
    if (!viewController)
        return ^(void){ return viewController;};
    
    [self addChildViewController:viewController];
    
    UIView *controllerView = viewController.view;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controllerView.frame = view.bounds;
    
    [view addSubview:controllerView];
    
    UIViewController* (^completionBlock)(void) = ^(void)
    {
        [viewController didMoveToParentViewController:self];
        return viewController;
    };
    
    return completionBlock;
}

// Undeploy method. Returns a block (returning the affected controller) to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (UIViewController* (^)(void))_undeployViewController:(UIViewController*)viewController
{
    if (!viewController)
        return ^(void){ return viewController;};
    
    [viewController willMoveToParentViewController:nil];
    
    UIViewController* (^completionBlock)(void) = ^(void)
    {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        return viewController;
    };
    
    return completionBlock;
}



@end



#pragma mark - UIViewController(SWRevealViewController) Category

@implementation UIViewController(SWRevealViewController)

- (SWRevealViewController*)revealViewController
{
    UIViewController *parent = self;
    Class revealClass = [SWRevealViewController class];
    
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:revealClass] )
    {
    }
    
    return (id)parent;
}

@end


#pragma mark - SWRevealViewControllerSegue Class

@implementation SWRevealViewControllerSegue

- (void)perform
{
    if ( _performBlock != nil )
    {
        _performBlock( self, self.sourceViewController, self.destinationViewController );
    }
}

@end

