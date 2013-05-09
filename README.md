# SWRevealViewController

A UIViewController subclass for presenting two view controllers inspired on the FaceBook app, done right!

## Features

* A Reveal view controller implemented using view controller containment, done right!.
* API is easier than a UINavigationController.
* Supports any combination of Left/Right rear controllers.
* Correctly handles appearance methods on its child controllers that you can rely on.
* Correctly handles rotations.
* Can be embedded as a child view controller of other controllers or deployed as the rootViewController.
* Plays nicely with any child view controllers or parent controllers.
* Can be deployed as a child of itself to create cascade like, hierarchical interfaces.
* Seamless integration of pan gesture recognizer, behaving as smooth as silk.
* Includes a category method of UIViewController 'revealViewController' to get the parent SWRevealViewController of any child controller. Similar to the UIViewController's property 'navigationController'.
* Light weight, Clean, Easy to read, self explaining code you will enjoy using in your projects.


![Dynamic](https://raw.github.com/John-Lluch/SWRevealViewController/master/SWRevealViewController3.png)
![Dynamic](https://raw.github.com/John-Lluch/SWRevealViewController/master/SWRevealViewController.png)


## Requirements

* iOS 6.0 or later, tested to work fine on iOS 5.1 as well.
* ARC memory management.

## Usage

* Copy the following to your project:
   * SWRevealViewController.h
   * SWRevealViewController.m


* Initialize an instance of a SWRevealViewController passing in a "rear" and a "front" view controllers.
* Use the SWRevealViewController instance in your code as you would use any view controller.
* Deploy as the application window rootViewController, or as a child of other containment controllers.
* Add the panGestureRecognized provided by the SWRevealViewController to a suitable view of your "front" view controller, for example use the viewDidLoad method of your controller to add the gesture recognizer to a navigationBar.
* At any time, you can reveal, conceal the "rear" view or replace the "front" view controller, programmatically or based on user actions, with or without animations enabled

## Basic API description

Initializing a SWRevealViewController:

    - (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;

Setting the right view controller

	@property (strong, nonatomic) UIViewController *rightViewController;
	
Animated setting of the front view controller:

    - (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

Animating the position of the front view controller. Position can be: FrontViewPositionLeftSideMostRemoved, FrontViewPositionLeftSideMost, FrontViewPositionLeftSide, FrontViewPositionLeft, FrontViewPositionRight, FrontViewPositionRightMost or FrontViewPositionRightMostRemoved

	- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated;
	
Obtaining a gesture recognizer to add to your front view controller:

	- (UIPanGestureRecognizer*)panGestureRecognizer;
	
Other methods are documented in the SWRevealViewController.h header file. 
	
## License

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

Early code inspired on a similar class by Philip Kluz (Philip.Kluz@zuui.org)
