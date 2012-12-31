//
//  FrontViewControllerBlocksViewController.m
//  RevealControllerProject3
//
//  Created by Joan on 30/12/12.
//
//

#import "FrontViewControllerImage.h"
#import "SWRevealViewController.h"

@implementation FrontViewControllerImage


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
    
    SWRevealViewController *revealController = self.revealViewController;
    
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_button addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

@end
