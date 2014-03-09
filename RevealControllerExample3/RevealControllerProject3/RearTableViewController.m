//
//  RearTableViewController.m
//  RevealControllerProject3
//
//  Created by Joan on 30/12/12.
//
//

#import "RearTableViewController.h"

#import "SWRevealViewController.h"

#import "FrontViewControllerImage.h"
#import "FrontViewControllerLabel.h"


@implementation RearTableViewController
{
    NSInteger _previouslySelectedRow;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SWRevealViewController *revealController = self.revealViewController;
    SWRevealViewController *grandParentRevealController = revealController.revealViewController;
    
    [self.view addGestureRecognizer:grandParentRevealController.panGestureRecognizer];
    
    
   // self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    
    //[_button addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    NSLog( @"%@: %d", NSStringFromSelector(_cmd), animated);
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//
//    NSLog( @"%@: %d", NSStringFromSelector(_cmd), animated);
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//
//    NSLog( @"%@: %d", NSStringFromSelector(_cmd), animated);
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//
//    NSLog( @"%@: %d", NSStringFromSelector(_cmd), animated);
//}


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
        case 0: text = @"Image 1"; break;
        case 1: text = @"Image 2"; break;
        case 2: text = @"Image 3"; break;
        case 3: text = @"Label 1"; break;
        case 4: text = @"Label 2"; break;
        case 5: text = @"Label 3"; break;
   }
   
    cell.textLabel.text = text;
    return cell;
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
        case 3: text = @"Hello World!"; break;
        case 4: text = @"Hello America!"; break;
        case 5: text = @"Best Wishes!"; break;
   }
    
    UIViewController *frontController = nil;
    switch ( row )
    {
        case 0:
        case 1:
        case 2:
            frontController = [[FrontViewControllerImage alloc] init];
            ((FrontViewControllerImage*)frontController).image = [UIImage imageNamed:text];
            break;
            
        case 3:
        case 4:
        case 5:
            frontController = [[FrontViewControllerLabel alloc] init];
            ((FrontViewControllerLabel*)frontController).text = text;
            break;
    }
    
    [revealController pushFrontViewController:frontController animated:YES];
}

@end
