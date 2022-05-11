//
//  AKActiveCallView.m
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

#import "AKActiveCallView.h"


@implementation AKActiveCallView

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSCharacterSet *DTMFCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#abcdrABCDR"];
    NSCharacterSet *commandsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"mh"];
    
    unichar firstCharacter = [[theEvent characters] characterAtIndex:0];
    if ([DTMFCharacterSet characterIsMember:firstCharacter]) {
        if (![theEvent isARepeat]) {
            // We want to get DTMF string as text.
            [self interpretKeyEvents:@[theEvent]];
        }
    } else if ([commandsCharacterSet characterIsMember:firstCharacter]) {
        if (![theEvent isARepeat]) {
            // Pass call control commands further so that main menu will catch them.
            // The corresponding key equivalents must be set in the main menu.
            // We need this because we have key equivalents without modifiers,
            // in which case NSApplication can't recognize them and can't dispatch
            // appropriate events before we even get here.
            [super keyDown:theEvent];
        }
    } else {
        [super keyDown:theEvent];
    }
}

- (void)insertText:(id)aString {
    if ([[self delegate] respondsToSelector:@selector(activeCallView:didReceiveText:)]) {
        [[self delegate] activeCallView:self didReceiveText:aString];
    }
}

@end
