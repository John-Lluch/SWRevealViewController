//
//  FrontViewControllerBlocksViewController.m
//  RevealControllerProject3
//
//  Created by Joan on 30/12/12.
//
//

#import "FrontViewControllerLabel.h"
#import "SWRevealViewController.h"

@implementation FrontViewControllerLabel


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label.text = _text;
    
    SWRevealViewController *revealController = self.revealViewController;
    
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_button addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}


@end
