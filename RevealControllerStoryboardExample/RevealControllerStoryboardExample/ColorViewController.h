//
//  ColorViewController.h
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel* label;

-(void)setColor:(UIColor*)aColor;
-(void)setText:(NSString*)aString;
@end
