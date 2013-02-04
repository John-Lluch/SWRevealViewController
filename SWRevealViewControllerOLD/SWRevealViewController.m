/*

 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

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
@property (nonatomic, readonly) UIView *rightView;
@property (nonatomic, readonly) UIView *frontView;
@property (nonatomic, assign) BOOL disableLayout;

@end


@interface SWRevealViewController()
- (void)_getRevealWidth:(CGFloat*)pRevealWidth revealOverDraw:(CGFloat*)pRevealOverdraw forSymetry:(int)symetry;
- (void)_getBounceBack:(BOOL*)pBounceBack pStableDrag:(BOOL*)pStableDrag forSymetry:(int)symetry;
- (void)_getAdjustedFrontViewPosition:(FrontViewPosition*)frontViewPosition forSymetry:(int)symetry;
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
        _frontView.autoresizingMask = UIViewAutoresizingNone;

        [self addSubview:_frontView];

        CALayer *frontViewLayer = _frontView.layer;
        frontViewLayer.masksToBounds = NO;
        frontViewLayer.shadowColor = [UIColor blackColor].CGColor;
        frontViewLayer.shadowOpacity = 1.0f;
        frontViewLayer.shadowOffset = _c.frontViewShadowOffset;
        frontViewLayer.shadowRadius = _c.frontViewShadowRadius;
    }
    
    return self;
}


- (void)layoutSubviews
{
    if ( _disableLayout ) return;

    [self _layoutRearViews];

    CGRect bounds = self.bounds;
    
    CGFloat xPosition = [self frontLocationForPosition:_c.frontViewPosition];
    _frontView.frame = CGRectMake(xPosition, 0.0f, bounds.size.width, bounds.size.height);
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_frontView.bounds];
    _frontView.layer.shadowPath = shadowPath.CGPath;
}


- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition
{
    if ( _rearView == nil )
    {
        _rearView = [[UIView alloc] initWithFrame:self.bounds];
        _rearView.autoresizingMask = UIViewAutoresizingNone;
        [self insertSubview:_rearView belowSubview:_frontView];
    }
    [self _layoutRearViews];
    [self _prepareForNewPosition:newPosition];
}


- (CGFloat)frontLocationForPosition:(FrontViewPosition)frontViewPosition
{
    CGFloat revealWidth;
    CGFloat revealOverdraw;
    
    CGFloat location = 0.0f;
    
    int symetry = frontViewPosition<FrontViewPositionLeft? -1 : 1;
    [_c _getRevealWidth:&revealWidth revealOverDraw:&revealOverdraw forSymetry:symetry];
    [_c _getAdjustedFrontViewPosition:&frontViewPosition forSymetry:symetry];
    
    if ( frontViewPosition == FrontViewPositionRight )
        location = revealWidth;
    
    else if ( frontViewPosition > FrontViewPositionRight )
        location = revealWidth + revealOverdraw;

    return location*symetry;
}


- (void)dragFrontViewToXPosition:(CGFloat)xPosition
{
    CGRect bounds = self.bounds;
    xPosition = [self _adjustedDragLocationForLocation:xPosition];
    _frontView.frame = CGRectMake(xPosition, 0.0f, bounds.size.width, bounds.size.height);
}


- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition
{
    if ( _rightView == nil )
    {
        _rightView = [[UIView alloc] initWithFrame:self.bounds];
        _rightView.autoresizingMask = UIViewAutoresizingNone;
        [self insertSubview:_rightView belowSubview:_frontView];
    }
    [self _layoutRearViews];
    [self _prepareForNewPosition:newPosition];
}


# pragma mark private

- (void)_layoutRearViews
{
    CGRect bounds = self.bounds;
    
    CGFloat rearWidth = _c.rearViewRevealWidth + _c.rearViewRevealOverdraw;
    _rearView.frame = CGRectMake(0.0, 0.0, rearWidth, bounds.size.height);
    
    CGFloat rightWidth = _c.rightViewRevealWidth + _c.rightViewRevealOverdraw;
    _rightView.frame = CGRectMake(bounds.size.width-rightWidth, 0.0f, rightWidth, bounds.size.height);
}


- (void)_prepareForNewPosition:(FrontViewPosition)newPosition;
{
    if ( _rearView == nil || _rightView == nil )
        return;
    
    int symetry = newPosition<FrontViewPositionLeft? -1 : 1;

    NSArray *subViews = self.subviews;
    NSInteger rearIndex = [subViews indexOfObjectIdenticalTo:_rearView];
    NSInteger rightIndex = [subViews indexOfObjectIdenticalTo:_rightView];
    
    if ( (symetry < 0 && rightIndex < rearIndex) || (symetry > 0 && rearIndex < rightIndex) )
        [self exchangeSubviewAtIndex:rightIndex withSubviewAtIndex:rearIndex];
}


- (CGFloat)_adjustedDragLocationForLocation:(CGFloat)x
{
    CGFloat result;
    
    CGFloat revealWidth;
    CGFloat revealOverdraw;
    BOOL bounceBack;
    BOOL stableDrag;
    FrontViewPosition position = _c.frontViewPosition;
    
    int symetry = x<0 ? -1 : 1;
    
    [_c _getRevealWidth:&revealWidth revealOverDraw:&revealOverdraw forSymetry:symetry];
    [_c _getBounceBack:&bounceBack pStableDrag:&stableDrag forSymetry:symetry];
    
    BOOL stableTrack = !bounceBack || stableDrag || position==FrontViewPositionRightMost || position==FrontViewPositionLeftSideMost;
    if ( stableTrack )
    {
        revealWidth += revealOverdraw;
        revealOverdraw = 0.0f;
    }
    
    x = x * symetry;
    
    if (x <= revealWidth)
        result = x;         // Translate linearly.

    else if (x <= revealWidth+2*revealOverdraw)
        result = revealWidth + (x-revealWidth)/2;   // slow down translation by halph the movement.

    else
        result = revealWidth+revealOverdraw;        // keep at the rightMost location.
    
    return result * symetry;
}

@end


#pragma mark - SWRevealViewController Class

@interface SWRevealViewController()<UIGestureRecognizerDelegate>
{
    SWRevealView *_contentView;
    UIPanGestureRecognizer *_panGestureRecognizer;
    FrontViewPosition _frontViewPosition;
    FrontViewPosition _rearViewPosition;
    FrontViewPosition _rightViewPosition;
}
@end


@implementation SWRevealViewController
{
    //void (^_panRearCompletion)(void);
    //void (^_panRightCompletion)(void);
    FrontViewPosition _panInitialFrontPosition;
    //FrontViewPosition _panTargetFrontPosition;
    NSMutableArray *_animationQueue;
    BOOL _userInteractionStore;
}

const int FrontViewPositionNone = 0xff;


#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self _initDefaultProperties];
    }    
    return self;
}


- (id)init
{
    return [self initWithRearViewController:nil frontViewController:nil];
}


- (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;
{
    self = [super init];
    if ( self )
    {
        [self _initDefaultProperties];
        [self _setRearViewController:rearViewController];
        [self _setFrontViewController:frontViewController];
    }
    return self;
}


- (void)_initDefaultProperties
{
    _frontViewPosition = FrontViewPositionLeft;
    _rearViewPosition = FrontViewPositionLeft;
    _rightViewPosition = FrontViewPositionLeft;
    _rearViewRevealWidth = 260.0f;
    _rearViewRevealOverdraw = 60.0f;
    _rightViewRevealWidth = 260.0f;
    _rightViewRevealOverdraw = 60.0f;
    _bounceBackOnOverdraw = YES;
    _bounceBackOnLeftOverdraw = YES;
    _stableDragOnOverdraw = NO;
    _stableDragOnLeftOverdraw = NO;
    _quickFlickVelocity = 250.0f;
    _toggleAnimationDuration = 0.25;
    _frontViewShadowRadius = 2.5f;
    _frontViewShadowOffset = CGSizeMake(0.0f, 2.5f);
    _animationQueue = [NSMutableArray array];
}


#pragma mark storyboard support

static NSString * const SWSegueRearIdentifier = @"sw_rear";
static NSString * const SWSegueFrontIdentifier = @"sw_front";
static NSString * const SWSegueRightIdentifier = @"sw_right";

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
    if ( [segue isKindOfClass:[SWRevealViewControllerSegue class]] && sender == nil )
    {
        if ( [identifier isEqualToString:SWSegueRearIdentifier] )
        {
            segue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
            {
                [self _setRearViewController:dvc];
            };
        }
        else if ( [identifier isEqualToString:SWSegueFrontIdentifier] )
        {
            segue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
            {
                [self _setFrontViewController:dvc];
            };
        }
        else if ( [identifier isEqualToString:SWSegueRightIdentifier] )
        {
            segue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
            {
                [self _setRightViewController:dvc];
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
    _rightViewPosition = FrontViewPositionNone;
    
    // now set the desired initial position
    [self _setFrontViewPosition:initialPosition withDuration:0.0];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Uncomment the following code if you want the child controllers
    // to be loaded at this point.
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
        [self _setFrontViewController:frontViewController];
        return;
    }
    
    [self _dispatchSetFrontViewController:frontViewController animated:animated];
}


- (void)setRearViewController:(UIViewController *)rightViewController
{
    if ( ![self isViewLoaded])
    {
        [self _setRearViewController:rightViewController];
        return;
    }

    [self _dispatchSetRearViewController:rightViewController];
}


- (void)setRightViewController:(UIViewController *)rightViewController
{
    if ( ![self isViewLoaded])
    {
        [self _setRightViewController:rightViewController];
        return;
    }

    [self _dispatchSetRightViewController:rightViewController];
}


- (void)revealToggleAnimated:(BOOL)animated
{
    FrontViewPosition toogledFrontViewPosition = FrontViewPositionLeft;
    if (_frontViewPosition <= FrontViewPositionLeft)
        toogledFrontViewPosition = FrontViewPositionRight;
    
    [self setFrontViewPosition:toogledFrontViewPosition animated:animated];
}

- (void)rightRevealToggleAnimated:(BOOL)animated
{
    FrontViewPosition toogledFrontViewPosition = FrontViewPositionLeft;
    if (_frontViewPosition >= FrontViewPositionLeft)
        toogledFrontViewPosition = FrontViewPositionLeftSide;
    
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
        _rightViewPosition = frontViewPosition;
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

- (void)rightRevealToggle:(id)sender
{    
    [self rightRevealToggleAnimated:YES];
}


#pragma mark - UserInteractionEnabling

// disable userInteraction on the entire control
- (void)_disableUserInteraction
{
    _userInteractionStore = _contentView.userInteractionEnabled;
    [_contentView setUserInteractionEnabled:NO];
    [_contentView setDisableLayout:YES];
}

// restore userInteraction on the control
- (void)_restoreUserInteraction
{
    // we use the stored userInteraction state just in case a developer decided
    // to have our view interaction disabled beforehand
    [_contentView setUserInteractionEnabled:_userInteractionStore];
    [_contentView setDisableLayout:NO];
}


#pragma mark - Symetry

- (void)_getRevealWidth:(CGFloat*)pRevealWidth revealOverDraw:(CGFloat*)pRevealOverdraw forSymetry:(int)symetry
{
    if ( symetry < 0 ) *pRevealWidth = _rightViewRevealWidth, *pRevealOverdraw = _rightViewRevealOverdraw;
    else *pRevealWidth = _rearViewRevealWidth, *pRevealOverdraw = _rearViewRevealOverdraw;
}

- (void)_getBounceBack:(BOOL*)pBounceBack pStableDrag:(BOOL*)pStableDrag forSymetry:(int)symetry
{
    if ( symetry < 0 ) *pBounceBack = _bounceBackOnLeftOverdraw, *pStableDrag = _stableDragOnLeftOverdraw;
    else *pBounceBack = _bounceBackOnOverdraw, *pStableDrag = _stableDragOnOverdraw;
}

- (void)_getAdjustedFrontViewPosition:(FrontViewPosition*)frontViewPosition forSymetry:(int)symetry
{
    if ( symetry < 0 ) *frontViewPosition = FrontViewPositionLeft + symetry*(*frontViewPosition-FrontViewPositionLeft);
}


#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // only allow gesture if no previous request is in process
    return ( gestureRecognizer == _panGestureRecognizer && _animationQueue.count == 0) ;
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

    // we store the initial position and initialize a target position
    _panInitialFrontPosition = _frontViewPosition;

    // we disable user interactions on the views, however programatic accions will still be
    // enqueued to be performed after the gesture completes
    [self _disableUserInteraction];
}


- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_contentView].x;
        
    BOOL allowDragging = YES;
    
    CGFloat baseLocation = [_contentView frontLocationForPosition:_panInitialFrontPosition];
    CGFloat xPosition = baseLocation + translation;
    
    if ( xPosition < 0 )
    {
        allowDragging = (_rightViewController != nil);
        [self _rightViewDeploymentForNewFrontViewPosition:FrontViewPositionLeftSide]();
    }
    
    if ( xPosition > 0 )
    {
        allowDragging = (_rearViewController != nil);
        [self _rearViewDeploymentForNewFrontViewPosition:FrontViewPositionRight]();
    }
    
    if ( allowDragging )
    {
       // [_contentView dragFrontViewFromPosition:_panInitialFrontPosition withTranslation:translation];
        [_contentView dragFrontViewToXPosition:xPosition];
    }
}


- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
//    if (_panRearCompletion) _panRearCompletion();
//        _panRearCompletion = nil;
    
    UIView *frontView = _contentView.frontView;
    
    CGFloat xPosition = frontView.frame.origin.x;
    CGFloat velocity = [recognizer velocityInView:_contentView].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // depending on position we compute a simetric replacement of widths and positions
    int symetry = xPosition<0 ? -1 : 1;
    
    // simetring computing of widths
    CGFloat revealWidth ;
    CGFloat revealOverdraw ;
    BOOL bounceBack;
    BOOL stableDrag;
    
    [self _getRevealWidth:&revealWidth revealOverDraw:&revealOverdraw forSymetry:symetry];
    [self _getBounceBack:&bounceBack pStableDrag:&stableDrag forSymetry:symetry];
    
    // simetric replacement of position
    xPosition = xPosition * symetry;
    
    // initially we assume drag to left and default duration
    FrontViewPosition frontViewPosition = FrontViewPositionLeft;
    NSTimeInterval duration = _toggleAnimationDuration;

    // Velocity driven change:
    if (fabsf(velocity) > _quickFlickVelocity)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = xPosition;
        if (velocity*symetry > 0.0f)
        {
            frontViewPosition = FrontViewPositionRight;
            journey = revealWidth - xPosition;
            if (xPosition > revealWidth)
            {
                if (!bounceBack && stableDrag /*&& xPosition > _rearViewRevealWidth+_rearViewRevealOverdraw*0.5f*/)
                {
                    frontViewPosition = FrontViewPositionRightMost;
                    journey = revealWidth+revealOverdraw - xPosition;
                }
            }
        }
        
        duration = fabsf(journey/velocity);
    }
    
    // Position driven change:
    else
    {    
        // we may need to set the drag position        
        if (xPosition > revealWidth*0.5f)
        {
            frontViewPosition = FrontViewPositionRight;
            if (xPosition > revealWidth)
            {
                if (bounceBack)
                    frontViewPosition = FrontViewPositionLeft;

                else if (stableDrag && xPosition > revealWidth+revealOverdraw*0.5f)
                    frontViewPosition = FrontViewPositionRightMost;
            }
        }
    }
    
    // symetric replacement of frontViewPosition
    [self _getAdjustedFrontViewPosition:&frontViewPosition forSymetry:symetry];
    
    // restore user interaction and animate to the final position
    [self _restoreUserInteraction];
    [self _setFrontViewPosition:frontViewPosition withDuration:duration];
}


- (void)_handleRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
//    if (_panRearCompletion) _panRearCompletion();
//    _panRearCompletion = nil;
//    
//    if (_panRightCompletion) _panRightCompletion();
//    _panRightCompletion = nil;
    
    [self _restoreUserInteraction];
    [self _dequeue];
}


#pragma mark enqueued position and controller setup

- (void)_dispatchSetFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated
{
    NSTimeInterval duration = animated?_toggleAnimationDuration:0.0;
    __weak SWRevealViewController *theSelf = self;
    [self _enqueueBlock:^
    {
        [theSelf _setFrontViewPosition:frontViewPosition withDuration:duration];
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

    __weak SWRevealViewController *theSelf = self;
    if ( animated )
    {
        [self _enqueueBlock:^
        {
            [theSelf _setFrontViewPosition:FrontViewPositionRightMost withDuration:duration];
        }];
    
        [self _enqueueBlock:^
        {
            [theSelf _setFrontViewController:newFrontViewController];
        }];
    
        [self _enqueueBlock:^
        {
            [theSelf _setFrontViewPosition:FrontViewPositionLeft withDuration:duration];
        }];
    }
    else
    {
        [self _enqueueBlock:^
        {
            [theSelf _setFrontViewController:newFrontViewController];
        }];
    }
}


- (void)_dispatchSetRearViewController:(UIViewController *)newRearViewController
{
    __weak SWRevealViewController *theSelf = self;
    [self _enqueueBlock:^{
        [theSelf _setRearViewController:newRearViewController];
    }];
}


- (void)_dispatchSetRightViewController:(UIViewController *)newRightViewController
{
    __weak SWRevealViewController *theSelf = self;
    [self _enqueueBlock:^
    {
        [theSelf _setRightViewController:newRightViewController];
    }];
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

// Primitive method for view controller deployment and animated layout to the given position.
- (void)_setFrontViewPosition:(FrontViewPosition)newPosition withDuration:(NSTimeInterval)duration
{
    void (^rearDeploymentCompletion)() = [self _rearViewDeploymentForNewFrontViewPosition:newPosition];
    void (^rightDeploymentCompletion)() = [self _rightViewDeploymentForNewFrontViewPosition:newPosition];
    void (^frontDeploymentCompletion)() = [self _frontViewDeploymentForNewFrontViewPosition:newPosition];
    
    void (^animations)() = ^()
    {
        [self _layoutControllerViews];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        rearDeploymentCompletion();
        rightDeploymentCompletion();
        frontDeploymentCompletion();
        [self _dequeue];
    };
    
    if ( duration > 0.0f )
    {
        [UIView animateWithDuration:duration delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:animations completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

// primitive method for front controller transition
- (void)_setFrontViewController:(UIViewController*)newFrontViewController
{
    UIViewController *old = _frontViewController;
    _frontViewController = newFrontViewController;
    [self _transitionFrontController:old toController:newFrontViewController inView:_contentView.frontView]();    
    [self _dequeue];
}


// Primitive method for rear controller transition
- (void)_setRearViewController:(UIViewController*)newRearViewController
{
    UIViewController *old = _rearViewController;
    _rearViewController = newRearViewController;
    [self _transitionRearController:old toController:newRearViewController inView:_contentView.frontView]();
    [self _dequeue];
}

// Primitive method for right controller transition
- (void)_setRightViewController:(UIViewController*)newRightViewController
{
    UIViewController *old = _rightViewController;
    _rightViewController = newRightViewController;
    [self _transitionRearController:old toController:newRightViewController inView:_contentView.rightView]();
    [self _dequeue];
    
//    UIViewController *old = _rightViewController;
//    void (^completion)() = [self _transitionRearController:old toController:newRightViewController inView:_contentView.rightView];
//    [newRightViewController.view setAlpha:0.0];
//    [UIView animateWithDuration:_toggleAnimationDuration
//    animations:^
//    {
//        [old.view setAlpha:0.0f];
//        [newRightViewController.view setAlpha:1.0];
//    }
//    completion:^(BOOL finished)
//    {
//        completion();
//        [self _dequeue];
//    }];
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


#pragma mark Position based view controller deployment

// Deploy/Undeploy of the front view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_frontViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    if ( _rightViewController == nil && newPosition < FrontViewPositionLeft )
        newPosition = FrontViewPositionLeft;
    
    if ( _rearViewController == nil && newPosition > FrontViewPositionLeft )
        newPosition = FrontViewPositionLeft;

    BOOL positionIsChanging = (_frontViewPosition != newPosition);
    
    BOOL frontIsAppearing =
        (_frontViewPosition >= FrontViewPositionRightMostRemoved || _frontViewPosition <= FrontViewPositionLeftSideMostRemoved) &&
        (newPosition < FrontViewPositionRightMostRemoved && newPosition > FrontViewPositionLeftSideMostRemoved);
    
    BOOL frontIsDisappearing =
        (newPosition >= FrontViewPositionRightMostRemoved || newPosition <= FrontViewPositionLeftSideMostRemoved ) &&
        (_frontViewPosition < FrontViewPositionRightMostRemoved && _frontViewPosition > FrontViewPositionLeftSideMostRemoved);
    
    void (^deployCompletion)() = nil;
    void (^undeployCompletion)() = nil;
    UIViewController *viewController = _frontViewController;
    
    if ( positionIsChanging )
    {
        if ( [_delegate respondsToSelector:@selector(revealController:willMoveToPosition:)] )
            [_delegate revealController:self willMoveToPosition:newPosition];
    }
    
    _frontViewPosition = newPosition;
    
    if ( frontIsAppearing )
        deployCompletion = [self _deployFrontController:_frontViewController inView:_contentView.frontView];
    
    else if ( frontIsDisappearing )
        undeployCompletion = [self _undeployFrontController:viewController];
    
    void (^completion)() = ^()
    {
        if ( frontIsAppearing )
            deployCompletion();
        
        else if ( frontIsDisappearing )
            undeployCompletion();
        
        if ( positionIsChanging )
        {
            if ( [_delegate respondsToSelector:@selector(revealController:didMoveToPosition:)] )
                [_delegate revealController:self didMoveToPosition:newPosition];
        }
    };

    return completion;
}

// Deploy/Undeploy of the left view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rearViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    if ( _rearViewController == nil && newPosition > FrontViewPositionLeft )
        newPosition = FrontViewPositionLeft;

    BOOL rearIsAppearing = (_rearViewPosition <= FrontViewPositionLeft || _rearViewPosition == FrontViewPositionNone) && newPosition > FrontViewPositionLeft;
    BOOL rearIsDisappearing = (newPosition <= FrontViewPositionLeft || newPosition == FrontViewPositionNone) && _rearViewPosition > FrontViewPositionLeft;
    
    if ( rearIsAppearing )
        [_contentView prepareRearViewForPosition:newPosition];
    
    _rearViewPosition = newPosition;
    
    void (^completion)() = ^{};
    
    if ( rearIsAppearing )
        completion = [self _deployRearController:_rearViewController inView:_contentView.rearView];
    
    if ( rearIsDisappearing )
        completion = [self _undeployRearController:_rearViewController];
    
    return completion;
}

// Deploy/Undeploy of the right view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rightViewDeploymentForNewFrontViewPosition:(FrontViewPosition)newPosition
{
    if ( _rightViewController == nil && newPosition < FrontViewPositionLeft )
        newPosition = FrontViewPositionLeft;

    BOOL rightIsAppearing = _rightViewPosition >= FrontViewPositionLeft && newPosition < FrontViewPositionLeft ;
    BOOL rightIsDisappearing = newPosition >= FrontViewPositionLeft && _rightViewPosition < FrontViewPositionLeft;
    
    if ( rightIsAppearing )
        [_contentView prepareRightViewForPosition:newPosition];
    
    _rightViewPosition = newPosition;
   
    void (^completion)() = ^{};
    
    if ( rightIsAppearing )
        completion = [self _deployRearController:_rightViewController inView:_contentView.rightView];
    
    if (rightIsDisappearing )
        completion = [self _undeployRearController:_rightViewController];
    
    return completion;
}

// Front deploy
- (void (^)(void))_deployFrontController:(UIViewController*)frontController inView:(UIView*)view
{
    if ([_delegate respondsToSelector:@selector(revealController:willShowFrontViewController:)])
        [_delegate revealController:self willShowFrontViewController:frontController];
        
    void (^completion)() = [self _deployViewController:frontController inView:view];
    
    void (^frontCompletionBlock)() = ^()
    {
        completion();
        if ([_delegate respondsToSelector:@selector(revealController:didShowFrontViewController:)])
            [_delegate revealController:self didShowFrontViewController:frontController];
    };

    return frontCompletionBlock;
}

// Front undeploy
- (void (^)(void))_undeployFrontController:(UIViewController*)frontController
{
    if ([_delegate respondsToSelector:@selector(revealController:willHideFrontViewController:)])
        [_delegate revealController:self willHideFrontViewController:frontController];
        
    void (^completion)() = [self _undeployViewController:frontController];
    
    void (^frontCompletionBlock)() = ^()
    {
        completion();
        if ([_delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
            [_delegate revealController:self didHideFrontViewController:frontController];
    };

    return frontCompletionBlock;
}

// Rear deploy
- (void (^)(void))_deployRearController:(UIViewController*)rearController inView:(UIView*)view
{
    if ([_delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
            [_delegate revealController:self willRevealRearViewController:rearController];
        
    void (^completion)() = [self _deployViewController:rearController inView:view];
    
    void (^rearCompletionBlock)() = ^()
    {
        completion();
        if ([_delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
                [_delegate revealController:self didRevealRearViewController:rearController];
    };

    return rearCompletionBlock;
}

// Rear undeploy
- (void (^)(void))_undeployRearController:(UIViewController*)rearController
{
    if ([_delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
        [_delegate revealController:self willHideRearViewController:rearController];
        
    void (^completion)() = [self _undeployViewController:rearController];
    
    void (^rearCompletionBlock)() = ^()
    {
        completion();
        if ([_delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
                [_delegate revealController:self didHideRearViewController:rearController];
    };

    return rearCompletionBlock;
}


#pragma mark View controller transition

// Front Transition method.
- (void(^)(void))_transitionFrontController:(UIViewController*)fromController toController:(UIViewController*)toController inView:(UIView*)view
{
    SEL deploy = @selector(_deployFrontController:inView:);
    SEL undeploy = @selector(_undeployFrontController:);
    
    void (^completionBlock)(void) = [self _transitionFromViewController:fromController toViewController:toController inView:view
        deploySelector:deploy undeploySelector:undeploy];
    
    return completionBlock;
}

// Rear Transition method.
- (void(^)(void))_transitionRearController:(UIViewController*)fromController toController:(UIViewController*)toController inView:(UIView*)view
{
    SEL deploy = @selector(_deployRearController:inView:);
    SEL undeploy = @selector(_undeployRearController:);
    
    void (^completionBlock)(void) = [self _transitionFromViewController:fromController toViewController:toController inView:view
        deploySelector:deploy undeploySelector:undeploy];
    
    return completionBlock;
}


#pragma mark Containment view controller deployment and transition

// Containment Deploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_deployViewController:(UIViewController*)viewController inView:(UIView*)view
{
    if ( !viewController || !view )
        return ^(void){};
    
    UIView *controllerView = viewController.view;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controllerView.frame = view.bounds;
    
    [view addSubview:controllerView];
    
    void (^completionBlock)(void) = ^(void)
    {
        // nothing to do on completion at this stage
    };
    
    return completionBlock;
}

// Containment Undeploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_undeployViewController:(UIViewController*)viewController
{
    if (!viewController)
        return ^(void){};

    // nothing to do before completion at this stage
    
    void (^completionBlock)(void) = ^(void)
    {
        [viewController.view removeFromSuperview];
    };
    
    return completionBlock;
}

// Containment Transition method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated transition.
- (void(^)(void))_transitionFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController inView:(UIView*)view deploySelector:(SEL)deploy undeploySelector:(SEL)undeploy
{
    if ( fromController == toController )
        return ^(void){};
    
    if ( toController ) [self addChildViewController:toController];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if ( deploy == NULL ) deploy = @selector(_deployViewController:inView:);
    void (^deployCompletion)() = [self performSelector:deploy withObject:toController withObject:view];
    
    [fromController willMoveToParentViewController:nil];
    
    if ( undeploy == NULL ) undeploy = @selector(_undeployViewController:);
    void (^undeployCompletion)() = [self performSelector:undeploy withObject:fromController];
    
    #pragma clang diagnostic pop
    
    void (^completionBlock)(void) = ^(void)
    {
        undeployCompletion() ;
        [fromController removeFromParentViewController];
        
        deployCompletion() ;
        [toController didMoveToParentViewController:self];
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

