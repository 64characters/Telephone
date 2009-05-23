//
//  AccountController.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AccountController.h"

#import <AddressBook/AddressBook.h>
#import <Growl/Growl.h>

#import "AKABAddressBook+Localizing.h"
#import "AKABRecord+Querying.h"
#import "AKKeychain.h"
#import "AKNSString+Scanning.h"
#import "AKNSWindow+Resizing.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "AKTelephoneNumberFormatter.h"

#import "AppController.h"
#import "CallController.h"
#import "PreferenceController.h"


// Account registration pull-down button widths.

// English.
const CGFloat kAccountRegistrationButtonOfflineEnglishWidth = 58.0;
const CGFloat kAccountRegistrationButtonAvailableEnglishWidth = 69.0;
const CGFloat kAccountRegistrationButtonUnavailableEnglishWidth = 81.0;
const CGFloat kAccountRegistrationButtonConnectingEnglishWidth = 90.0;

// Russian.
const CGFloat kAccountRegistrationButtonOfflineRussianWidth = 65.0;
const CGFloat kAccountRegistrationButtonAvailableRussianWidth = 73.0;
const CGFloat kAccountRegistrationButtonUnavailableRussianWidth = 85.0;
const CGFloat kAccountRegistrationButtonConnectingRussianWidth = 96.0;

// German.
const CGFloat kAccountRegistrationButtonOfflineGermanWidth = 58.0;
const CGFloat kAccountRegistrationButtonAvailableGermanWidth = 84.0;
const CGFloat kAccountRegistrationButtonUnavailableGermanWidth = 111.0;
const CGFloat kAccountRegistrationButtonConnectingGermanWidth = 88.0;


// Call destination keys.
NSString * const kURI = @"URI";
NSString * const kPhoneLabel = @"PhoneLabel";


// Address Book label for SIP address in the email field.
NSString * const kEmailSIPLabel = @"sip";


@interface AccountController ()

@property(nonatomic, assign) NSTimer *reRegistrationTimer;
@property(nonatomic, assign) NSUInteger callDestinationURIIndex;

- (void)reRegistrationTimerTick:(NSTimer *)theTimer;

@end

@implementation AccountController

@synthesize enabled = enabled_;
@synthesize account = account_;
@dynamic accountRegistered;
@synthesize callControllers = callControllers_;
@synthesize attemptingToRegisterAccount = attemptingToRegisterAccount_;
@synthesize attemptingToUnregisterAccount = attemptingToUnregisterAccount_;
@synthesize accountUnavailable = accountUnavailable_;
@synthesize reRegistrationTimer = reRegistrationTimer_;
@synthesize shouldMakeCall = shouldMakeCall_;
@synthesize catchedURLString = catchedURLString_;

@synthesize substitutesPlusCharacter = substitutesPlusCharacter_;
@synthesize plusCharacterSubstitution = plusCharacterSubstitution_;

@synthesize activeAccountView = activeAccountView_;
@synthesize offlineAccountView = offlineAccountView_;
@synthesize accountRegistrationPopUp = accountRegistrationPopUp_;
@synthesize callDestinationField = callDestinationField_;
@synthesize callDestinationURIIndex = callDestinationURIIndex_;

@synthesize authenticationFailureSheet = authenticationFailureSheet_;
@synthesize updateCredentialsInformativeText = updateCredentialsInformativeText_;
@synthesize newUsernameField = newUsernameField_;
@synthesize newPasswordField = newPasswordField_;
@synthesize mustSaveCheckBox = mustSaveCheckBox_;
@synthesize authenticationFailureCancelButton = authenticationFailureCancelButton_;

- (BOOL)isAccountRegistered {
  return [[self account] isRegistered];
}

- (void)setAccountRegistered:(BOOL)flag {
  // Invalidate account automatic re-registration timer.
  if ([self reRegistrationTimer] != nil) {
    [[self reRegistrationTimer] invalidate];
    [self setReRegistrationTimer:nil];
  }
  
  if ([[self account] identifier] != kAKTelephoneInvalidIdentifier) {  // Account has been added.
    [self showConnectingMode];
    
    [[self account] setRegistered:flag];
    
  } else {
    NSString *password
      = [AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@",
                                            [[self account] registrar]]
                               accountName:[[self account] username]];
    
    [self showConnectingMode];
    
    // Add account to Telephone
    BOOL added = [[[NSApp delegate] telephone] addAccount:[self account]
                                             withPassword:password];
    
    // Error connecting to registrar.
    if (added &&
        ![self isAccountRegistered] &&
        [[self account] registrationExpireTime] < 0)
    {
      if ([[[NSApp delegate] telephone] userAgentStarted]) {
        [self showUnregisteredMode];
        
        NSString *statusText;
        NSString *preferredLocalization
          = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([preferredLocalization isEqualToString:@"Russian"])
          statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                        [[self account] registrationStatus]];
        else
          statusText = [[self account] registrationStatusText];
        
        NSString *error;
        if (statusText == nil) {
          error = [NSString stringWithFormat:
                   NSLocalizedString(@"Error %d", @"Error #."),
                   [[self account] registrationStatus]];
          error = [error stringByAppendingString:@"."];
        } else {
          error = [NSString stringWithFormat:
                   NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.",
                                     @"Error description."),
                   [[self account] registrationStatus], statusText];
        }
        
        // Show a sheet.
        [self showRegistrarConnectionErrorSheetWithError:error];
        
      }
    }
  }
}

- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount {
  self = [super initWithWindowNibName:@"Account"];
  if (self == nil)
    return nil;
  
  [self setAccount:anAccount];
  callControllers_ = [[NSMutableArray alloc] init];
  [self setSubstitutesPlusCharacter:NO];
  
  [self setAttemptingToRegisterAccount:NO];
  [self setAttemptingToUnregisterAccount:NO];
  [self setAccountUnavailable:NO];
  [self setShouldMakeCall:NO];
  
  [[self account] setDelegate:self];
  
  [[self window] setTitle:[[self account] SIPAddress]];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
      selector:@selector(telephoneUserAgentDidFinishStarting:)
          name:AKTelephoneUserAgentDidFinishStartingNotification
        object:nil];
  
  return self;
}

- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername {
  AKTelephoneAccount *anAccount
    = [AKTelephoneAccount telephoneAccountWithFullName:aFullName
                                            SIPAddress:aSIPAddress
                                             registrar:aRegistrar
                                                 realm:aRealm
                                              username:aUsername];
  
  return [self initWithTelephoneAccount:anAccount];
}

- (void)dealloc {
  // Close all call controllers.
  for (CallController *aCallController in [self callControllers])
    [aCallController close];
  
  if ([[[self account] delegate] isEqual:self])
    [[self account] setDelegate:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // Close authentication failure sheet if it's raised
  [[self authenticationFailureCancelButton] performClick:nil];
  
  [account_ release];
  [callControllers_ release];
  [catchedURLString_ release];
  [plusCharacterSubstitution_ release];
  
  [activeAccountView_ release];
  [offlineAccountView_ release];
  [accountRegistrationPopUp_ release];
  [callDestinationField_ release];
  [authenticationFailureSheet_ release];
  [updateCredentialsInformativeText_ release];
  [newUsernameField_ release];
  [newPasswordField_ release];
  [mustSaveCheckBox_ release];
  [authenticationFailureCancelButton_ release];
  
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ controller", [self account]];
}

- (void)awakeFromNib {
  [self setShouldCascadeWindows:NO];
  [[self window] setFrameAutosaveName:[[self account] SIPAddress]];
  
  // Exclude comma from the callDestination tokenizing character set.
  [[self callDestinationField] setTokenizingCharacterSet:
   [NSCharacterSet characterSetWithCharactersInString:@""]];
  
  [[self callDestinationField] setCompletionDelay:0.4];
}

- (void)removeAccountFromTelephone {
  NSAssert([self isEnabled],
           @"Account conroller must be enabled to remove account from Telephone.");
  
  // Invalidate account automatic re-registration timer if it's valid.
  if ([self reRegistrationTimer] != nil) {
    [[self reRegistrationTimer] invalidate];
    [self setReRegistrationTimer:nil];
  }
  
  [self showOfflineMode];
  
  // Remove account from Telephone.
  [[[NSApp delegate] telephone] removeAccount:[self account]];
}

// Ask model to make call, create call controller, attach the call to the call contoller
- (IBAction)makeCall:(id)sender {
  if ([[[self callDestinationField] objectValue] count] == 0)
    return;
  
  NSDictionary *primaryDestinationDict
    = [[[[self callDestinationField] objectValue] objectAtIndex:0]
       objectAtIndex:[self callDestinationURIIndex]];
  
  AKSIPURI *originalURI
    = [[[primaryDestinationDict objectForKey:kURI] copy] autorelease];
  
  NSString *phoneLabel = [primaryDestinationDict objectForKey:kPhoneLabel];
  
  AKSIPURI *firstURI
    = [[[[[self callDestinationField] objectValue] objectAtIndex:0]
        objectAtIndex:0] objectForKey:kURI];
  
  if ([[originalURI user] length] == 0)
    return;
  
  AKSIPURI *uri = [[originalURI copy] autorelease];
  if (![uri isKindOfClass:[AKSIPURI class]])
    return;
  
  if ([[uri user] length] == 0)
    return;
  
  if ([[uri host] length] == 0)
    [uri setHost:[[[self account] registrationURI] host]];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  AKTelephoneNumberFormatter *telephoneNumberFormatter
    = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
  [telephoneNumberFormatter setSplitsLastFourDigits:
   [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
  
  // Get the clean string of contiguous digits if the user part doesn't contain
  // letters.
  if (![[uri user] ak_hasLetters])
    [uri setUser:[telephoneNumberFormatter telephoneNumberFromString:[uri user]]];
  
  // Actually, the call will be made to the copy of the URI without display-name
  // part to prevent another call party from seeing local Address Book records.
  AKSIPURI *cleanURI = [[uri copy] autorelease];
  [cleanURI setDisplayName:nil];
  
  // Substitute plus character if needed.
  if ([self substitutesPlusCharacter] && [[cleanURI user] hasPrefix:@"+"]) {
    [cleanURI setUser:
     [[cleanURI user]
      stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                              withString:[self plusCharacterSubstitution]]];
    [originalURI setUser:
     [[originalURI user]
      stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                              withString:[self plusCharacterSubstitution]]];
  }
  
  CallController *aCallController
    = [[[CallController alloc] initWithAccountController:self] autorelease];
  [aCallController setNameFromAddressBook:[firstURI displayName]];
  [aCallController setPhoneLabelFromAddressBook:phoneLabel];
  [aCallController setEnteredCallDestination:[originalURI user]];
  [[self callControllers] addObject:aCallController];
  
  // Set title.
  if ([[originalURI host] length] == 0 && ![[originalURI user] ak_hasLetters]) {
    if ([[originalURI user] ak_isTelephoneNumber] &&
        [defaults boolForKey:kFormatTelephoneNumbers]) {
      [[aCallController window] setTitle:
       [telephoneNumberFormatter stringForObjectValue:[originalURI user]]];
    } else {
      [[aCallController window] setTitle:[originalURI user]];
    }
  } else {
    [[aCallController window] setTitle:[uri SIPAddress]];
  }
  
  // Set displayed name.
  if ([[firstURI displayName] length] == 0) {
    if ([[originalURI host] length] > 0) {
      [aCallController setDisplayedName:[uri SIPAddress]];
    } else if ([[originalURI user] ak_isTelephoneNumber] &&
               [defaults boolForKey:kFormatTelephoneNumbers]) {
      [aCallController setDisplayedName:
       [telephoneNumberFormatter stringForObjectValue:[originalURI user]]];
    } else {
      [aCallController setDisplayedName:[originalURI user]];
    }
  } else {
    [aCallController setDisplayedName:[firstURI displayName]];
  }
  
  // Set URI for redial.
  [aCallController setRedialURI:cleanURI];
  
  [[aCallController window] setContentView:[aCallController activeCallView]];
  
  if ([phoneLabel length] > 0) {
    [aCallController setStatus:
     [NSString stringWithFormat:
      NSLocalizedString(@"calling %@...",
                        @"Outgoing call in progress. Calling specific phone "
                        "type (mobile, home, etc)."),
      phoneLabel]];
  } else {
    [aCallController setStatus:NSLocalizedString(@"calling...",
                                                 @"Outgoing call in progress.")];
  }
  
  [aCallController showWindow:nil];
  [[aCallController callProgressIndicator] startAnimation:self];
  
  // Make actual call.
  AKTelephoneCall *aCall = [[self account] makeCallTo:cleanURI];
  if (aCall != nil) {
    [aCallController setCall:aCall];
    [aCallController setCallActive:YES];
  } else {
    [[aCallController window] setContentView:[aCallController endedCallView]];
    [aCallController setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
  }
}

- (IBAction)changeAccountRegistration:(id)sender {
  // Invalidate account automatic re-registration timer.
  if ([self reRegistrationTimer] != nil) {
    [[self reRegistrationTimer] invalidate];
    [self setReRegistrationTimer:nil];
  }
  
  NSInteger selectedItemTag = [[sender selectedItem] tag];
  
  if (selectedItemTag == kTelephoneAccountOfflineTag) {
    [self setAccountUnavailable:NO];
    [self showOfflineMode];
    // Remove account from Telephone.
    [self removeAccountFromTelephone];
    
  } else if (selectedItemTag == kTelephoneAccountUnregisterTag) {
    // Unregister account only if it is registered or it wasn't added to Telephone.
    if ([self isAccountRegistered] ||
        [[self account] identifier] == kAKTelephoneInvalidIdentifier) {
      [self setAccountUnavailable:YES];
      [self setAttemptingToUnregisterAccount:YES];
      [self setAccountRegistered:NO];
    }
    
  } else if (selectedItemTag == kTelephoneAccountRegisterTag) {
    [self setAccountUnavailable:NO];
    [self setAttemptingToRegisterAccount:YES];
    [self setAccountRegistered:YES];
  }
}

// Remove old account from Telephone, change username for the account, add
// to Telephone with new password and update Keychain.
- (IBAction)changeUsernameAndPassword:(id)sender {
  [self closeSheet:sender];
  
  if (![[[self newUsernameField] stringValue] isEqualToString:@""]) {
    [self removeAccountFromTelephone];
    [[self account] setUsername:[[self newUsernameField] stringValue]];
    
    [self showConnectingMode];
    
    // Add account to Telephone.
    [[[NSApp delegate] telephone] addAccount:[self account]
                                withPassword:[[self newPasswordField]
                                              stringValue]];
    
    // Error connecting to registrar.
    if (![self isAccountRegistered] &&
        [[self account] registrationExpireTime] < 0) {
      [self showUnregisteredMode];
      
      NSString *statusText;
      NSString *preferredLocalization
        = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
      if ([preferredLocalization isEqualToString:@"Russian"]) {
        statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                      [[self account] registrationStatus]];
      } else {
        statusText = [[self account] registrationStatusText];
      }
      
      NSString *error;
      if (statusText == nil) {
        error = [NSString stringWithFormat:
                 NSLocalizedString(@"Error %d", @"Error #."),
                 [[self account] registrationStatus]];
        error = [error stringByAppendingString:@"."];
      } else {
        error = [NSString stringWithFormat:
                 NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.",
                                   @"Error description."),
                 [[self account] registrationStatus], statusText];
      }
      
      [self showRegistrarConnectionErrorSheetWithError:error];
    }
    
    if ([[self mustSaveCheckBox] state] == NSOnState)
      [AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@",
                                          [[self account] registrar]]
                             accountName:[[self newUsernameField] stringValue]
                                password:[[self newPasswordField] stringValue]];
  }
  
  [[self newPasswordField] setStringValue:@""];
}

- (IBAction)closeSheet:(id)sender {
  [NSApp endSheet:[sender window]];
  [[sender window] orderOut:self];
}

- (IBAction)changeCallDestinationURIIndex:(id)sender {
  [self setCallDestinationURIIndex:[sender tag]];
}

- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error {
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:[NSString stringWithFormat:
                         NSLocalizedString(@"Could not connect to server %@.",
                                           @"Registrar connection error."),
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
  
  [alert beginSheetModalForWindow:[self window]
                    modalDelegate:nil
                   didEndSelector:NULL
                      contextInfo:NULL];
}


- (void)showRegisteredMode {
  NSSize buttonSize = [[self accountRegistrationPopUp] frame].size;
  
  NSString *preferredLocalization
    = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  
  if ([preferredLocalization isEqualToString:@"English"])
    buttonSize.width = kAccountRegistrationButtonAvailableEnglishWidth;
  else if ([preferredLocalization isEqualToString:@"Russian"])
    buttonSize.width = kAccountRegistrationButtonAvailableRussianWidth;
  else if ([preferredLocalization isEqualToString:@"German"])
    buttonSize.width = kAccountRegistrationButtonAvailableGermanWidth;
  
  [[self accountRegistrationPopUp] setFrameSize:buttonSize];
  [[self accountRegistrationPopUp] setTitle:
   NSLocalizedString(@"Available",
                     @"Account registration Available menu item.")];
  
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountRegisterTag] setState:NSOnState];
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountUnregisterTag] setState:NSOffState];
  [[self window] setContentView:[self activeAccountView]];
  
  if ([[self callDestinationField] acceptsFirstResponder])
    [[self window] makeFirstResponder:[self callDestinationField]];
}

- (void)showUnregisteredMode {
  NSSize buttonSize = [[self accountRegistrationPopUp] frame].size;
  
  NSString *preferredLocalization
    = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  
  if ([preferredLocalization isEqualToString:@"English"])
    buttonSize.width = kAccountRegistrationButtonUnavailableEnglishWidth;
  else if ([preferredLocalization isEqualToString:@"Russian"])
    buttonSize.width = kAccountRegistrationButtonUnavailableRussianWidth;
  else if ([preferredLocalization isEqualToString:@"German"])
    buttonSize.width = kAccountRegistrationButtonUnavailableGermanWidth;
  
  [[self accountRegistrationPopUp] setFrameSize:buttonSize];
  [[self accountRegistrationPopUp] setTitle:
   NSLocalizedString(@"Unavailable",
                     @"Account registration Unavailable menu item.")];
  
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountRegisterTag] setState:NSOffState];
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountUnregisterTag] setState:NSOnState];
  [[self window] setContentView:[self activeAccountView]];
  
  if ([[self callDestinationField] acceptsFirstResponder])
    [[self window] makeFirstResponder:[self callDestinationField]];
}

- (void)showOfflineMode {
  NSSize buttonSize = [[self accountRegistrationPopUp] frame].size;
  
  NSString *preferredLocalization
    = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  
  if ([preferredLocalization isEqualToString:@"English"])
    buttonSize.width = kAccountRegistrationButtonOfflineEnglishWidth;
  else if ([preferredLocalization isEqualToString:@"Russian"])
    buttonSize.width = kAccountRegistrationButtonOfflineRussianWidth;
  else if ([preferredLocalization isEqualToString:@"German"])
    buttonSize.width = kAccountRegistrationButtonOfflineGermanWidth;
  
  [[self accountRegistrationPopUp] setFrameSize:buttonSize];
  [[self accountRegistrationPopUp] setTitle:
   NSLocalizedString(@"Offline",
                     @"Account registration Offline menu item.")];
  
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountRegisterTag] setState:NSOffState];
  [[[[self accountRegistrationPopUp] menu]
    itemWithTag:kTelephoneAccountUnregisterTag] setState:NSOffState];
  [[self window] setContentView:[self offlineAccountView]];
}

- (void)showConnectingMode {
  NSSize buttonSize = [[self accountRegistrationPopUp] frame].size;
  
  NSString *preferredLocalization
    = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  
  if ([preferredLocalization isEqualToString:@"English"])
    buttonSize.width = kAccountRegistrationButtonConnectingEnglishWidth;
  else if ([preferredLocalization isEqualToString:@"Russian"])
    buttonSize.width = kAccountRegistrationButtonConnectingRussianWidth;
  else if ([preferredLocalization isEqualToString:@"German"])
    buttonSize.width = kAccountRegistrationButtonConnectingGermanWidth;
  
  [[self accountRegistrationPopUp] setFrameSize:buttonSize];
  [[self accountRegistrationPopUp] setTitle:
   NSLocalizedString(@"Connecting...",
                     @"Account registration Connecting... menu item.")];
}

- (void)reRegistrationTimerTick:(NSTimer *)theTimer {
  [[self account] setRegistered:YES];
}

- (void)handleCatchedURL {
  AKSIPURI *uri = [AKSIPURI SIPURIWithString:[self catchedURLString]];
  
  // Clear |catchedURLString|.
  [self setCatchedURLString:nil];
  
  if ([[uri user] length] == 0)
    return;
  
  [[self callDestinationField] setTokenStyle:NSPlainTextTokenStyle];
  
  NSString *theString;
  if ([[uri host] length] > 0)
    theString = [uri SIPAddress];
  else
    theString = [uri user];
  
  [[self callDestinationField] setStringValue:theString];
  [self makeCall:[self callDestinationField]];
}


#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowDidLoad {
  [self showOfflineMode];
}

- (BOOL)windowShouldClose:(id)sender {
  BOOL result = YES;
  
  if (sender == [self window]) {
    [[self window] orderOut:self];
    result = NO;
  }
  
  return result;
}


#pragma mark -
#pragma mark AKTelephoneAccount notifications

// When account registration changes, make appropriate modifications to the UI.
// A call can also be made from here if the user called from the Address Book
// or from the application URL handler.
- (void)telephoneAccountRegistrationDidChange:(NSNotification *)notification {
  // Account identifier can be AKTelephoneInvalidIdentifier if notification
  // on the main thread was delivered after Telephone had removed the account.
  // Don't bother in that case.
  if ([[self account] identifier] == kAKTelephoneInvalidIdentifier)
    return;
  
  if ([[self account] isRegistered]) {
    // Invalidate account automatic re-registration timer.
    if ([self reRegistrationTimer] != nil) {
      [[self reRegistrationTimer] invalidate];
      [self setReRegistrationTimer:nil];
    }
    
    // If the account was offline and the user chose Unavailable state,
    // setAccountRegistered:NO will add the account to Telephone. Telephone
    // will register the account. Set the account to Unavailable (unregister
    // it) here.
    if ([self attemptingToUnregisterAccount]) {
      [self setAccountRegistered:NO];
      
    } else {
      [self setAccountUnavailable:NO];
      [self showRegisteredMode];
      
      // The user could initiate a call from the Address Book plug-in.
      if ([self shouldMakeCall]) {
        // Explicitly display registered mode before calling.
        [[self window] display];
        
        [self setShouldMakeCall:NO];
        [self makeCall:[self callDestinationField]];
      }
      
      // The user could click a URL.
      if ([self catchedURLString] != nil) {
        // Explicitly display registered mode before calling.
        [[self window] display];
        
        [self handleCatchedURL];
      }
    }
    
  } else {
    [self showUnregisteredMode];
    
    // Handle authentication failure
    if ([[self account] registrationStatus] == PJSIP_EFAILEDCREDENTIAL) {
      if ([self authenticationFailureSheet] == nil)
        [NSBundle loadNibNamed:@"AuthFailed" owner:self];
      
      [[self updateCredentialsInformativeText] setStringValue:
       [NSString stringWithFormat:
        NSLocalizedString(@"Telephone was unable to login to %@. "
                          "Change user name or password and try again.",
                          @"Registrar authentication failed."),
        [[self account] registrar]]];
      [[self newUsernameField] setStringValue:[[self account] username]];
      [[self newPasswordField] setStringValue:@""];
      
      [NSApp beginSheet:[self authenticationFailureSheet]
         modalForWindow:[self window]
          modalDelegate:nil
         didEndSelector:NULL
            contextInfo:NULL];
      
    } else if ([[self account] registrationStatus] == PJSIP_SC_NOT_FOUND ||
               [[self account] registrationStatus] == PJSIP_SC_FORBIDDEN ||
               [[self account] registrationStatus] == PJSIP_EAUTHNOCHAL) {
      NSAlert *alert = [[[NSAlert alloc] init] autorelease];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:
       [NSString stringWithFormat:
        NSLocalizedString(@"SIP address \\U201C%@\\U201D does not match "
                          "the user name \\U201C%@\\U201D.",
                          @"SIP address does not match the user name."),
        [[self account] SIPAddress], [[self account] username]]];
      [alert setInformativeText:
       NSLocalizedString(@"Please check your SIP Address.",
                         @"SIP address does not match the user name informative text.")];
      [alert beginSheetModalForWindow:[self window]
                        modalDelegate:nil
                       didEndSelector:NULL
                          contextInfo:NULL];
      
    } else if (([[self account] registrationStatus] / 100 != 2) &&
               ([[self account] registrationExpireTime] < 0)) {
      // Raise a sheet if connection to the registrar failed.
      // If last registration status is 2xx and expiration interval is less
      // than zero, it is unregistration, not failure. Condition of failure is:
      // last registration status != 2xx AND expiration interval < 0.
      
      if ([[[NSApp delegate] telephone] userAgentStarted]) {
        // Show a sheet if setAccountRegistered: was called.
        if ([self attemptingToRegisterAccount] ||
            [self attemptingToUnregisterAccount]) {
          NSString *statusText;
          NSString *preferredLocalization
            = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
          if ([preferredLocalization isEqualToString:@"Russian"]) {
            statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                          [[self account] registrationStatus]];
          } else {
            statusText = [[self account] registrationStatusText];
          }
          
          NSString *error;
          if (statusText == nil) {
            error = [NSString stringWithFormat:
                     NSLocalizedString(@"Error %d", @"Error #."),
                     [[self account] registrationStatus]];
            error = [error stringByAppendingString:@"."];
          } else {
            error = [NSString stringWithFormat:
                     NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.",
                                       @"Error description."),
                     [[self account] registrationStatus], statusText];
          }
          
          [self showRegistrarConnectionErrorSheetWithError:error];
          
        } else {
          // Schedule account automatic re-registration timer.
          if ([self reRegistrationTimer] == nil) {
            NSTimeInterval reregistrationTimeInterval
              = (NSTimeInterval)[[self account] reregistrationTime];
            
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
}

- (void)telephoneAccountWillRemove:(NSNotification *)notification {
  // Invalidate account automatic re-registration timer.
  if ([self reRegistrationTimer] != nil) {
    [[self reRegistrationTimer] invalidate];
    [self setReRegistrationTimer:nil];
  }
}


#pragma mark -
#pragma mark CallController notifications

// Remove call controller from array of controllers before the window is closed
- (void)telephoneCallWindowWillClose:(NSNotification *)notification {
  CallController *aCallController = [notification object];
  [[self callControllers] removeObject:aCallController];
}


#pragma mark -
#pragma mark AKTelephoneAccountDelegate protocol

// When the call is received, create call controller, add to array, show call window
- (void)telephoneAccountDidReceiveCall:(AKTelephoneCall *)aCall {
  // Just reply with 480 Temporarily Unavailable if the user selected
  // Unavailable account state.
  if ([self isAccountUnavailable]) {
    [aCall replyWithTemporarilyUnavailable];
    return;
  }
  
  [[NSApp delegate] pauseITunes];
  
  CallController *aCallController
    = [[[CallController alloc] initWithAccountController:self] autorelease];
  [aCallController setCall:aCall];
  [aCallController setCallActive:YES];
  [aCallController setCallUnhandled:YES];
  [[self callControllers] addObject:aCallController];
  
  AKSIPURIFormatter *SIPURIFormatter
    = [[[AKSIPURIFormatter alloc] init] autorelease];
  
  // These variables will be changed during the Address Book search if the record is found.
  NSString *finalTitle = [[aCall remoteURI] SIPAddress];
  NSString *finalDisplayedName
    = [SIPURIFormatter stringForObjectValue:[aCall remoteURI]];
  NSString *finalStatus
    = NSLocalizedString(@"calling",
                        @"John Smith calling. Somebody is calling us right now. "
                        "Call status string. Deliberately in lower case, "
                        "translators should do the same, if possible.");
  AKSIPURI *finalRedialURI = [aCall remoteURI];
  
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
    id theRecord = [records objectAtIndex:0];
    
    finalDisplayedName = [theRecord ak_fullName];
    [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
    
    NSString *localizedLabel = [AB ak_localizedLabel:kEmailSIPLabel];
    finalStatus = localizedLabel;
    [aCallController setPhoneLabelFromAddressBook:localizedLabel];
    
    finalRedialURI = [aCall remoteURI];
    
  } else if ([[[aCall remoteURI] displayName] ak_isTelephoneNumber] ||
             ([[[aCall remoteURI] displayName] length] == 0 &&
              [[[aCall remoteURI] user] ak_isTelephoneNumber]))
  {  // No SIP Address found, search for the phone number.
    NSString *phoneNumberToSearch;
    if ([[[aCall remoteURI] displayName] length] > 0)
      phoneNumberToSearch = [[aCall remoteURI] displayName];
    else 
      phoneNumberToSearch = [[aCall remoteURI] user];
    
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
      id theRecord = [records objectAtIndex:0];
      finalDisplayedName = [theRecord ak_fullName];
      [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
      
      // Find the exact phone number match.
      ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
      for (NSUInteger i = 0; i < [phones count]; ++i)
        if ([[phones valueAtIndex:i] isEqualToString:phoneNumberToSearch]) {
          NSString *localizedLabel
            = [AB ak_localizedLabel:[phones labelAtIndex:i]];
          finalStatus = localizedLabel;
          [aCallController setPhoneLabelFromAddressBook:localizedLabel];
          
          finalRedialURI
            = [AKSIPURI SIPURIWithUser:[phones valueAtIndex:i]
                                  host:[[[self account] registrationURI] host]
                           displayName:nil];
          break;
        }
    }
    
    NSUInteger significantPhoneNumberLength
      = [[NSUserDefaults standardUserDefaults]
         integerForKey:kSignificantPhoneNumberLength];
    
    // Get the significant phone suffix if the phone number length is greater
    // than we defined.
    NSString *significantPhoneSuffix;
    if ([phoneNumberToSearch length] > significantPhoneNumberLength) {
      significantPhoneSuffix
        = [phoneNumberToSearch substringFromIndex:
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
          id theRecord = [records objectAtIndex:0];
          finalDisplayedName = [theRecord ak_fullName];
          [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
          
          // Find the exact phone number match.
          ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
          for (NSUInteger i = 0; i < [phones count]; ++i)
            if ([[phones valueAtIndex:i] hasSuffix:significantPhoneSuffix]) {
              NSString *localizedLabel
                = [AB ak_localizedLabel:[phones labelAtIndex:i]];
              finalStatus = localizedLabel;
              [aCallController setPhoneLabelFromAddressBook:localizedLabel];
              
              finalRedialURI
              = [AKSIPURI SIPURIWithUser:[phones valueAtIndex:i]
                                    host:[[[self account] registrationURI] host]
                             displayName:nil];
              break;
            }
        }
      }
    }
    
    // If still not found, search phone numbers that contain spaces, dashes, etc.
    if (!recordFound) {
      NSArray *allPeople = [AB people];
      
      AKTelephoneNumberFormatter *telephoneNumberFormatter
        = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
      for (id theRecord in allPeople) {
        ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
        
        for (NSUInteger i = 0; i < [phones count]; ++i) {
          NSString *phoneNumber = [phones valueAtIndex:i];
          
          // Don't bother if the phone number contains only contiguous
          // digits, we should have covered such numbers in previous search.
          if ([phoneNumber ak_isTelephoneNumber])
            continue;
          
          // Don't bother if the phone number has letters.
          if ([phoneNumber ak_hasLetters])
            continue;
          
          // Here phone number probably includes spaces or other dividers.
          // Scan valid phone characters to compare with a given string.
          NSString *scannedPhoneNumber
            = [telephoneNumberFormatter telephoneNumberFromString:phoneNumber];
          if ([scannedPhoneNumber isEqualToString:phoneNumberToSearch]) {
            recordFound = YES;
          } else if (([phoneNumberToSearch length] > significantPhoneNumberLength) &&
                     [scannedPhoneNumber hasSuffix:significantPhoneSuffix]) {
            recordFound = YES;
          }
          
          if (recordFound) {
            NSString *localizedLabel
              = [AB ak_localizedLabel:[phones labelAtIndex:i]];
            finalStatus = localizedLabel;
            [aCallController setPhoneLabelFromAddressBook:localizedLabel];
            
            finalRedialURI
              = [AKSIPURI SIPURIWithUser:scannedPhoneNumber
                                    host:[[[self account] registrationURI] host]
                             displayName:nil];
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
  
  [[aCallController window] setTitle:finalTitle];
  [aCallController setDisplayedName:finalDisplayedName];
  [aCallController setStatus:finalStatus];
  [aCallController setRedialURI:finalRedialURI];
  [[aCallController window] ak_resizeAndSwapToContentView:
   [aCallController incomingCallView]];
  
  [aCallController showWindow:nil];
  
  // Show Growl notification.
  NSString *callSource;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  AKTelephoneNumberFormatter *telephoneNumberFormatter
    = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
  [telephoneNumberFormatter setSplitsLastFourDigits:
   [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
  if ([[aCallController phoneLabelFromAddressBook] length] > 0) {
    callSource = [aCallController phoneLabelFromAddressBook];
  } else if ([[[aCall remoteURI] user] length] > 0) {
    if ([[[aCall remoteURI] user] ak_isTelephoneNumber]) {
      if ([defaults boolForKey:kFormatTelephoneNumbers]) {
        callSource = [telephoneNumberFormatter stringForObjectValue:
                      [[aCall remoteURI] user]];
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
         NSLocalizedString(@"calling from %@", @"John Smith calling from 1234567. "
                           "Somebody is calling us right now from some source. "
                           "Growl notification description. Deliberately in lower case, "
                           "translators should do the same, if possible."),
         callSource];
  } else {
    notificationTitle = callSource;
    notificationDescription
      = NSLocalizedString(@"calling",
                          @"John Smith calling. Somebody is calling us right "
                          "now. Growl notification description. "
                          "Deliberately in lower case, translators should do "
                          "the same, if possible.");
  }
  
  [GrowlApplicationBridge notifyWithTitle:notificationTitle
                              description:notificationDescription
                         notificationName:kGrowlNotificationIncomingCall
                                 iconData:nil
                                 priority:0
                                 isSticky:NO
                             clickContext:[aCallController identifier]];
  
  [[[NSApp delegate] ringtone] play];
  [[NSApp delegate] startRingtoneTimer];
  
  if (![NSApp isActive]) {
    [NSApp requestUserAttention:NSInformationalRequest];
    [[NSApp delegate] startUserAttentionTimer];
  }
  
  [aCall sendRingingNotification];
}


#pragma mark -
#pragma mark AKTelephone notifications

- (void)telephoneUserAgentDidFinishStarting:(NSNotification *)notification {
  if (![[notification object] userAgentStarted]) {
    [self showOfflineMode];
    
    return;
  }
  
  if ([self attemptingToRegisterAccount])
    [self setAccountRegistered:YES];
  
  else if ([self attemptingToUnregisterAccount])
    [self setAccountRegistered:NO];
}


#pragma mark -
#pragma mark NSTokenField delegate

// Return completions based on the Address Book search.
// A completion string can be in one of two formats: Display Name <1234567> for 
// person or company name searches, 1234567 (Display Name) for the phone number
// searches.
// Sets tokenField sytle to NSRoundedTokenStyle if the substring is found in
// the Address Book; otherwise, sets tokenField sytle to NSPlainTextTokenStyle.
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex
    indexOfSelectedItem:(NSInteger *)selectedIndex {
  
  ABAddressBook *AB = [ABAddressBook sharedAddressBook];
  NSMutableArray *searchElements = [NSMutableArray array];
  NSArray *substringComponents = [substring componentsSeparatedByString:@" "];
  
  ABSearchElement *isPersonRecord
    = [ABPerson searchElementForProperty:kABPersonFlags
                                   label:nil
                                     key:nil
                                   value:[NSNumber
                                          numberWithInteger:kABShowAsPerson]
                              comparison:kABBitsInBitFieldMatch];
  
  // Entered substring matches the first name prefix.
  ABSearchElement *firstNamePrefixMatch
    = [ABPerson searchElementForProperty:kABFirstNameProperty
                                   label:nil
                                     key:nil
                                   value:substring
                              comparison:kABPrefixMatchCaseInsensitive];
  
  ABSearchElement *firstNamePrefixPersonMatch
    = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                          children:[NSArray arrayWithObjects:
                                                    firstNamePrefixMatch,
                                                    isPersonRecord,
                                                    nil]];
  
  [searchElements addObject:firstNamePrefixPersonMatch];
  
  // Entered substring matches the last name prefix.
  ABSearchElement *lastNamePrefixMatch
    = [ABPerson searchElementForProperty:kABLastNameProperty
                                   label:nil
                                     key:nil
                                   value:substring
                              comparison:kABPrefixMatchCaseInsensitive];
  
  ABSearchElement *lastNamePrefixPersonMatch
    = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                          children:[NSArray arrayWithObjects:
                                                    lastNamePrefixMatch,
                                                    isPersonRecord,
                                                    nil]];
  
  [searchElements addObject:lastNamePrefixPersonMatch];
  
  
  // If entered substring consists of several words separated by spaces,
  // add searches for all possible combinations of the first and the last names.
  for (NSUInteger i = 0; i < [substringComponents count] - 1; ++i) {
    NSMutableString *firstPart = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *secondPart = [[[NSMutableString alloc] init] autorelease];
    NSUInteger j;
    
    for (j = 0; j <= i; ++j) {
      if ([firstPart length] > 0)
        [firstPart appendFormat:@" %@", [substringComponents objectAtIndex:j]];
      else
        [firstPart appendString:[substringComponents objectAtIndex:j]];
    }
    
    for (j = i + 1; j < [substringComponents count]; ++j) {
      if ([secondPart length] > 0)
        [secondPart appendFormat:@" %@", [substringComponents objectAtIndex:j]];
      else
        [secondPart appendString:[substringComponents objectAtIndex:j]];
    }
    
    ABSearchElement *firstNameMatch
      = [ABPerson searchElementForProperty:kABFirstNameProperty
                                     label:nil
                                       key:nil
                                     value:firstPart
                                comparison:kABEqualCaseInsensitive];
    
    if ([secondPart length] > 0) {
      // Search element for the prefix match of the last name.
      lastNamePrefixMatch
        = [ABPerson searchElementForProperty:kABLastNameProperty
                                       label:nil
                                         key:nil
                                       value:secondPart
                                  comparison:kABPrefixMatchCaseInsensitive];
    } else {
      // Search element for the existence of the last name.
      lastNamePrefixMatch
        = [ABPerson searchElementForProperty:kABLastNameProperty
                                       label:nil
                                         key:nil
                                       value:nil
                                  comparison:kABNotEqual];
    }
    
    ABSearchElement *firstNameAndLastNamePrefixMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      firstNameMatch,
                                                      lastNamePrefixMatch,
                                                      isPersonRecord,
                                                      nil]];
    
    [searchElements addObject:firstNameAndLastNamePrefixMatch];
    
    // Swap the first and the last names in search.
    ABSearchElement *lastNameMatch
      = [ABPerson searchElementForProperty:kABLastNameProperty
                                     label:nil
                                       key:nil
                                     value:firstPart
                                comparison:kABEqualCaseInsensitive];
    
    if ([secondPart length] > 0) {
      // Search element for the prefix match of the first name.
      firstNamePrefixMatch
        = [ABPerson searchElementForProperty:kABFirstNameProperty
                                       label:nil
                                         key:nil
                                       value:secondPart
                                  comparison:kABPrefixMatchCaseInsensitive];
    } else {
      // Search element for the existence of the first name.
      firstNamePrefixMatch
        = [ABPerson searchElementForProperty:kABFirstNameProperty
                                       label:nil
                                         key:nil
                                       value:nil
                                  comparison:kABNotEqual];
    }
    
    ABSearchElement *lastNameAndFirstNamePrefixMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      lastNameMatch,
                                                      firstNamePrefixMatch,
                                                      isPersonRecord,
                                                      nil]];
    
    [searchElements addObject:lastNameAndFirstNamePrefixMatch];
  }
  
  ABSearchElement *isCompanyRecord
    = [ABPerson searchElementForProperty:kABPersonFlags
                                   label:nil
                                     key:nil
                                   value:[NSNumber
                                          numberWithInteger:kABShowAsCompany]
                              comparison:kABBitsInBitFieldMatch];
  
  // Entered substring matches company name prefix.
  ABSearchElement *companyPrefixMatch
    = [ABPerson searchElementForProperty:kABOrganizationProperty
                                   label:nil
                                     key:nil
                                   value:substring
                              comparison:kABPrefixMatchCaseInsensitive];
  
  // Don't bother if the AB record is not a company record.
  ABSearchElement *companyPrefixAndIsCompanyRecord
    = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                          children:[NSArray arrayWithObjects:
                                                    companyPrefixMatch,
                                                    isCompanyRecord,
                                                    nil]];
  
  [searchElements addObject:companyPrefixAndIsCompanyRecord];
  
  // Entered substring matches phone number prefix.
  ABSearchElement *phoneNumberPrefixMatch
    = [ABPerson searchElementForProperty:kABPhoneProperty
                                   label:nil
                                     key:nil
                                   value:substring
                              comparison:kABPrefixMatch];
  
  [searchElements addObject:phoneNumberPrefixMatch];
  
  // Entered substing matches SIP address prefix. (SIP address is the email
  // with AKEmailSIPLabel label.) If you set the label to AKEmailSIPLabel,
  // it will find only the first email with that label. So, find all emails and
  // filter them later.
  ABSearchElement *SIPAddressPrefixMatch
    = [ABPerson searchElementForProperty:kABEmailProperty
                                   label:nil
                                     key:nil
                                   value:substring
                              comparison:kABPrefixMatchCaseInsensitive];
  
  [searchElements addObject:SIPAddressPrefixMatch];
  
  ABSearchElement *compoundMatch
    = [ABSearchElement searchElementForConjunction:kABSearchOr
                                          children:searchElements];
  
  // Perform Address Book search.
  NSArray *recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
  

  // Populate the completions array.
  
  NSMutableArray *completions
    = [NSMutableArray arrayWithCapacity:[recordsFound count]];
  
  for (id theRecord in recordsFound) {
    if (![theRecord isKindOfClass:[ABPerson class]])
      continue;
    
    NSString *firstName = [theRecord valueForProperty:kABFirstNameProperty];
    NSString *lastName = [theRecord valueForProperty:kABLastNameProperty];
    NSString *company = [theRecord valueForProperty:kABOrganizationProperty];
    ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
    ABMultiValue *emails = [theRecord valueForProperty:kABEmailProperty];
    NSInteger personFlags = [[theRecord valueForProperty:kABPersonFlags] integerValue];
    BOOL isPerson = (personFlags & kABShowAsMask) == kABShowAsPerson;
    BOOL isCompany = (personFlags & kABShowAsMask) == kABShowAsCompany;
    NSUInteger i;
    
    // Check for the phone number match.
    // Display completion as 1234567 (Display Name).
    for (i = 0; i < [phones count]; ++i) {
      NSString *phoneNumber = [phones valueAtIndex:i];
      
      NSRange range = [phoneNumber rangeOfString:substring];
      if (range.location == 0) {
        NSString *completionString = nil;
        if ([[theRecord ak_fullName] length] > 0) {
          completionString = [NSString stringWithFormat:@"%@ (%@)",
                              phoneNumber, [theRecord ak_fullName]];
        } else {
          completionString = phoneNumber;
        }
        
        if (completionString != nil)
          [completions addObject:completionString];
      }
    }
    
    // Check if the substing matches email labelled as AKEmailSIPLabel.
    // Display completion as email_address (Display Name).
    for (i = 0; i < [emails count]; ++i) {
      if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel]
          != NSOrderedSame)
        continue;
      
      NSString *anEmail = [emails valueAtIndex:i];
      
      NSRange range = [anEmail rangeOfString:substring
                                     options:NSCaseInsensitiveSearch];
      if (range.location == 0) {
        NSString *completionString = nil;
        
        if ([[theRecord ak_fullName] length] > 0)
          completionString = [NSString stringWithFormat:@"%@ (%@)",
                              anEmail, [theRecord ak_fullName]];
        else
          completionString = anEmail;
        
        if (completionString != nil)
          [completions addObject:completionString];
      }
    }
    
    
    // Check for first name, last name or company name match.
    
    // Determine the contact name including first and last names ordering.
    // Skip if it's not the name match.
    NSString *contactName = nil;
    if (isPerson) {
      NSString *firstNameFirst
        = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
      NSString *lastNameFirst
        = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
      NSRange firstNameFirstRange
        = [firstNameFirst rangeOfString:substring
                                options:NSCaseInsensitiveSearch];
      NSRange lastNameFirstRange
        = [lastNameFirst rangeOfString:substring
                               options:NSCaseInsensitiveSearch];
      NSRange firstNameRange
        = [firstName rangeOfString:substring options:NSCaseInsensitiveSearch];
      NSRange
        lastNameRange = [lastName rangeOfString:substring
                                        options:NSCaseInsensitiveSearch];
      
      // Continue if the substing does not match person name prefix.
      if (firstNameRange.location != 0 && lastNameRange.location != 0 &&
          firstNameFirstRange.location != 0 && lastNameFirstRange.location != 0)
        continue;
      
      if ([firstName length] > 0 && [lastName length] > 0) {
        // Determine the order of names in the full name the user is looking for.
        if (firstNameFirstRange.location == 0) {
          contactName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        } else {
          contactName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
        }
        
      } else if ([firstName length] > 0) {
        contactName = firstName;
      } else if ([lastName length] > 0) {
        contactName = lastName;
      }
      
    } else if (isCompany) {
      // Continue if the substring does not match company name prefix.
      NSRange companyNamePrefixRange
        = [company rangeOfString:substring options:NSCaseInsensitiveSearch];
      if (companyNamePrefixRange.location != 0)
        continue;
      
      if ([company length] > 0)
        contactName = company;
    }
    
    if (contactName == nil)
      continue;
    
    // Add phone numbers. Display completion as Display Name <1234567>.
    for (i = 0; i < [phones count]; ++i) {
      NSString *phoneNumber = [phones valueAtIndex:i];
      NSString *completionString = nil;
      
      if (contactName != nil) {
        completionString = [NSString stringWithFormat:@"%@ <%@>",
                            contactName, phoneNumber];
      } else {
        completionString = phoneNumber;
      }
      
      if (completionString != nil)
        [completions addObject:completionString];
    }
    
    // Add SIP address from the email fields labelled as AKEmailSIPLabel.
    // Display completion as Display Name <email_address>
    for (i = 0; i < [emails count]; ++i) {
      if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel]
          != NSOrderedSame)
        continue;
      
      NSString *anEmail = [emails valueAtIndex:i];
      NSString *completionString = nil;
      
      if (contactName != nil) {
        completionString = [NSString stringWithFormat:@"%@ <%@>",
                            contactName, anEmail];
      } else {
        completionString = anEmail;
      }
      
      if (completionString != nil)
        [completions addObject:completionString];
    }
  }
  
  
  // Preserve string capitalization according to the user input.
  if ([completions count] > 0) {
    NSRange searchedStringRange
      = [[completions objectAtIndex:0] rangeOfString:substring
                                             options:NSCaseInsensitiveSearch];
    if (searchedStringRange.location == 0) {
      NSRange replaceRange = NSMakeRange(0, [substring length]);
      NSString *newFirstElement
        = [[completions objectAtIndex:0]
           stringByReplacingCharactersInRange:replaceRange withString:substring];
      [completions replaceObjectAtIndex:0 withObject:newFirstElement];
    }
  }
  
  // Set appropriate token style depending on the search success.
  if ([completions count] > 0)
    [tokenField setTokenStyle:NSRoundedTokenStyle];
  else
    [tokenField setTokenStyle:NSPlainTextTokenStyle];
  
  return [[completions copy] autorelease];
}

// Convert input text to the array of dictionaries containing AKSIPURIs
// and phone labels (mobile, home, etc).
// Dictionary keys are AKURI and AKPhoneLabel.
// If there is no @ sign, the input is treated as a user part of the URI
// and host part will be nil.
- (id)tokenField:(NSTokenField *)tokenField
representedObjectForEditingString:(NSString *)editingString {
  
  AKSIPURIFormatter *SIPURIFormatter
    = [[[AKSIPURIFormatter alloc] init] autorelease];
  AKSIPURI *theURI = [SIPURIFormatter SIPURIFromString:editingString];
  if (theURI == nil)
    return nil;
  
  ABAddressBook *AB = [ABAddressBook sharedAddressBook];
  NSArray *recordsFound;
  
  NSAssert(([[theURI user] length] > 0),
           @"User part of the URI must not have zero length in this context");
  
  ABSearchElement *phoneNumberMatch
    = [ABPerson searchElementForProperty:kABPhoneProperty
                                   label:nil
                                     key:nil
                                   value:[theURI user]
                              comparison:kABEqual];
  
  ABSearchElement *SIPAddressMatch
    = [ABPerson searchElementForProperty:kABEmailProperty
                                   label:nil
                                     key:nil
                                   value:[theURI SIPAddress]
                              comparison:kABEqualCaseInsensitive];
  
  NSString *displayedName = [theURI displayName];
  if ([displayedName length] > 0) {
    NSMutableArray *searchElements = [[[NSMutableArray alloc] init] autorelease];
    
    // displayedName matches the first name.
    ABSearchElement *firstNameMatch
      = [ABPerson searchElementForProperty:kABFirstNameProperty
                                     label:nil
                                       key:nil
                                     value:displayedName
                                comparison:kABEqualCaseInsensitive];
    
    ABSearchElement *firstNameAndPhoneNumberMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      firstNameMatch,
                                                      phoneNumberMatch,
                                                      nil]];
    
    [searchElements addObject:firstNameAndPhoneNumberMatch];
    
    ABSearchElement *firstNameAndSIPAddressMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      firstNameMatch,
                                                      SIPAddressMatch,
                                                      nil]];
    
    [searchElements addObject:firstNameAndSIPAddressMatch];
    
    // displayedName matches the last name.
    ABSearchElement *lastNameMatch
      = [ABPerson searchElementForProperty:kABLastNameProperty
                                     label:nil
                                       key:nil
                                     value:displayedName
                                comparison:kABEqualCaseInsensitive];
    
    ABSearchElement *lastNameAndPhoneNumberMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      lastNameMatch,
                                                      phoneNumberMatch,
                                                      nil]];
    
    [searchElements addObject:lastNameAndPhoneNumberMatch];
    
    ABSearchElement *lastNameAndSIPAddressMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      lastNameMatch,
                                                      SIPAddressMatch,
                                                      nil]];
    
    [searchElements addObject:lastNameAndSIPAddressMatch];
    
    // Add person searches for all combination of displayedName components
    // separated by space.
    NSArray *displayedNameComponents
      = [displayedName componentsSeparatedByString:@" "];
    for (NSUInteger i = 0; i < [displayedNameComponents count] - 1; ++i) {
      NSMutableString *firstPart = [[[NSMutableString alloc] init] autorelease];
      NSMutableString *secondPart = [[[NSMutableString alloc] init] autorelease];
      NSUInteger j;
      
      for (j = 0; j <= i; ++j) {
        if ([firstPart length] > 0)
          [firstPart appendFormat:@" %@",
           [displayedNameComponents objectAtIndex:j]];
        else
          [firstPart appendString:[displayedNameComponents objectAtIndex:j]];
      }
      
      for (j = i + 1; j < [displayedNameComponents count]; ++j) {
        if ([secondPart length] > 0)
          [secondPart appendFormat:@" %@",
           [displayedNameComponents objectAtIndex:j]];
        else
          [secondPart appendString:[displayedNameComponents objectAtIndex:j]];
      }
      
      firstNameMatch
        = [ABPerson searchElementForProperty:kABFirstNameProperty
                                       label:nil
                                         key:nil
                                       value:firstPart
                                  comparison:kABEqualCaseInsensitive];
      lastNameMatch
        = [ABPerson searchElementForProperty:kABLastNameProperty
                                       label:nil
                                         key:nil
                                       value:secondPart
                                  comparison:kABEqualCaseInsensitive];
      
      ABSearchElement *fullNameAndPhoneNumberMatch
        = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                              children:[NSArray arrayWithObjects:
                                                        firstNameMatch,
                                                        lastNameMatch,
                                                        phoneNumberMatch,
                                                        nil]];
      
      [searchElements addObject:fullNameAndPhoneNumberMatch];
      
      ABSearchElement *fullNameAndSIPAddressMatch
        = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                              children:[NSArray arrayWithObjects:
                                                        firstNameMatch,
                                                        lastNameMatch,
                                                        SIPAddressMatch,
                                                        nil]];
      
      [searchElements addObject:fullNameAndSIPAddressMatch];
      
      // Swap the first and the last names.
      firstNameMatch
        = [ABPerson searchElementForProperty:kABFirstNameProperty
                                       label:nil
                                         key:nil
                                       value:secondPart
                                  comparison:kABEqualCaseInsensitive];
      lastNameMatch
        = [ABPerson searchElementForProperty:kABLastNameProperty
                                       label:nil
                                         key:nil
                                       value:firstPart
                                  comparison:kABEqualCaseInsensitive];
      
      fullNameAndPhoneNumberMatch
        = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                              children:[NSArray arrayWithObjects:
                                                        firstNameMatch,
                                                        lastNameMatch,
                                                        phoneNumberMatch,
                                                        nil]];
      
      [searchElements addObject:fullNameAndPhoneNumberMatch];
      
      fullNameAndSIPAddressMatch
        = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                              children:[NSArray arrayWithObjects:
                                                        firstNameMatch,
                                                        lastNameMatch,
                                                        SIPAddressMatch,
                                                        nil]];
      
      [searchElements addObject:fullNameAndSIPAddressMatch];
    }
    
    // Add organization search.
    ABSearchElement *organizationMatch
      = [ABPerson searchElementForProperty:kABOrganizationProperty
                                     label:nil
                                       key:nil
                                     value:displayedName
                                comparison:kABEqualCaseInsensitive];
    
    ABSearchElement *organizationAndPhoneNumberMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      organizationMatch,
                                                      phoneNumberMatch,
                                                      nil]];
    
    [searchElements addObject:organizationAndPhoneNumberMatch];
    
    ABSearchElement *organizationAndSIPAddressMatch
      = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                            children:[NSArray arrayWithObjects:
                                                      organizationMatch,
                                                      SIPAddressMatch,
                                                      nil]];
    
    [searchElements addObject:organizationAndSIPAddressMatch];
    
    ABSearchElement *compoundMatch
      = [ABSearchElement searchElementForConjunction:kABSearchOr
                                            children:searchElements];
    
    recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
    
  } else {
    recordsFound = [AB recordsMatchingSearchElement:phoneNumberMatch];
  }
  
  NSMutableArray *callDestinations = [[[NSMutableArray alloc] init] autorelease];
  NSUInteger destinationIndex = 0;
  
  if ([recordsFound count] > 0) {
    ABRecord *theRecord = [recordsFound objectAtIndex:0];
    
    if ([[theRecord ak_fullName] length] > 0)
      [theURI setDisplayName:[theRecord ak_fullName]];
    
    // Get phones.
    AKTelephoneNumberFormatter *telephoneNumberFormatter
      = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
    ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
    for (NSUInteger i = 0; i < [phones count]; ++i) {
      NSString *phoneNumber = [phones valueAtIndex:i];
      NSString *localizedPhoneLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
      
      AKSIPURI *uri = [SIPURIFormatter SIPURIFromString:phoneNumber];
      [uri setDisplayName:[theURI displayName]];
      [callDestinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   uri, kURI,
                                   localizedPhoneLabel, kPhoneLabel,
                                   nil]];
      
      // If we've met entered URI, store its index.
      NSRange atSignRange = [phoneNumber rangeOfString:@"@"];
      if (atSignRange.location == NSNotFound && [[theURI host] length] == 0) {
        // No @ sign, treat as telephone number.
        if ([[telephoneNumberFormatter telephoneNumberFromString:phoneNumber]
             isEqualToString:
             [telephoneNumberFormatter telephoneNumberFromString:[theURI user]]])
        {
          destinationIndex = [callDestinations count] - 1;
        }
      } else {
        if ([phoneNumber isEqualToString:[theURI SIPAddress]]) {
          destinationIndex = [callDestinations count] - 1;
        }
      }
    }
    
    // Get SIP addresses.
    ABMultiValue *emails = [theRecord valueForProperty:kABEmailProperty];
    for (NSUInteger i = 0; i < [emails count]; ++i) {
      if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel]
          != NSOrderedSame)
        continue;
      
      NSString *anEmail = [emails valueAtIndex:i];
      NSString *localizedPhoneLabel = [AB ak_localizedLabel:kEmailSIPLabel];
      
      AKSIPURI *uri = [SIPURIFormatter SIPURIFromString:anEmail];
      [uri setDisplayName:[theURI displayName]];
      [callDestinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   uri, kURI,
                                   localizedPhoneLabel, kPhoneLabel,
                                   nil]];
      
      // If we've met entered URI, store its index.
      if ([anEmail caseInsensitiveCompare:[theURI SIPAddress]] == NSOrderedSame) {
        destinationIndex = [callDestinations count] - 1;
      }
    }
    
  } else {
    [callDestinations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 theURI, kURI,
                                 @"", kPhoneLabel, nil]];
  }
  
  // First URI in the array is the default call destination.
  [self setCallDestinationURIIndex:destinationIndex];
  
  return [[callDestinations copy] autorelease];
}

- (NSString *)tokenField:(NSTokenField *)tokenField
displayStringForRepresentedObject:(id)representedObject {
  
  if (![representedObject isKindOfClass:[NSArray class]])
    return nil;
  
  AKSIPURI *uri
    = [[representedObject objectAtIndex:[self callDestinationURIIndex]]
       objectForKey:kURI];
  
  NSString *returnString = nil;
  
  if ([[uri displayName] length] > 0) {
    returnString = [uri displayName];
    
  } else if ([[uri host] length] > 0) {
    NSAssert(([[uri user] length] > 0),
             @"User part of the URI must not have zero length in this context");
    
    returnString = [uri SIPAddress];
    
  } else {
    NSAssert(([[uri user] length] > 0),
             @"User part of the URI must not have zero length in this context");
    
    if ([[uri user] ak_isTelephoneNumber]) {
      AKTelephoneNumberFormatter *formatter
        = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
      [formatter setSplitsLastFourDigits:
       [[NSUserDefaults standardUserDefaults]
        boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
      returnString = [formatter stringForObjectValue:[uri user]];
      
    } else {
      returnString = [uri user];
    }
  }
  
  return returnString;
}

- (NSString *)tokenField:(NSTokenField *)tokenField
editingStringForRepresentedObject:(id)representedObject {
  
  if (![representedObject isKindOfClass:[NSArray class]])
    return nil;
  
  AKSIPURI *uri
    = [[representedObject objectAtIndex:[self callDestinationURIIndex]]
       objectForKey:kURI];
  
  NSAssert(([[uri user] length] > 0),
           @"User part of the URI must not have zero length in this context");
  
  NSString *returnString = nil;
  
  if ([[uri displayName] length] > 0) {
    if ([[uri host] length] > 0) {
      returnString = [NSString stringWithFormat:@"%@ <%@>",
                      [uri displayName], [uri SIPAddress]];
    } else {
      returnString =  [NSString stringWithFormat:@"%@ <%@>",
                       [uri displayName], [uri user]];
    }
  } else if ([[uri host] length] > 0) {
    returnString =  [uri SIPAddress];
    
  } else {
    returnString =  [uri user];
  }
  
  return returnString;
}

- (BOOL)tokenField:(NSTokenField *)tokenField
hasMenuForRepresentedObject:(id)representedObject {
  
  AKSIPURI *uri
    = [[representedObject objectAtIndex:[self callDestinationURIIndex]]
       objectForKey:kURI];
  
  if ([representedObject isKindOfClass:[NSArray class]] &&
      [[uri displayName] length] > 0)
    return YES;
  else
    return NO;
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField
menuForRepresentedObject:(id)representedObject {
  
  NSMenu *tokenMenu = [[[NSMenu alloc] init] autorelease];
  
  for (NSUInteger i = 0; i < [representedObject count]; ++i) {
    AKSIPURI *uri = [[representedObject objectAtIndex:i] objectForKey:kURI];
    
    NSString *phoneLabel
      = [[representedObject objectAtIndex:i] objectForKey:kPhoneLabel];
    
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    
    AKTelephoneNumberFormatter *formatter
      = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
    [formatter setSplitsLastFourDigits:
     [[NSUserDefaults standardUserDefaults]
      boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
    
    if ([[uri host] length] > 0) {
      [menuItem setTitle:[NSString stringWithFormat:@"%@: %@",
                          phoneLabel, [uri SIPAddress]]];
      
    } else if ([[uri user] ak_isTelephoneNumber]) {
      [menuItem setTitle:[NSString stringWithFormat:@"%@: %@",
                          phoneLabel,
                          [formatter stringForObjectValue:[uri user]]]];
    } else {
      [menuItem setTitle:[NSString stringWithFormat:@"%@: %@",
                          phoneLabel, [uri user]]];
    }
    
    [menuItem setTag:i];
    [menuItem setAction:@selector(changeCallDestinationURIIndex:)];
    
    [tokenMenu addItem:menuItem];
  }
  
  [[tokenMenu itemWithTag:[self callDestinationURIIndex]] setState:NSOnState];
  
  return tokenMenu;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField
       shouldAddObjects:(NSArray *)tokens
                atIndex:(NSUInteger)index {
  if (index > 0)
    return nil;
  else
    return tokens;
}

@end
