//
//  PJSUAOnAccountRegistrationState.m
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

#import "PJSUACallbacks.h"

#import "AKSIPAccount.h"
#import "AKSIPUserAgent.h"

void PJSUAOnAccountRegistrationState(pjsua_acc_id accountID) {
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPAccount *account = [[AKSIPUserAgent sharedUserAgent] accountWithIdentifier:accountID];
        [account.delegate SIPAccountRegistrationDidChange:account];
    });
}
