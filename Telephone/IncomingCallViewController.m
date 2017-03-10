//
//  IncomingCallViewController.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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

#import "IncomingCallViewController.h"

#import "AppController.h"
#import "CallController.h"


@implementation IncomingCallViewController

@synthesize callController = callController_;

- (instancetype)initWithCallController:(CallController *)callController {
    self = [super initWithNibName:@"IncomingCallView" bundle:nil];
    
    if (self != nil) {
        [self setCallController:callController];
    }
    return self;
}

- (instancetype)init {
    NSString *reason = @"Initialize IncomingCallViewController with initWithCallController:";
    @throw [NSException exceptionWithName:@"AKBadInitCall" reason:reason userInfo:nil];
    return nil;
}

- (void)removeObservations {
    [[self displayedNameField] unbind:NSValueBinding];
    [[self statusField] unbind:NSValueBinding];
}

- (void)awakeFromNib {
    [[[self displayedNameField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[[self statusField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
}

- (IBAction)acceptCall:(id)sender {
    [[self callController] acceptCall];
}

- (IBAction)hangUpCall:(id)sender {
    [[self callController] hangUpCall];
}


#pragma mark -
#pragma mark NSMenuValidation protocol

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(hangUpCall:)) {
        [menuItem setTitle:NSLocalizedString(@"Decline", @"Decline. Call menu item.")];
    }
    
    return YES;
}

@end
