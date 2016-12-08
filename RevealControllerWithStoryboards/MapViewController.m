/* 
 * Copyright (c) 2011, Nehira.com
 * All rights reserved.
 * 
 * @author Philip Kluz
 * @project ZUUIRevealController 0.9.5 Tutorial
 * @date 07.02.2012
 */

#import "MapViewController.h"
#import "SWRevealViewController.h"

@implementation MapViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Map View", nil);
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
        style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
}


@end