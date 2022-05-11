//
//  AKActiveCallView.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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


@protocol AKActiveCallViewDelegate;

// The AKActiveCallView class receives DTMF digits |0123456789*#| and control characters |mh| from the keyboard. It
// gives its delegate a chance to get those DTMF digits and it sends control characters further.
@interface AKActiveCallView : NSView

// The receiver's delegate.
@property(nonatomic, weak) IBOutlet id <AKActiveCallViewDelegate> delegate;

@end

// Declares the interface that AKActiveCallView delegates must implement.
@protocol AKActiveCallViewDelegate <NSObject>
@optional
// Sent when a view receives text input from the keyboard.
// Now it handles only DTMF digits |0123456789*#|.
- (void)activeCallView:(AKActiveCallView *)sender didReceiveText:(NSString *)aString;
@end
