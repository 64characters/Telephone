//
//  EndedCallViewController.m
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

#import "EndedCallViewController.h"

#import "CallController.h"


@implementation EndedCallViewController

@synthesize callController = callController_;

@synthesize displayedNameField = displayedNameField_;
@synthesize statusField = statusField_;
@synthesize redialButton = redialButton_;

- (id)initWithNibName:(NSString *)nibName callController:(CallController *)callController {
    self = [super initWithNibName:nibName bundle:nil windowController:callController];
    
    if (self != nil) {
        [self setCallController:callController];
    }
    return self;
}

- (id)init {
    [self dealloc];
    NSString *reason = @"Initialize EndedCallViewController with initWithCallController:";
    @throw [NSException exceptionWithName:@"AKBadInitCall" reason:reason userInfo:nil];
    return nil;
}

- (void)dealloc {
    [displayedNameField_ release];
    [statusField_ release];
    [redialButton_ release];
    
    [super dealloc];
}

- (void)removeObservations {
    [[self displayedNameField] unbind:NSValueBinding];
    [[self statusField] unbind:NSValueBinding];
    [super removeObservations];
}

- (void)awakeFromNib {
    [[[self displayedNameField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[[self statusField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
}

- (IBAction)redial:(id)sender {
    [[self callController] redial];
}

- (void)enableRedialButtonTick:(NSTimer *)theTimer {
    [[self redialButton] setEnabled:YES];
}

@end
