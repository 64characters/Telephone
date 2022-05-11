//
//  AccountController.m
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

#import "AccountController.h"

@import AddressBook;
@import UseCases;

#import "AKABAddressBook+Localizing.h"
#import "AKKeychain.h"
#import "AKNetworkReachability.h"
#import "AKNSString+Scanning.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountControllerToAccountAdapter.h"
#import "AccountViewController.h"
#import "AccountWindowController.h"
#import "ActiveAccountViewController.h"
#import "AuthenticationFailureController.h"
#import "CallTransferController.h"
#import "SIPResponseLocalization.h"

#import "Telephone-Swift.h"

NSString * const kEmailSIPLabel = @"sip";
static NSString * const kRussian = @"ru";

@interface AccountController () <AccountWindowControllerDelegate>

@property(nonatomic) AKNetworkReachability *registrarReachability;

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;
@property(nonatomic, readonly) WorkspaceSleepStatus *sleepStatus;

@property(nonatomic, readonly) AuthenticationFailureController *authenticationFailureController;

@property(nonatomic, readonly) AccountViewController *accountViewController;
@property(nonatomic, readonly) AccountWindowController *windowController;

@property(nonatomic, readonly, getter=isAccountAdded) BOOL accountAdded;
@property(nonatomic, strong) NSTimer *reRegistrationTimer;
@property(nonatomic, copy) NSString *destinationToCall;

@end

@implementation AccountController

@synthesize authenticationFailureController = _authenticationFailureController;

- (void)setEnabled:(BOOL)flag {
    _enabled = flag;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (flag) {
        AKNetworkReachability *reachability
            = [AKNetworkReachability networkReachabilityWithHost:self.account.registrar.host];
        [self setRegistrarReachability:reachability];
        
        if (reachability != nil) {
            [notificationCenter addObserver:self
                                   selector:@selector(networkReachabilityDidBecomeReachable:)
                                       name:AKNetworkReachabilityDidBecomeReachableNotification
                                     object:reachability];
        }
    } else {
        if ([self registrarReachability] != nil) {
            [notificationCenter removeObserver:self
                                          name:AKNetworkReachabilityDidBecomeReachableNotification
                                        object:[self registrarReachability]];
            
            [self setRegistrarReachability:nil];
        }
    }
}

- (BOOL)isAccountRegistered {
    return [[self account] isRegistered];
}

- (void)setAccountRegistered:(BOOL)flag {
    [self invalidateReRegistrationTimer];

    if ([self isAccountAdded]) {
        [self showConnectingState];
        
        [[self account] setRegistered:flag];
        
    } else {
        NSString *serviceName = [NSString stringWithFormat:@"SIP: %@", [[self account] registrar]];
        NSString *password = [AKKeychain passwordForService:serviceName account:[[self account] username]];
        
        [self showConnectingState];
        
        BOOL accountAdded = [[self userAgent] addAccount:[self account] withPassword:password];
        
        // Error connecting to registrar.
        if (accountAdded &&
            ![self isAccountRegistered] &&
            [[self account] registrationExpireTime] == kAKSIPAccountRegistrationExpireTimeNotSpecified &&
            [[self userAgent] isStarted]) {
            
            [self showUnavailableState];
            
            // Schedule account automatic re-registration timer.
            if ([self reRegistrationTimer] == nil) {
                NSTimeInterval reregistrationTimeInterval = (NSTimeInterval)[[self account] reregistrationTime];
                
                [self setReRegistrationTimer:
                 [NSTimer scheduledTimerWithTimeInterval:reregistrationTimeInterval
                                                  target:self
                                                selector:@selector(reRegistrationTimerTick:)
                                                userInfo:nil
                                                 repeats:YES]];
            }
            
            if ([self shouldPresentRegistrationError]) {
                NSString *statusText;
                NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
                if ([preferredLocalization isEqualToString:kRussian]) {
                    statusText = LocalizedStringForSIPResponseCode([[self account] registrationStatus]);
                } else {
                    statusText = [[self account] registrationStatusText];
                }
                
                NSString *error;
                if (statusText == nil) {
                    error = [NSString stringWithFormat:
                             NSLocalizedString(@"Error %ld", @"Error #."),
                             [[self account] registrationStatus]];
                    error = [error stringByAppendingString:@"."];
                } else {
                    error = [NSString stringWithFormat:
                             NSLocalizedString(@"The error was: “%ld %@”.", @"Error description."),
                             [[self account] registrationStatus], statusText];
                }
                
                [self showRegistrarConnectionErrorSheetWithError:error];
            }
            
            [self setShouldPresentRegistrationError:NO];
        }
    }
}

- (BOOL)isAccountAdded {
    return self.account.identifier != kAKSIPUserAgentInvalidIdentifier;
}

- (AuthenticationFailureController *)authenticationFailureController {
    if (_authenticationFailureController == nil) {
        _authenticationFailureController
            = [[AuthenticationFailureController alloc] initWithAccountController:self userAgent:self.userAgent];
    }
    
    return _authenticationFailureController;
}

- (BOOL)canMakeCalls {
    return self.windowController.allowsCallDestinationInput;
}

- (instancetype)initWithSIPAccount:(AKSIPAccount *)account
                accountDescription:(NSString *)accountDescription
                         userAgent:(AKSIPUserAgent *)userAgent
                  ringtonePlayback:(id<RingtonePlaybackUseCase>)ringtonePlayback
                       sleepStatus:(WorkspaceSleepStatus *)sleepStatus
 callHistoryViewEventTargetFactory:(AsyncCallHistoryViewEventTargetFactory *)callHistoryViewEventTargetFactory
       purchaseCheckUseCaseFactory:(AsyncCallHistoryPurchaseCheckUseCaseFactory *)purchaseCheckUseCaseFactory
              storeWindowPresenter:(StoreWindowPresenter *)storeWindowPresenter{

    self = [super init];
    if (self == nil) {
        return nil;
    }

    _account = account;
    _account.delegate = self;
    _userAgent = userAgent;
    _ringtonePlayback = ringtonePlayback;
    _sleepStatus = sleepStatus;

    _callControllers = [[NSMutableArray alloc] init];
    _accountDescription = [accountDescription copy];
    _destinationToCall = @"";

    _accountViewController
    = [[AccountViewController alloc] initWithActiveAccountViewController:[[ActiveAccountViewController alloc] initWithAccountController:self]
                                               callHistoryViewController:[[CallHistoryViewController alloc] init]
                                       callHistoryViewEventTargetFactory:callHistoryViewEventTargetFactory
                                             purchaseCheckUseCaseFactory:purchaseCheckUseCaseFactory
                                                                 account:[[AccountControllerToAccountAdapter alloc] initWithController:self]
                                                    storeWindowPresenter:storeWindowPresenter];
    _windowController = [[AccountWindowController alloc] initWithAccountDescription:_accountDescription
                                                                         SIPAddress:_account.SIPAddress
                                                              accountViewController:_accountViewController
                                                                           delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SIPUserAgentDidFinishStarting:)
                                                 name:AKSIPUserAgentDidFinishStartingNotification
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    for (CallController *aCallController in [self callControllers]) {
        [aCallController close];
    }
    
    if ([[[self account] delegate] isEqual:self]) {
        [[self account] setDelegate:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Close authentication failure sheet if it's raised.
    [[_authenticationFailureController cancelButton] performClick:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ controller", [self account]];
}

- (void)registerAccount {
    if (![[self userAgent] isStarted]) {
        [self setAttemptingToRegisterAccount:YES];
    }
    [self setAccountRegistered:YES];
}

- (void)unregisterAccount {
    if (![self isAccountAdded]) {
        [self setAttemptingToUnregisterAccount:YES];
    }
    [self setAccountRegistered:NO];
}

- (void)removeAccountFromUserAgent {
    NSAssert([self isEnabled], @"Account conroller must be enabled to remove account from the user agent.");
    [self invalidateReRegistrationTimer];
    [self showOfflineState];
    [[self userAgent] removeAccount:[self account]];
}

- (void)makeCallToURI:(AKSIPURI *)destinationURI
        phoneLabel:(NSString *)phoneLabel
        callTransferController:(CallTransferController *)callTransferController {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
    [telephoneNumberFormatter setSplitsLastFourDigits:
     [defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
    
    NSString *enteredCallDestinationString = [[destinationURI user] copy];
    
    // Make user part a string of contiguous digits if needed.
    if (![[destinationURI user] ak_hasLetters]) {
        [destinationURI setUser:[telephoneNumberFormatter telephoneNumberFromString:[destinationURI user]]];
    }
    
    // Replace plus character if needed.
    if ([self substitutesPlusCharacter] &&
        [[destinationURI user] hasPrefix:@"+"]) {
        [destinationURI setUser:[[destinationURI user]
                                 stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                         withString:[self plusCharacterSubstitution]]];
        enteredCallDestinationString = [enteredCallDestinationString
                                        stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                withString:[self plusCharacterSubstitution]];
    }
    
    // If it's a regular call, not a transfer, create the new CallController.
    CallController *aCallController;
    if (callTransferController == nil) {
        aCallController = [[CallController alloc] initWithWindowNibName:@"Call"
                                                      accountController:self
                                                              userAgent:self.userAgent
                                                               delegate:self];
    } else {
        aCallController = callTransferController;
    }
    
    [aCallController setNameFromAddressBook:[destinationURI displayName]];
    [aCallController setPhoneLabelFromAddressBook:phoneLabel];
    [aCallController setEnteredCallDestination:enteredCallDestinationString];
    [[self callControllers] addObject:aCallController];
    
    // Set title.
    if ([[destinationURI host] length] > 0) {
        [aCallController setTitle:[destinationURI SIPAddress]];
        
    } else if (![enteredCallDestinationString ak_hasLetters]) {
        if ([enteredCallDestinationString ak_isTelephoneNumber] && [defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]) {
            [aCallController setTitle:[telephoneNumberFormatter stringForObjectValue:enteredCallDestinationString]];
        } else {
            [aCallController setTitle:enteredCallDestinationString];
        }
    } else {
        [aCallController setTitle:[[SIPAddress alloc] initWithUser:destinationURI.user host:self.account.uri.host].stringValue];
    }
    
    // Set displayed name.
    if ([[destinationURI displayName] length] > 0) {
        [aCallController setDisplayedName:[destinationURI displayName]];
        
    } else {
        if ([[destinationURI host] length] > 0) {
            [aCallController setDisplayedName:[destinationURI SIPAddress]];
            
        } else if ([enteredCallDestinationString ak_isTelephoneNumber] &&
                   [defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]) {
            
            [aCallController setDisplayedName:
             [telephoneNumberFormatter stringForObjectValue:enteredCallDestinationString]];
            
        } else {
            [aCallController setDisplayedName:enteredCallDestinationString];
        }
    }
    
    // Clean display-name part of the destination URI to prevent another call
    // party from seeing local Address Book records.
    [destinationURI setDisplayName:@""];
    
    if ([[destinationURI host] length] == 0) {
        [destinationURI setHost:[[[self account] uri] host]];
    }
    
    // Set URI for redial.
    [aCallController setRedialURI:destinationURI];
    
    [aCallController prepareForCall];

    if ([phoneLabel length] > 0) {
        [aCallController setStatus:
         [NSString stringWithFormat:NSLocalizedString(@"calling %@...",
                                                      @"Outgoing call in progress. Calling specific phone "
                                                       "type (mobile, home, etc)."), phoneLabel]];
    } else {
        [aCallController setStatus:NSLocalizedString(@"calling...", @"Outgoing call in progress.")];
    }
    
    if (callTransferController == nil) {
        [aCallController showWindow:self];
    }
    
    // Finally, make a call.
    [self.account makeCallTo:destinationURI completion:^(AKSIPCall *call) {
        if (call != nil) {
            [aCallController setCall:call];
            [aCallController setCallActive:YES];
        } else {
            [aCallController showEndedCallView];
            [aCallController setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
        }
    }];
}

- (void)makeCallToURI:(AKSIPURI *)destinationURI phoneLabel:(NSString *)phoneLabel {
    if (self.isAccountAdded) {
        [self makeCallToURI:destinationURI phoneLabel:phoneLabel callTransferController:nil];
    }
}

- (void)makeCallToDestinationRegisteringAccountIfNeeded:(SanitizedCallDestination *)destination {
    if (![self isAccountAdded]) {
        [self setDestinationToCall:destination.value];
        [self registerAccount];
    } else {
        [self makeCallToDestination:destination.value];
    }
}

- (void)makeCallToDestination:(NSString *)destination {
    [self.windowController makeCallToDestination:destination];
}

- (void)makeCallToSavedDestination {
    [self makeCallToDestination:[self destinationToCall]];
    [self setDestinationToCall:@""];
}

- (void)showWindow {
    [self.windowController showWindow:self];
}

- (void)showWindowWithoutMakingKey {
    [self.windowController showWindowWithoutMakingKey];
}

- (void)hideWindow {
    [self.windowController hideWindow];
}

- (BOOL)isWindowKey {
    return self.windowController.isWindowKey;
}

- (void)orderWindow:(NSWindowOrderingMode)place relativeTo:(NSInteger)otherWindow {
    [self.windowController orderWindow:place relativeTo:otherWindow];
}

- (NSInteger)windowNumber {
    return self.windowController.windowNumber;
}

- (void)changeAccountState:(AccountWindowControllerAccountState)state {
    [self invalidateReRegistrationTimer];
    switch (state) {
        case AccountWindowControllerAccountStateOffline:
            self.accountUnavailable = NO;
            [self removeAccountFromUserAgent];
            break;
        case AccountWindowControllerAccountStateAvailable:
            self.accountUnavailable = NO;
            self.shouldPresentRegistrationError = YES;
            [self registerAccount];
            break;
        case AccountWindowControllerAccountStateUnavailable:
            if (self.isAccountRegistered || !self.isAccountAdded) {
                self.accountUnavailable = YES;
                self.shouldPresentRegistrationError = YES;
                [self unregisterAccount];
            }
            break;
    }
}

- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:
                           NSLocalizedString(@"Could not register with %@.", @"Registrar connection error."),
                           [[self account] registrar]]];
    
    if (error == nil) {
        [alert setInformativeText:
         [NSString stringWithFormat:
          NSLocalizedString(@"Please check network connection and Registry Server settings.",
                            @"Registrar connection error informative text."),
          [[self account] registrar]]];
    } else {
        [alert setInformativeText:error];
    }
    
    [self.windowController showAlert:alert];
}


- (void)showAvailableState {
    [self.windowController showAvailableState];
}

- (void)showUnavailableState {
    [self.windowController showUnavailableState];
}

- (void)showOfflineState {
    [self.windowController showOfflineState];
}

- (void)showConnectingState {
    [self.windowController showConnectingState];
}

- (void)reRegistrationTimerTick:(NSTimer *)theTimer {
    [[self account] setRegistered:YES];
}

- (void)invalidateReRegistrationTimer {
    [self.reRegistrationTimer invalidate];
    self.reRegistrationTimer = nil;
}

#pragma mark - AccountWindowControllerDelegate

- (void)accountWindowController:(AccountWindowController *)controller didChangeAccountState:(AccountWindowControllerAccountState)state {
    [self changeAccountState:state];
}


#pragma mark - AKSIPAccountDelegate

// When account registration changes, make appropriate modifications to the UI. A call can also be made from here if
// the user called from the Address Book or from the application URL handler.
- (void)SIPAccountRegistrationDidChange:(AKSIPAccount *)account {
    // The account can be not added if notification on the main thread was delivered after
    // user agent had removed the account. Don't bother in that case.
    if (![self isAccountAdded]) {
        return;
    }
    
    if ([[self account] isRegistered]) {
        [self invalidateReRegistrationTimer];

        // If the account was offline and the user chose Unavailable state, -unregisterAccount will add the account
        // to the user agent. User agent will register the account. Set the account to Unavailable (unregister it) here.
        if ([self attemptingToUnregisterAccount]) {
            [self unregisterAccount];
            
        } else {
            [self setAccountUnavailable:NO];
            [self showAvailableState];
            if ([[self destinationToCall] length] > 0) {
                [self makeCallToSavedDestination];
            }
        }
        
    } else {
        [self showUnavailableState];
        
        // Handle authentication failure
        if ([[self account] registrationStatus] == PJSIP_SC_UNAUTHORIZED &&
            [[self account] registrationErrorCode] == PJSIP_EFAILEDCREDENTIAL) {

            [[[self authenticationFailureController] informativeText] setStringValue:
             [NSString stringWithFormat:
              NSLocalizedString(@"Telephone was unable to login to %@. "
                                 "Change user name or password and try again.",
                                @"Registrar authentication failed."),
              [[self account] registrar]]];
            
            NSString *service = [NSString stringWithFormat:@"SIP: %@", [[self account] registrar]];
            NSString *password = [AKKeychain passwordForService:service account:[[self account] username]];
            
            [[[self authenticationFailureController] usernameField] setStringValue:[[self account] username]];
            [[[self authenticationFailureController] passwordField] setStringValue:password];

            [[self windowController] beginSheet:[[self authenticationFailureController] window]];

        } else if (([[self account] registrationStatus] / 100 != 2) &&
                   ([[self account] registrationExpireTime] == kAKSIPAccountRegistrationExpireTimeNotSpecified)) {
            // Raise a sheet if connection to the registrar failed. If last registration status is 2xx and expiration
            // interval is not specified, it is unregistration, not failure. Condition of failure is: last registration
            // status != 2xx AND expiration interval is not specified.
            
            if ([[self userAgent] isStarted]) {
                if ([self shouldPresentRegistrationError]) {
                    NSString *statusText;
                    NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
                    if ([preferredLocalization isEqualToString:kRussian]) {
                        statusText = LocalizedStringForSIPResponseCode([[self account] registrationStatus]);
                    } else {
                        statusText = [[self account] registrationStatusText];
                    }
                    
                    NSString *error;
                    if (statusText == nil) {
                        error = [NSString stringWithFormat:NSLocalizedString(@"Error %ld", @"Error #."),
                                 [[self account] registrationStatus]];
                        error = [error stringByAppendingString:@"."];
                    } else {
                        error = [NSString stringWithFormat:
                                 NSLocalizedString(@"The error was: “%ld %@”.", @"Error description."),
                                 [[self account] registrationStatus], statusText];
                    }
                    
                    [self showRegistrarConnectionErrorSheetWithError:error];
                    
                } else {
                    // Schedule account automatic re-registration timer.
                    if ([self reRegistrationTimer] == nil) {
                        NSTimeInterval reregistrationTimeInterval = (NSTimeInterval)[[self account] reregistrationTime];
                        
                        [self setReRegistrationTimer:
                         [NSTimer scheduledTimerWithTimeInterval:reregistrationTimeInterval
                                                          target:self
                                                        selector:@selector(reRegistrationTimerTick:)
                                                        userInfo:nil
                                                         repeats:YES]];
                    }
                }
            }
        }
    }
    
    [self setAttemptingToRegisterAccount:NO];
    [self setAttemptingToUnregisterAccount:NO];
    [self setShouldPresentRegistrationError:NO];
}

- (void)SIPAccountWillRemove:(AKSIPAccount *)account {
    [self invalidateReRegistrationTimer];
}

- (void)SIPAccount:(AKSIPAccount *)account didReceiveCall:(AKSIPCall *)aCall {
    if ([self isAccountUnavailable]) {
        // Reply with 480 Temporarily Unavailable if the user selected Unavailable account state.
        [aCall replyWithTemporarilyUnavailable];
        
        return;
        
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultsKeys.callWaiting]) {
        // Reply with 486 Busy Here if needed.
        for (CallController *callController in [self callControllers]) {
            if ([callController isCallActive]) {
                [aCall replyWithBusyHere];
                
                return;
            }
        }
    }
    
    CallController *aCallController = [[CallController alloc] initWithWindowNibName:@"Call"
                                                                  accountController:self
                                                                          userAgent:self.userAgent
                                                                           delegate:self];
    
    [aCallController setCall:aCall];
    [aCallController setCallActive:YES];
    [[self callControllers] addObject:aCallController];
    
    AKSIPURIFormatter *SIPURIFormatter = [[AKSIPURIFormatter alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [SIPURIFormatter setFormatsTelephoneNumbers:[defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]];
    [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
     [defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
    
    // These variables will be changed during the Address Book search if the record is found.
    NSString *finalDisplayedName = [SIPURIFormatter stringForObjectValue:[aCall remoteURI]];
    NSString *finalStatus = NSLocalizedString(@"calling",
                                              @"John Smith calling. Somebody is calling us right "
                                               "now. Call status string. Deliberately in lower case, "
                                               "translators should do the same, if possible.");

    // Search Address Book for caller's name.
    
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    NSArray *records = nil;
    
    ABSearchElement *SIPAddressMatch
        = [ABPerson searchElementForProperty:kABEmailProperty
                                       label:nil
                                         key:nil
                                       value:[[aCall  remoteURI] SIPAddress]
                                  comparison:kABEqualCaseInsensitive];
    
    records = [AB recordsMatchingSearchElement:SIPAddressMatch];
    
    if ([records count] > 0) {
        id theRecord = records[0];
        
        finalDisplayedName = [theRecord ak_fullName];
        [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
        
        NSString *localizedLabel = [AB ak_localizedLabel:kEmailSIPLabel];
        finalStatus = localizedLabel;
        [aCallController setPhoneLabelFromAddressBook:localizedLabel];

    } else if ([[[aCall remoteURI] displayName] ak_isTelephoneNumber] ||
               ([[[aCall remoteURI] displayName] length] == 0 &&
                [[[aCall remoteURI] user] ak_isTelephoneNumber]))
    {  // No SIP Address found, search for the phone number.
        NSString *phoneNumberToSearch;
        if ([[[aCall remoteURI] displayName] length] > 0) {
            phoneNumberToSearch = [[aCall remoteURI] displayName];
        } else {
            phoneNumberToSearch = [[aCall remoteURI] user];
        }
        
        BOOL recordFound = NO;
        
        // Look for the whole phone number match first.
        ABSearchElement *phoneNumberMatch
            = [ABPerson searchElementForProperty:kABPhoneProperty
                                           label:nil
                                             key:nil
                                           value:phoneNumberToSearch
                                      comparison:kABEqual];
        
        records = [AB recordsMatchingSearchElement:phoneNumberMatch];
        if ([records count] > 0) {
            recordFound = YES;
            id theRecord = records[0];
            finalDisplayedName = [theRecord ak_fullName];
            [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
            
            // Find the exact phone number match.
            ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
            for (NSUInteger i = 0; i < [phones count]; ++i) {
                if ([[phones valueAtIndex:i] isEqualToString:phoneNumberToSearch]) {
                    NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                    finalStatus = localizedLabel;
                    [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                    break;
                }
            }
        }
        
        NSUInteger significantPhoneNumberLength = [defaults integerForKey:UserDefaultsKeys.significantPhoneNumberLength];
        
        // Get the significant phone suffix if the phone number length is greater
        // than we defined.
        NSString *significantPhoneSuffix;
        if ([phoneNumberToSearch length] >= significantPhoneNumberLength) {
            significantPhoneSuffix = [phoneNumberToSearch substringFromIndex:
                                      ([phoneNumberToSearch length] - significantPhoneNumberLength)];
            
            // If the the record hasn't been found with the whole number, look for
            // significant suffix match.
            if (!recordFound) {
                ABSearchElement *phoneNumberSuffixMatch
                    = [ABPerson searchElementForProperty:kABPhoneProperty
                                                   label:nil
                                                     key:nil
                                                   value:significantPhoneSuffix
                                              comparison:kABSuffixMatch];
                
                records = [AB recordsMatchingSearchElement:phoneNumberSuffixMatch];
                if ([records count] > 0) {
                    recordFound = YES;
                    id theRecord = records[0];
                    finalDisplayedName = [theRecord ak_fullName];
                    [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
                    
                    // Find the exact phone number match.
                    ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
                    for (NSUInteger i = 0; i < [phones count]; ++i) {
                        if ([[phones valueAtIndex:i] hasSuffix:significantPhoneSuffix]) {
                            NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                            finalStatus = localizedLabel;
                            [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                            break;
                        }
                    }
                }
            }
        }
        
        // If still not found, search phone numbers that contain spaces, dashes, etc.
        if (!recordFound) {
            NSArray *allPeople = [AB people];
            
            AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
            for (id theRecord in allPeople) {
                ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
                
                for (NSUInteger i = 0; i < [phones count]; ++i) {
                    NSString *phoneNumber = [phones valueAtIndex:i];
                    
                    // Don't bother if the phone number contains only contiguous
                    // digits, we should have covered such numbers in previous search.
                    if ([phoneNumber ak_isTelephoneNumber]) {
                        continue;
                    }
                    
                    // Don't bother if the phone number has letters.
                    if ([phoneNumber ak_hasLetters]) {
                        continue;
                    }
                    
                    // Here phone number probably includes spaces or other dividers.
                    // Scan valid phone characters to compare with a given string.
                    NSString *scannedPhoneNumber = [telephoneNumberFormatter telephoneNumberFromString:phoneNumber];
                    if ([scannedPhoneNumber isEqualToString:phoneNumberToSearch]) {
                        recordFound = YES;
                    } else if (([phoneNumberToSearch length] >= significantPhoneNumberLength) &&
                               [scannedPhoneNumber hasSuffix:significantPhoneSuffix]) {
                        
                        recordFound = YES;
                    }
                    
                    if (recordFound) {
                        NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                        finalStatus = localizedLabel;
                        [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                        break;
                    }
                }
                
                if (recordFound) {
                    finalDisplayedName = [theRecord ak_fullName];
                    [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
                    break;
                }
            }
        }
    }
    
    // Address Book search ends here.
    
    [aCallController setTitle:([[aCall remoteURI] SIPAddress] ?: @"")];
    [aCallController setDisplayedName:finalDisplayedName];
    [aCallController setStatus:finalStatus];
    [aCallController setRedialURI:[aCall remoteURI]];
    
    [aCallController showIncomingCallView];
    
    [aCallController showWindow:nil];
    
    // Show user notification.
    NSString *callSource;
    AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
    [telephoneNumberFormatter setSplitsLastFourDigits:
     [defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
    if ([[aCallController phoneLabelFromAddressBook] length] > 0) {
        callSource = [aCallController phoneLabelFromAddressBook];
    } else if ([[[aCall remoteURI] user] length] > 0) {
        if ([[[aCall remoteURI] user] ak_isTelephoneNumber]) {
            if ([defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]) {
                callSource = [telephoneNumberFormatter stringForObjectValue:[[aCall remoteURI] user]];
            } else {
                callSource = [[aCall remoteURI] user];
            }
        } else {
            callSource = [[aCall remoteURI] SIPAddress];
        }
    } else {
        callSource = [[aCall remoteURI] host];
    }
    
    NSString *notificationTitle, *notificationDescription;
    if ([[aCallController nameFromAddressBook] length] > 0) {
        notificationTitle = [aCallController nameFromAddressBook];
        notificationDescription = callSource;
        
    } else if ([[[aCall remoteURI] displayName] length] > 0) {
        notificationTitle = [[aCall remoteURI] displayName];
        notificationDescription
            = [NSString stringWithFormat:
               NSLocalizedString(@"calling from %@",
                                 @"John Smith calling from 1234567. "
                                  "Somebody is calling us right now from some source. "
                                  "User notification description. Deliberately in "
                                  "lower case, translators should do the same, if "
                                  "possible."),
               callSource];
    } else {
        notificationTitle = callSource;
        notificationDescription
            = NSLocalizedString(@"calling",
                                @"John Smith calling. Somebody is calling us right "
                                 "now. User notification description. "
                                 "Deliberately in lower case, translators should do "
                                 "the same, if possible.");
    }
    
    NSUserNotification *userNotification = [[NSUserNotification alloc] init];
    userNotification.identifier = aCallController.identifier;
    userNotification.title = notificationTitle;
    userNotification.informativeText = notificationDescription;
    userNotification.actionButtonTitle = NSLocalizedString(@"Answer", @"Call answer button.");
    NSString *decline = NSLocalizedString(@"Decline", @"Call decline button.");
    userNotification.additionalActions = @[[NSUserNotificationAction actionWithIdentifier:@"decline" title:decline]];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];

    [self startPlayingRingtoneOrLogError];
    
    [aCall sendRingingNotification];
}

- (void)startPlayingRingtoneOrLogError {
    NSError *error;
    BOOL success = [self.ringtonePlayback startAndReturnError:&error];
    if (!success) {
        NSLog(@"Could not start playing ringtone: %@", error);
    }
}


#pragma mark - CallControllerDelegate

- (void)callControllerWillClose:(CallController *)callController {
    [self.callControllers removeObject:callController];
    [(AppController *)[NSApp delegate] updateDockTileBadgeLabel];
}


#pragma mark - AKSIPUserAgent notifications

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    if (![[notification object] isStarted]) {
        [self showOfflineState];
        
        return;
    }
    
    if ([self attemptingToRegisterAccount]) {
        [self registerAccount];
    } else if ([self attemptingToUnregisterAccount]) {
        [self unregisterAccount];
    }
}


#pragma mark - AKNetworkReachability notifications

// This is the moment when the application starts doing its main job.
- (void)networkReachabilityDidBecomeReachable:(NSNotification *)notification {
    if (!self.sleepStatus.isSleeping && !self.isAccountUnavailable && !self.isAccountRegistered) {
        [self registerAccount];
    }
}

@end
