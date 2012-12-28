# SWRevealViewController

A UIViewController subclass for presenting two view controllers inspired on the FaceBook app, done right!

## Features

* Reveal view controller implemented using view controller containment, done right!.
* API is easier than a UINavigationController.
* Correctly handles appearance methods on its child controllers that you can rely on.
* Correctly handles rotations.
* Can be embedded as a child view controller of other controllers, it always works, no glitches, no interface artifacts, no initialization issues, no rotation or resizing problems.
* Seamless integration of pan gesture recognizer, behaving as smooth as silk.
* Includes a category method of UIViewController 'revealViewController' to get the parent SWRevealViewController of any child controller. Similar to the UIViewController's property 'navigationController'.
* Light weight, Clean, Easy to read, self explaining code you will enjoy using in your projects.


![Dynamic](https://raw.github.com/Joan-Lluch/SWRevealViewController/master/SWRevealViewController.png)


## Requirements

* iOS 6.0 or later
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
	
Setting or changing the front view controller:

    - (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

Setting the position of the front view controller. Position can be FrontViewPositionLeft, FrontViewPositionRight, FrontViewPositionRightMost or FrontViewPositionRightMostHidden:

	- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated;
	
Obtaining a gesture recognizer to add to your front view controller:

	- (UIPanGestureRecognizer*)panGestureRecognizer;
	
Other methods are documented in the SWRevealViewController.h header file. 
	
## License

Copyright (c) 2012, John Lluch-Zorrilla (joan.lluch@sweetwilliamsl.com)
Inspired on a similar class by Philip Kluz (Philip.Kluz@zuui.org)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of John Lluch, 'sweetwilliamsl.com' nor the names of its contributors may 
be used to endorse or promote products derived from this software 
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JOHN LLUCH BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
