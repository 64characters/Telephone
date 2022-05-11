//
//  ActiveAccountTransferViewController.m
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

#import "ActiveAccountTransferViewController.h"

#import "AccountController.h"


@implementation ActiveAccountTransferViewController

- (instancetype)initWithAccountController:(AccountController *)accountController {
    NSParameterAssert(accountController);
    if ((self = [super initWithNibName:@"ActiveAccountTransferView" bundle:nil])) {
        _accountController = accountController;
    }
    return self;
}

- (IBAction)makeCallToTransferDestination:(id)sender {
    if ([[[self callDestinationField] objectValue] count] == 0) {
        return;
    }
    
    NSDictionary *callDestinationDict = [[self callDestinationField] objectValue][0][[self callDestinationURIIndex]];
    NSString *phoneLabel = callDestinationDict[kPhoneLabel];
    
    AKSIPURI *uri = [self callDestinationURI];
    if (uri != nil) {
        [[self accountController] makeCallToURI:uri
                                     phoneLabel:phoneLabel
                         callTransferController:(CallTransferController *)[[sender window] windowController]];
    }
}

- (IBAction)makeCall:(id)sender {
    return;
}

@end
