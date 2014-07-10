//
//  ColorViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import "ColorViewController.h"

@interface ColorViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (strong, nonatomic) UIColor* color;
@property (strong, nonatomic) NSString* text;
@end

@implementation ColorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _label.text = _text;
    _label.textColor = _color;

    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector( revealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
}

-(void)setText:(NSString*)aString{
    _text = aString;
    _label.text = _text;

};

-(void)setColor:(UIColor *)aColor{
    _color = aColor;
    _label.textColor = _color;
};
@end
