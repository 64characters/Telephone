//
//  AKResponsiveProgressIndicator.h
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import <Cocoa/Cocoa.h>


// Allows progress indicator to send an action message to a target on mouse-up events.
@interface AKResponsiveProgressIndicator : NSProgressIndicator

// The receiver's target.
@property(nonatomic, weak) id target;

// The receiver's action-message selector.
@property(nonatomic, assign) SEL action;

@end
