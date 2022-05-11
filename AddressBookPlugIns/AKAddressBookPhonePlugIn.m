//
//  AKAddressBookPhonePlugIn.m
//  AKAddressBookPhonePlugIn
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

#import "AKAddressBookPhonePlugIn.h"

#import "AKABRecord+Querying.h"


@implementation AKAddressBookPhonePlugIn

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


// This plug-in handles phone numbers.
- (NSString *)actionProperty {
    return kABPhoneProperty;
}

- (NSString *)titleForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.tlphn.TelephoneAddressBookPhonePlugIn"];
    
    return NSLocalizedStringFromTableInBundle(@"Dial with Telephone", nil, bundle, @"Action title.");
}

- (void)performActionForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    NSArray *applications = [[NSWorkspace sharedWorkspace] runningApplications];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == 'com.tlphn.Telephone'"];
    applications = [applications filteredArrayUsingPredicate:predicate];
    BOOL isTelephoneLaunched = [applications count] > 0;
    
    ABMultiValue *phones = [person valueForProperty:[self actionProperty]];
    NSString *phoneNumber = [phones valueForIdentifier:identifier];
    NSString *fullName = [person ak_fullName];
    
    if (!isTelephoneLaunched) {
        [[NSWorkspace sharedWorkspace] launchApplication:@"Telephone"];
        [self setShouldDial:YES];
        [self setLastPhoneNumber:phoneNumber];
        [self setLastFullName:fullName];
        
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  phoneNumber, @"AKPhoneNumber",
                                  fullName, @"AKFullName",
                                  nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName:AKAddressBookDidDialPhoneNumberNotification
                       object:@"AddressBook"
                     userInfo:userInfo];
    }
}

- (BOOL)shouldEnableActionForPerson:(ABPerson *)person identifier:(NSString *)identifier {
    return YES;
}

- (void)workspaceDidLaunchApplication:(NSNotification *)notification {
    NSRunningApplication *application = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    NSString *bundleIdentifier = [application bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"com.tlphn.Telephone"] && [self shouldDial]) {
        [self setShouldDial:NO];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self lastPhoneNumber], @"AKPhoneNumber",
                                  [self lastFullName], @"AKFullName",
                                  nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName:AKAddressBookDidDialPhoneNumberNotification
                       object:@"AddressBook"
                     userInfo:userInfo];
    }
}

@end
