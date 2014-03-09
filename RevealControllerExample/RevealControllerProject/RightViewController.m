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

#import "RightViewController.h"
#import "MapViewController.h"
#import "SWRevealViewController.h"

@interface RightViewController ()
// Private Methods:
- (IBAction)replaceMe:(id)sender;
- (IBAction)replaceMeCustom:(id)sender;
- (IBAction)toggleFront:(id)sender;
@end

@implementation RightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set a random -not too dark- background color.
    CGFloat r = 0.001f*(250+arc4random_uniform(750));
    CGFloat g = 0.001f*(250+arc4random_uniform(750));
    CGFloat b = 0.001f*(250+arc4random_uniform(750));
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    self.view.backgroundColor = color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define TestStatusBarStyle 0   // <-- set this to 1 to test status bar style
#if TestStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#endif

#define TestStatusBarHidden 0  // <-- set this to 1 to test status bar hidden
#if TestStatusBarHidden
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#endif

- (IBAction)replaceMe:(id)sender
{
    RightViewController *replacement = [[RightViewController alloc] init];
    [self.revealViewController setRightViewController:replacement animated:YES];
}

- (IBAction)replaceMeCustom:(id)sender
{
    RightViewController *replacement = [[RightViewController alloc] init];
    replacement.wantsCustomAnimation = YES;
    [self.revealViewController setRightViewController:replacement animated:YES];
}


- (IBAction)toggleFront:(id)sender
{
    MapViewController *mapViewController = [[MapViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    [self.revealViewController pushFrontViewController:navigationController animated:YES];
}


//- (void)dealloc
//{
//    NSLog(@"RightController dealloc");
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}

@end
