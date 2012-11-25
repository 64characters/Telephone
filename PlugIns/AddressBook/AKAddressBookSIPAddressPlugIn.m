//
//  AKAddressBookSIPAddressPlugIn.m
//  AKAddressBookSIPAddressPlugIn
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

#import "AKAddressBookSIPAddressPlugIn.h"

#import "AKABRecord+Querying.h"


@implementation AKAddressBookSIPAddressPlugIn

@synthesize lastSIPAddress = lastSIPAddress_;
@synthesize lastFullName = lastFullName_;
@synthesize shouldDial = shouldDial_;

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    [self setShouldDial:NO];
    
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(workspaceDidLaunchApplication:)
                               name:NSWorkspaceDidLaunchApplicationNotification
                             object:nil];
    
    return self;
}

- (void)dealloc {
    [lastSIPAddress_ release];
    [lastFullName_ release];
    
    [super dealloc];
}

// This plug-in handles emails.
- (NSString *)actionProperty {
    return kABEmailProperty;
}

- (NSString *)titleForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.tlphn.TelephoneAddressBookSIPAddressPlugIn"];
    
    return NSLocalizedStringFromTableInBundle(@"Dial with Telephone", nil, bundle, @"Action title.");
}

- (void)performActionForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    NSArray *applications = [[NSWorkspace sharedWorkspace] runningApplications];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == 'com.tlphn.Telephone'"];
    applications = [applications filteredArrayUsingPredicate:predicate];
    BOOL isTelephoneLaunched = [applications count] > 0;
    
    ABMultiValue *emails = [person valueForProperty:[self actionProperty]];
    NSString *anEmail = [emails valueForIdentifier:identifier];
    NSString *fullName = [person ak_fullName];
    
    if (!isTelephoneLaunched) {
        [[NSWorkspace sharedWorkspace] launchApplication:@"Telephone"];
        [self setShouldDial:YES];
        [self setLastSIPAddress:anEmail];
        [self setLastFullName:fullName];
        
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  anEmail, @"AKSIPAddress",
                                  fullName, @"AKFullName",
                                  nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName:AKAddressBookDidDialSIPAddressNotification
                       object:@"AddressBook"
                     userInfo:userInfo];
    }
}

- (BOOL)shouldEnableActionForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    ABMultiValue *emails = [person valueForProperty:[self actionProperty]];
    NSString *label = [emails labelForIdentifier:identifier];
    
    // Enable the action only if label is |sip|.
    if ([label caseInsensitiveCompare:@"sip"] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

- (void)workspaceDidLaunchApplication:(NSNotification *)notification {
    NSRunningApplication *application = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    NSString *bundleIdentifier = [application bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"com.tlphn.Telephone"] && [self shouldDial]) {
        [self setShouldDial:NO];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self lastSIPAddress], @"AKSIPAddress",
                                  [self lastFullName], @"AKFullName",
                                  nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName:AKAddressBookDidDialSIPAddressNotification
                       object:@"AddressBook"
                     userInfo:userInfo];
    }
}

@end
