//
//  RearMasterTableViewController.m
//  RevealControllerProject3
//
//  Created by Joan on 30/12/12.
//
//

#import "RearMasterTableViewController.h"

#import "SWRevealViewController.h"

#import "FrontViewControllerImage.h"
#import "FrontViewControllerLabel.h"
#import "RearTableViewController.h"


@implementation RearMasterTableViewController
{
    NSInteger _previouslySelectedRow;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.5 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _previouslySelectedRow = -1;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *text = nil;
    switch ( indexPath.row )
    {
        case 0: text = @"heart.png"; break;
        case 1: text = @"skull.png"; break;
        case 2: text = @"gift.png"; break;
        case 3: text = @"airplane.png"; break;
        case 4: text = @"star.png"; break;
        case 5: text = @" ...  More"; break;
   }
   
    cell.imageView.image = [UIImage imageNamed:text];
    cell.imageView.frame = CGRectMake(0,0,44,44);
    cell.textLabel.text = text;
    cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.tableView.backgroundColor;

}

#pragma mark - Table view delegate





- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SWRevealViewController *revealController = self.revealViewController;
    
    NSInteger row = indexPath.row;
    
    if ( row == _previouslySelectedRow )
    {
        [revealController revealToggleAnimated:YES];
        return;
    }
    
    _previouslySelectedRow = row;
    
    NSString *text = nil;
    switch ( row )
    {
        case 0: text = @"bg_flowers.jpg"; break;
        case 1: text = @"bg_blocks.jpg"; break;
        case 2: text = @"bg_grass.jpg"; break;
        case 3: text = @"Hello America!"; break;
        case 4: text = @"Best Wishes!"; break;
   }
    
    UIViewController *frontController = nil;
    switch ( row )
    {
        case 0:
        case 1:
        case 2:
        {
            FrontViewControllerImage *imageController = [[FrontViewControllerImage alloc] init];
            imageController.image = [UIImage imageNamed:text];
            frontController = imageController;
            break;
        }
        
        case 3:
        case 4:
        {
            FrontViewControllerLabel *labelController = [[FrontViewControllerLabel alloc] init];
            labelController.text = text;
            frontController = labelController;
            break;
        }
        
        case 5:
        {
            RearTableViewController *rearViewController = [[RearTableViewController alloc] init];
            FrontViewControllerImage *frontViewController = [[FrontViewControllerImage alloc] init];
            [frontViewController setImage:[UIImage imageNamed:@"bg_flowers.jpg"]];
    
            SWRevealViewController *childRevealController =
                [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
            
#define NoRevealOverdraw true
#if NoRevealOverdraw
            childRevealController.rearViewRevealWidth = 60;
            childRevealController.rearViewRevealOverdraw = 120;
            childRevealController.bounceBackOnOverdraw = NO;
            childRevealController.stableDragOnOverdraw = YES;
#else
            childRevealController.rearViewRevealWidth = 200;
#endif
            childRevealController.rearViewRevealDisplacement = 0;
            
            [childRevealController setFrontViewPosition:FrontViewPositionRight animated:NO];
            frontController = childRevealController;
            break;
        }
    }
    
    if ( row != 5 )
    {
        [revealController setFrontViewController:frontController animated:YES];    //sf
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
    }
    else
    {
        [revealController setFrontViewController:frontController animated:YES];    //sf
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }
}

@end
