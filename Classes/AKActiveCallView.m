//
//  AKActiveCallView.m
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AKActiveCallView.h"


@implementation AKActiveCallView

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSCharacterSet *DTMFCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"];
    NSCharacterSet *commandsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"mh"];
    
    unichar firstCharacter = [[theEvent characters] characterAtIndex:0];
    if ([DTMFCharacterSet characterIsMember:firstCharacter]) {
        if (![theEvent isARepeat]) {
            // We want to get DTMF string as text.
            [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
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
