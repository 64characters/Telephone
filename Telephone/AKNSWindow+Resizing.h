//
//  AKNSWindow+Resizing.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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


// A category for window resizing.
@interface NSWindow (AKWindowResizingAdditions)

// Sets |aView| content view for the receiver and resizes the receiver with optional animation.
- (void)ak_resizeAndSwapToContentView:(NSView *)aView animate:(BOOL)performAnimation;

// Calls |ak_resizeAndSwapToContentView:animate:| with |performAnimation| set to NO.
- (void)ak_resizeAndSwapToContentView:(NSView *)aView;

@end
