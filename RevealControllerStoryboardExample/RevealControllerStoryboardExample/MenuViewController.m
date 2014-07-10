//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import "MenuViewController.h"
#import "ColorViewController.h"

@implementation SWUITableViewCell
@end

@implementation MenuViewController

- (void) prepareForSegue:(UIStoryboardSegue *) segue sender:(id) sender;{
    
    UIViewController* destination = segue.destinationViewController;

    SWRevealViewControllerSegue* revealSegue = (SWRevealViewControllerSegue*) segue;
    
    SWRevealViewController* revealVC = self.revealViewController;
    
    UINavigationController *frontNavigationController = (UINavigationController*)revealVC.frontViewController;
    NSAssert([frontNavigationController isKindOfClass:[UINavigationController class]], @"Incorrect storyboard configuration - you must have a NavController");
    UIViewController* currentFrontView = [[frontNavigationController viewControllers] firstObject];
    
    BOOL replaceVC = YES;
    if([destination isKindOfClass: [currentFrontView class]]) {
        // Note that this check may not be enough in your code - if you have a menu item that configures the same
        // viewController in many ways, you may also have to inspect segue.identifier as well as the destination class..
        replaceVC = NO;
        
        //ensure that the colour config code updates the correct viewController if we are not going to perform the switch
        destination = currentFrontView;
    }
    

    // configure the "destination" view controller:
    if ( [destination isKindOfClass: [ColorViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        UILabel* c = [(SWUITableViewCell *)sender label];
        ColorViewController* cvc = (ColorViewController*)destination;
        cvc.color = c.textColor;
        cvc.text = c.text;
    }
    

    // configure the segue to move to our new frontVC
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        NSAssert( revealVC != nil, @"revealViewController is not set in the menu controller" );
        revealSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            if(replaceVC) {
                // Do not replace the frontmost VC if we are transitioning to a VC that is already showing.
                // This means that the destination VC from the segue is not pushed. The segue code is OK with this and
                // The VC it created as destination gets cleaned up.
                [frontNavigationController setViewControllers:@[destination] animated:NO];
            }
            
            [revealVC revealToggle:self];
        };
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"map";
            break;
            
        case 1:
            CellIdentifier = @"blue";
            break;

        case 2:
            CellIdentifier = @"red";
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
 
    return cell;
}

@end
