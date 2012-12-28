# SWRevealViewController - A FaceBook like Reveal View Controller, done right !

A UIViewController subclass for presenting two view controllers inspired in the FaceBook app, done right!

## Features

* Tab controller implemented using view controller containment
* API is easier than UINavigationController
* Correctly handles appearance methods on the provided child controllers
* Correctly handles rotations
* Can be embedded in other controllers, it always works, no glitches, no interface artifacts, no initialization issues, no rotation or resizing problems
* Seamless integrated pan gesture support behaving as smooth as silk.
* Includes a category method of UIViewController, 'revealViewController', to get the parent SWRevealViewController, similar to the UIViewController's property 'navigationController'

## Requirements

* iOS 6.0 or later
* ARC memory management.

## Usage

* Copy the following to your project:
    * SWRevealViewController.h
    * SWRevealViewController.m
    
* Initialize an instance of a SWRevealViewController with a "rear" and "front" view controllers
* Use the SWRevealViewController instance in your code as you would use any containment controller
* Add the panGestureRecognized provided by the SWRevealViewController to your "front" view controller 
* You can change the "front" view controller at any time, even with animation

## Basic API

Initializing a SWRevealViewController:

    - (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;
	
Setting, changing the front view controller

    - (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

Setting the position of the front view controller, can be FrontViewPositionLeft, FrontViewPositionRight, FrontViewPositionRightMost or FrontViewPositionRightMostHidden

	- (void)setFrontViewPosition:(FrontViewPosition)frontViewPosition animated:(BOOL)animated;
	
Obtaining a gesture recognizer to add to your front view controller

	- (UIPanGestureRecognizer*)panGestureRecognizer;
	
	
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
DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.