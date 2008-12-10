//
//  AKAccountController.m
//  Telephone
//
//  Copyright (c) 2008 Alexei Kuznetsov. All rights reserved.
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

#import <AddressBook/AddressBook.h>

#import "AKAccountController.h"
#import "AKCallController.h"
#import "AKKeychain.h"
#import "AKPreferenceController.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "AKTelephoneNumberFormatter.h"
#import "AppController.h"
#import "NSStringAdditions.h"
#import "NSWindowAdditions.h"


// Account registration pull-down button widths.
const CGFloat AKAccountRegistrationButtonOfflineWidth = 58.0;
const CGFloat AKAccountRegistrationButtonAvailableWidth = 69.0;
const CGFloat AKAccountRegistrationButtonConnectingWidth = 90.0;
const CGFloat AKAccountRegistrationButtonDisconnectedWidth = 91.0;

// Account registration pull-down button titles.
NSString * const AKAccountRegistrationButtonOfflineTitle = @"Offline";
NSString * const AKAccountRegistrationButtonAvailableTitle = @"Available";
NSString * const AKAccountRegistrationButtonConnectingTitle = @"Connecting...";
NSString * const AKAccountRegistrationButtonDisconnectedTitle = @"Disconnected";

@implementation AKAccountController

@synthesize account;
@dynamic accountRegistered;
@synthesize callControllers;
@synthesize callDestinationURIIndex;

- (BOOL)isAccountRegistered
{
	return [[self account] isRegistered];
}

- (void)setAccountRegistered:(BOOL)flag
{
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	
	if (flag) {
		if ([[self account] identifier] != AKTelephoneInvalidIdentifier) {	// If account was added to Telephone.
			// Set registraton button title to Connecting...
			buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonConnectingTitle];
			
			// Explicitly redisplay button before DNS will look up the registrar host name.
			[[accountRegistrationPopUp superview] display];
			
			[[self account] setRegistered:flag];
		} else {
			NSString *password = [AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@", [[self account] registrar]]
														accountName:[[self account] username]];
			
			// Set registraton button title to Connecting...
			buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonConnectingTitle];
			
			// Explicitly redisplay button before DNS will look up the registrar host name.
			[[accountRegistrationPopUp superview] display];
			
			// Add account to Telephone
			[[[NSApp delegate] telephone] addAccount:[self account] withPassword:password];
			
			// Error connecting to registrar.
			if (![self isAccountRegistered] && [[self account] registrationExpireTime] < 0) {
				// Set registraton button title to Disconnected.
				buttonSize.width = AKAccountRegistrationButtonDisconnectedWidth;
				[accountRegistrationPopUp setFrameSize:buttonSize];
				[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonDisconnectedTitle];
				
				// Show sheet only if Telephone didn't start.
				if ([[[NSApp delegate] telephone] started])
					[self showRegistrarConnectionErrorSheet];
			}
		}
		
	} else {
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountRegisterTag] setState:NSOffState];
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountUnregisterTag] setState:NSOnState];
		[[self window] setContentView:unregisteredAccountView];
		
		// Set registraton button title to Offline.
		buttonSize.width = AKAccountRegistrationButtonOfflineWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonOfflineTitle];
		
		// Explicitly redisplay account window before DNS will look up the registrar host name.
		[[self window] display];
		
		[[self account] setRegistered:flag];
	}
}

- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount
{
	self = [super initWithWindowNibName:@"Account"];
	if (self == nil)
		return nil;
	
	[self setAccount:anAccount];
	callControllers = [[NSMutableArray alloc] init];
	[self setCallDestinationURIIndex:0];
	
	[account setDelegate:self];
	
	return self;
}

- (id)initWithFullName:(NSString *)aFullName
			SIPAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername
{
	AKTelephoneAccount *anAccount = [AKTelephoneAccount telephoneAccountWithFullName:aFullName
																		  SIPAddress:aSIPAddress
																		   registrar:aRegistrar
																			   realm:aRealm
																			username:aUsername];
	return [self initWithTelephoneAccount:anAccount];
}

- (void)dealloc
{
	// Close all call controllers.
	for (AKCallController *aCallController in [[[self callControllers] copy] autorelease])
		[aCallController close];
	
	if ([[[self account] delegate] isEqual:self])
		[[self account] setDelegate:nil];
	
	// Close authentication failure sheet if it's raised
	[authenticationFailureCancelButton performClick:nil];
	
	[[[NSApp delegate] telephone] removeAccount:[self account]];
	[account release];
	[callControllers release];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ controller", [self account]];
}

- (void)awakeFromNib
{
	[self setShouldCascadeWindows:NO];
	[[self window] setFrameAutosaveName:[[self account] SIPAddress]];
	
	// Exclude comma from the callDestination tokenizing character set.
	[callDestination setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
	
	[callDestination setCompletionDelay:0.4];
}

// Ask model to make call, create call controller, attach the call to the call contoller
- (IBAction)makeCall:(id)sender
{
	AKSIPURI *uri = [[[[[callDestination objectValue] objectAtIndex:0] objectAtIndex:[self callDestinationURIIndex]] copy] autorelease];
	if (![uri isKindOfClass:[AKSIPURI class]])
		return;
	
	if ([[uri user] length] <= 0)
		return;
	
	if ([[uri host] length] <= 0)
		[uri setHost:[[[self account] registrationURI] host]];
	
	// Preserve the original string entered by the user or found in the Address Book.
	NSString *userInput = [uri user];
	
	// Get the clean string of contigiuous digits if the user part does not contain letters.
	NSPredicate *containsLettersPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*[a-zA-Z].*'"];
	if (![containsLettersPredicate evaluateWithObject:[uri user]]) {
		AKTelephoneNumberFormatter *telephoneNumberFormatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
		[uri setUser:[telephoneNumberFormatter telephoneNumberFromString:[uri user]]];
	}
	
	// Actually, the call will be made to the copy of the URI without
	// display-name part to prevent another call party to see local Address Book record.
	AKSIPURI *cleanURI = [uri copy];
	[cleanURI setDisplayName:nil];
	
	// Make actual call.
	AKTelephoneCall *aCall = [[self account] makeCallTo:cleanURI];
	if (aCall != nil) {
		AKCallController *aCallController = [[AKCallController alloc] initWithTelephoneCall:aCall
																		  accountController:self];
		[[self callControllers] addObject:aCallController];
		
		if ([[uri displayName] length] == 0 && ![userInput AK_isTelephoneNumber]) {
			[aCallController setDisplayedName:userInput];
		} else {	
			AKSIPURIFormatter *SIPURIFormatter = [[[AKSIPURIFormatter alloc] init] autorelease];
			[aCallController setDisplayedName:[SIPURIFormatter stringForObjectValue:uri]];
		}
		
		[[aCallController window] setContentView:[aCallController activeCallView]];
		[aCallController setStatus:@"calling..."];
		[aCallController showWindow:nil];
		[[aCallController callProgressIndicator] startAnimation:self];
		
		[aCallController release];
	}
}

- (IBAction)changeAccountRegistration:(id)sender
{	
	if (![self isAccountRegistered] && [[sender selectedItem] tag] == AKTelephoneAccountUnregisterTag)
		return;
	
	[self setAccountRegistered:[[sender selectedItem] tag]];
}

// Remove old account from Telephone, change username for the account, add to Telephone with new password and update Keychain.
- (IBAction)changeUsernameAndPassword:(id)sender
{
	[self closeSheet:sender];
	
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	
	if (![[newUsername stringValue] isEqualToString:@""]) {
		[[[NSApp delegate] telephone] removeAccount:[self account]];
		[[self account] setUsername:[newUsername stringValue]];
		
		// Set registraton button title to Connecting...
		buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonConnectingTitle];
		
		// Add account to Telephone.
		[[[NSApp delegate] telephone] addAccount:[self account] withPassword:[newPassword stringValue]];
		
		// Error connecting to registrar.
		if (![self isAccountRegistered] && [[self account] registrationExpireTime] < 0) {
			// Set registraton button title to Disconnected.
			buttonSize.width = AKAccountRegistrationButtonDisconnectedWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonDisconnectedTitle];
			
			[self showRegistrarConnectionErrorSheet];
		}
		
		if ([mustSave state] == NSOnState)
			[AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [[self account] registrar]]
								   accountName:[newUsername stringValue]
									  password:[newPassword stringValue]];
	}
	
	[newPassword setStringValue:@""];
}

- (IBAction)closeSheet:(id)sender
{
	[NSApp endSheet:[sender window]];
	[[sender window] orderOut:self];
}

- (IBAction)changeCallDestinationURIIndex:(id)sender
{
	[self setCallDestinationURIIndex:[sender tag]];
}

- (void)showRegistrarConnectionErrorSheet
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:[NSString stringWithFormat:@"Could not connect to server %@.", [[self account] registrar]]];
	[alert setInformativeText:[NSString stringWithFormat:
							   @"Please, check network connection and Registry Server settings.",
							   [[self account] registrar]]];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:nil
					 didEndSelector:NULL
						contextInfo:NULL];
}

- (void)windowDidLoad
{
	// Set registraton button title to Offline.
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	buttonSize.width = AKAccountRegistrationButtonOfflineWidth;
	[accountRegistrationPopUp setFrameSize:buttonSize];
	[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonOfflineTitle];
}

// When account registration changes, make appropriate modifications in UI
- (void)telephoneAccountRegistrationDidChange:(NSNotification *)notification
{
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	
	if ([[self account] isRegistered]) {
		// Set registraton button title to Available.
		buttonSize.width = AKAccountRegistrationButtonAvailableWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonAvailableTitle];
		
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountRegisterTag] setState:NSOnState];
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountUnregisterTag] setState:NSOffState];
		[[self window] setContentView:registeredAccountView];
		
		if ([callDestination acceptsFirstResponder])
			[[self window] makeFirstResponder:callDestination];
		
	} else {
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountRegisterTag] setState:NSOffState];
		[[[accountRegistrationPopUp menu] itemWithTag:AKTelephoneAccountUnregisterTag] setState:NSOnState];
		[[self window] setContentView:unregisteredAccountView];
		
		// Handle authentication failure
		if ([[self account] registrationStatus] == PJSIP_EFAILEDCREDENTIAL) {
			// Set registraton button title to Disconnected.
			buttonSize.width = AKAccountRegistrationButtonDisconnectedWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonDisconnectedTitle];
			
			if (authenticationFailureSheet == nil)
				[NSBundle loadNibNamed:@"AuthFailed" owner:self];
			
			[updateCredentialsInformativeText setStringValue:
			 [NSString stringWithFormat:@"Telehone was unable to login to %@. Change user name or password and try again.",
			  [[self account] registrar]]];
			[newUsername setStringValue:[[self account] username]];
			[newPassword setStringValue:@""];
			
			[NSApp beginSheet:authenticationFailureSheet
			   modalForWindow:[self window]
				modalDelegate:nil
			   didEndSelector:NULL
				  contextInfo:NULL];
			
		} else if ([[self account] registrationStatus] == PJSIP_SC_NOT_FOUND ||
				   [[self account] registrationStatus] == PJSIP_SC_FORBIDDEN ||
				   [[self account] registrationStatus] == PJSIP_EAUTHNOCHAL) {
			// Set registraton button title to Disconnected.
			buttonSize.width = AKAccountRegistrationButtonDisconnectedWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonDisconnectedTitle];
			
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:[NSString stringWithFormat:@"SIP address “%@” does not match the user name “%@”.",
								   [[self account] SIPAddress], [[self account] username]]];
			[alert setInformativeText:@"Please, check your SIP Address."];
			[alert beginSheetModalForWindow:[self window]
							  modalDelegate:nil
							 didEndSelector:NULL
								contextInfo:NULL];
			
		} else if (([[self account] registrationStatus] / 100 != 2) && ([[self account] registrationExpireTime] < 0)) {
			// Change registration status button title and raise sheet if connection to the registrar failed.
			// If last registration status is 2xx and expiration interval is less than zero, it is unregistration, not failure.
			// Condition of failure is: last registration status != 2xx AND expiration interval < 0.
			
			// Set registraton button title to Disconnected.
			buttonSize.width = AKAccountRegistrationButtonDisconnectedWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonDisconnectedTitle];
			
			// Show a sheet only if Telephone has started. Don't show if user agent is being destroyed right now.
			if ([[[NSApp delegate] telephone] started])
				[self showRegistrarConnectionErrorSheet];
			
		} else {
			// Set registraton button title to Offline.
			buttonSize.width = AKAccountRegistrationButtonOfflineWidth;
			[accountRegistrationPopUp setFrameSize:buttonSize];
			[accountRegistrationPopUp setTitle:AKAccountRegistrationButtonOfflineTitle];
		}
	}
}

// Remove call controller from array of controllers before the window is closed
- (void)telephoneCallWindowWillClose:(NSNotification *)notification
{
	AKCallController *aCallController = [notification object];
	[[self callControllers] removeObject:aCallController];
}


#pragma mark -
#pragma mark AKTelephoneAccountDelegate protocol

// When the call is received, create call controller, add to array, show call window
- (void)telephoneAccountDidReceiveCall:(AKTelephoneCall *)aCall
{
	AKCallController *aCallController = [[AKCallController alloc] initWithTelephoneCall:aCall
																	  accountController:self];
	[[self callControllers] addObject:aCallController];
	
	AKSIPURIFormatter *formatter = [[[AKSIPURIFormatter alloc] init] autorelease];
	[aCallController setDisplayedName:[formatter stringForObjectValue:[aCall remoteURI]]];
	[aCallController setStatus:@"calling"];
	[[aCallController window] resizeAndSwapToContentView:[aCallController incomingCallView]];
	[aCallController showWindow:nil];
	
	[[[NSApp delegate] incomingCallSound] play];
	[[NSApp delegate] startIncomingCallSoundTimer];
	
	[aCallController release];
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
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	ABAddressBook *AB = [ABAddressBook sharedAddressBook];
	NSMutableArray *searchElements = [[NSMutableArray alloc] init];
	NSArray *substringComponents = [substring componentsSeparatedByString:@" "];
	
	// Entered substring matches the first name prefix.
	ABSearchElement *firstNamePrefixMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
																		 label:nil
																		   key:nil
																		 value:substring
																	comparison:kABPrefixMatchCaseInsensitive];
	[searchElements addObject:firstNamePrefixMatch];
	
	// Entered substring matches the last name prefix.
	ABSearchElement *lastNamePrefixMatch =  [ABPerson searchElementForProperty:kABLastNameProperty
																		 label:nil
																		   key:nil
																		 value:substring
																	comparison:kABPrefixMatchCaseInsensitive];
	[searchElements addObject:lastNamePrefixMatch];
	
	
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
		
		ABSearchElement *firstNameMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
																	   label:nil
																		 key:nil
																	   value:firstPart
																  comparison:kABEqualCaseInsensitive];
		
		if ([secondPart length] > 0) {		// Search element for the prefix match of the last name.
			lastNamePrefixMatch = [ABPerson searchElementForProperty:kABLastNameProperty
															   label:nil
																 key:nil
															   value:secondPart
														  comparison:kABPrefixMatchCaseInsensitive];
		} else {							// Search element for the existence of the last name.
			lastNamePrefixMatch = [ABPerson searchElementForProperty:kABLastNameProperty
															   label:nil
																 key:nil
															   value:nil
														  comparison:kABNotEqual];
		}

		ABSearchElement *firstNameAndLastNamePrefixMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																							   children:[NSArray arrayWithObjects:
																										 firstNameMatch,
																										 lastNamePrefixMatch,
																										 nil]];
		[searchElements addObject:firstNameAndLastNamePrefixMatch];
		
		// Swap the first and the last names in search.
		ABSearchElement *lastNameMatch = [ABPerson searchElementForProperty:kABLastNameProperty
																	  label:nil
																		key:nil
																	  value:firstPart
																 comparison:kABEqualCaseInsensitive];
		
		if ([secondPart length] > 0) {		// Search element for the prefix match of the first name.
			firstNamePrefixMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
																label:nil
																  key:nil
																value:secondPart
														   comparison:kABPrefixMatchCaseInsensitive];
		} else {							// Search element for the existence of the first name.
			firstNamePrefixMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
																label:nil
																  key:nil
																value:nil
														   comparison:kABNotEqual];
		}

		ABSearchElement *lastNameAndFirstNamePrefixMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																							   children:[NSArray arrayWithObjects:
																										 lastNameMatch,
																										 firstNamePrefixMatch,
																										 nil]];
		[searchElements addObject:lastNameAndFirstNamePrefixMatch];
	}
	
	ABSearchElement *isCompanyRecord = [ABPerson searchElementForProperty:kABPersonFlags
																   label:nil
																	 key:nil
																   value:[NSNumber numberWithInteger:kABShowAsCompany]
															  comparison:kABBitsInBitFieldMatch];
	
	// Entered substring matches company name prefix.
	ABSearchElement *companyPrefixMatch = [ABPerson searchElementForProperty:kABOrganizationProperty
																	   label:nil
																		 key:nil
																	   value:substring
																  comparison:kABPrefixMatchCaseInsensitive];
	
	// Don't bother if the AB record is not a company record.
	ABSearchElement *companyPrefixAndIsCompanyRecord = [ABSearchElement searchElementForConjunction:kABSearchAnd
																						   children:[NSArray arrayWithObjects:
																									 companyPrefixMatch,
																									 isCompanyRecord,
																									 nil]];
	[searchElements addObject:companyPrefixAndIsCompanyRecord];
	
	// Entered substring matches phone number prefix.
	ABSearchElement *phoneNumberPrefixMatch = [ABPerson searchElementForProperty:kABPhoneProperty
																		   label:nil
																			 key:nil
																		   value:substring
																	  comparison:kABPrefixMatch];
	[searchElements addObject:phoneNumberPrefixMatch];
	
	ABSearchElement *compoundMatch = [ABSearchElement searchElementForConjunction:kABSearchOr children:searchElements];
	[searchElements release];
	
	// Perform Address Book search.
	NSArray *recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
	
	// Set appropriate token style depending on the search success.
	if ([recordsFound count] > 0)
		[tokenField setTokenStyle:NSRoundedTokenStyle];
	else
		[tokenField setTokenStyle:NSPlainTextTokenStyle];
	
	
	// Populate the completions array.
	
	NSMutableArray *completions = [NSMutableArray arrayWithCapacity:[recordsFound count]];
	
	for (id theRecord in recordsFound) {
		if (![theRecord isKindOfClass:[ABPerson class]])
			continue;
		
		NSString *firstName = [theRecord valueForProperty:kABFirstNameProperty];
		NSString *lastName = [theRecord valueForProperty:kABLastNameProperty];
		NSString *company = [theRecord valueForProperty:kABOrganizationProperty];
		ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
		NSInteger personFlags = [[theRecord valueForProperty:kABPersonFlags] integerValue];
		BOOL isPerson = (personFlags & kABShowAsMask) == kABShowAsPerson;
		BOOL isCompany = (personFlags & kABShowAsMask) == kABShowAsCompany;
		BOOL phoneNumberMatched = NO;
		NSUInteger i;
		
		// Check for the phone number match. Display completion as 1234567 (Display Name).
		for (i = 0; i < [phones count]; ++i) {
			NSString *phoneNumber = [phones valueAtIndex:i];
			
			NSRange range = [phoneNumber rangeOfString:substring];
			if (range.location == 0) {
				phoneNumberMatched = YES;
				
				NSString *completionString = nil;
				
				if (isPerson) {
					if ([firstName length] > 0 && [lastName length] > 0) {
						if ([AB defaultNameOrdering] == kABFirstNameFirst) {
							completionString = [[NSString alloc] initWithFormat:@"%@ (%@ %@)",
												phoneNumber, [firstName AK_escapeParentheses], [lastName AK_escapeParentheses]];
						} else {
							completionString = [[NSString alloc] initWithFormat:@"%@ (%@ %@)",
												phoneNumber, [lastName AK_escapeParentheses], [firstName AK_escapeParentheses]];
						}
					} else if ([firstName length] > 0) {
						completionString = [[NSString alloc] initWithFormat:@"%@ (%@)", phoneNumber, [firstName AK_escapeParentheses]];
					} else if ([lastName length] > 0) {
						completionString = [[NSString alloc] initWithFormat:@"%@ (%@)", phoneNumber, [lastName AK_escapeParentheses]];
					} else {
						completionString = [[NSString alloc] initWithFormat:@"%@", phoneNumber];
					}
				} else if (isCompany) {
					if ([company length] > 0) {
						completionString = [[NSString alloc] initWithFormat:@"%@ (%@)", phoneNumber, [company AK_escapeParentheses]];
					} else {
						completionString = [[NSString alloc] initWithFormat:@"%@", phoneNumber];
					}
				}
				
				if (completionString != nil) {
					[completions addObject:completionString];
					[completionString release];
				}
			}
		}
		
		if (phoneNumberMatched)
			continue;

		// Check for first name, last name or company name match. Display completion as Display Name <1234567>.
		for (i = 0; i < [phones count]; ++i) {
			NSString *phoneNumber = [phones valueAtIndex:i];
			NSString *completionString = nil;
			
			if (isPerson) {
				if ([firstName length] > 0 && [lastName length] > 0) {
					// Determine the order of names in the full name the user is looking for.
					NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
					NSRange fullNameRange = [fullName rangeOfString:substring options:NSCaseInsensitiveSearch];
					[fullName release];
					if (fullNameRange.location == 0) {
						completionString = [[NSString alloc] initWithFormat:@"%@ %@ <%@>", firstName, lastName, phoneNumber];
					} else {
						completionString = [[NSString alloc] initWithFormat:@"%@ %@ <%@>", lastName, firstName, phoneNumber];
					}
				} else if ([firstName length] > 0) {
					completionString = [[NSString alloc] initWithFormat:@"%@ <%@>", firstName, phoneNumber];
				} else if ([lastName length] > 0) {
					completionString = [[NSString alloc] initWithFormat:@"%@ <%@>", lastName, phoneNumber];
				} else {
					completionString = [[NSString alloc] initWithFormat:@"%@", phoneNumber];
				}
			} else if (isCompany) {
				if ([company length] > 0) {
					completionString = [[NSString alloc] initWithFormat:@"%@ <%@>", company, phoneNumber];
				} else {
					completionString = [[NSString alloc] initWithFormat:@"%@", phoneNumber];
				}
			}
			
			if (completionString != nil) {
				[completions addObject:completionString];
				[completionString release];
			}
		}
	}
	
	// Preserve case of the completion according to the user input.
	if ([completions count] > 0) {
		NSRange searchedStringRange = [[completions objectAtIndex:0] rangeOfString:substring options:NSCaseInsensitiveSearch];
		if (searchedStringRange.location == 0) {
			NSRange replaceRange = NSMakeRange(0, [substring length]);
			NSString *newFirstElement = [[completions objectAtIndex:0] stringByReplacingCharactersInRange:replaceRange
																							   withString:substring];
			[completions replaceObjectAtIndex:0 withObject:newFirstElement];
		}
	}
	
	return [[completions copy] autorelease];
}

// Convert input text to the array of AKSIPURIs.
// If there is no @ sign, the input is treated as a user part of the URI and host part will be nil.
- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
	AKSIPURIFormatter *SIPURIFormatter = [[[AKSIPURIFormatter alloc] init] autorelease];
	AKSIPURI *theURI = [SIPURIFormatter SIPURIFromString:editingString];
	if (theURI == nil)
		return nil;
	
	NSMutableArray *URIs = [[[NSMutableArray alloc] init] autorelease];
	[URIs addObject:theURI];
	
	ABAddressBook *AB = [ABAddressBook sharedAddressBook];
	NSArray *recordsFound;
	
	NSAssert(([[theURI user] length] > 0), @"User part of the URI must not have zero length in this context");
	ABSearchElement *phoneNumberMatch = [ABPerson searchElementForProperty:kABPhoneProperty
																	 label:nil
																	   key:nil
																	 value:[theURI user]
																comparison:kABEqual];
	NSString *displayedName = [theURI displayName];
	if ([displayedName length] > 0) {
		NSMutableArray *searchElements = [[[NSMutableArray alloc] init] autorelease];
		
		// displayedName matches the first name.
		ABSearchElement *firstNameMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
																	   label:nil
																		 key:nil
																	   value:displayedName
																  comparison:kABEqualCaseInsensitive];
		ABSearchElement *firstNameAndPhoneNumberMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																							children:[NSArray arrayWithObjects:
																									  firstNameMatch,
																									  phoneNumberMatch,
																									  nil]];
		[searchElements addObject:firstNameAndPhoneNumberMatch];
		
		// displayedName matches the last name.
		ABSearchElement *lastNameMatch = [ABPerson searchElementForProperty:kABLastNameProperty
																	  label:nil
																		key:nil
																	  value:displayedName
																 comparison:kABEqualCaseInsensitive];
		ABSearchElement *lastNameAndPhoneNumberMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																						   children:[NSArray arrayWithObjects:
																									 lastNameMatch,
																									 phoneNumberMatch,
																									 nil]];
		[searchElements addObject:lastNameAndPhoneNumberMatch];
		
		// Add person searches for all combination of displayedName components separated by space.
		NSArray *displayedNameComponents = [displayedName componentsSeparatedByString:@" "];
		for (NSUInteger i = 0; i < [displayedNameComponents count] - 1; ++i) {
			NSMutableString *firstPart = [[[NSMutableString alloc] init] autorelease];
			NSMutableString *secondPart = [[[NSMutableString alloc] init] autorelease];
			NSUInteger j;
			
			for (j = 0; j <= i; ++j) {
				if ([firstPart length] > 0)
					[firstPart appendFormat:@" %@", [displayedNameComponents objectAtIndex:j]];
				else
					[firstPart appendString:[displayedNameComponents objectAtIndex:j]];
			}
			
			for (j = i + 1; j < [displayedNameComponents count]; ++j) {
				if ([secondPart length] > 0)
					[secondPart appendFormat:@" %@", [displayedNameComponents objectAtIndex:j]];
				else
					[secondPart appendString:[displayedNameComponents objectAtIndex:j]];
			}
			
			firstNameMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
														  label:nil
															key:nil
														  value:firstPart
													 comparison:kABEqualCaseInsensitive];
			lastNameMatch = [ABPerson searchElementForProperty:kABLastNameProperty
														 label:nil
														   key:nil
														 value:secondPart
													comparison:kABEqualCaseInsensitive];
			ABSearchElement *fullNameAndPhoneNumberMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																							   children:[NSArray arrayWithObjects:
																										 firstNameMatch,
																										 lastNameMatch,
																										 phoneNumberMatch,
																										 nil]];
			[searchElements addObject:fullNameAndPhoneNumberMatch];
			
			// Swap the first and the last names.
			firstNameMatch = [ABPerson searchElementForProperty:kABFirstNameProperty
														  label:nil
															key:nil
														  value:secondPart
													 comparison:kABEqualCaseInsensitive];
			lastNameMatch = [ABPerson searchElementForProperty:kABLastNameProperty
														 label:nil
														   key:nil
														 value:firstPart
													comparison:kABEqualCaseInsensitive];
			fullNameAndPhoneNumberMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																			  children:[NSArray arrayWithObjects:
																						firstNameMatch,
																						lastNameMatch,
																						phoneNumberMatch,
																						nil]];
			[searchElements addObject:fullNameAndPhoneNumberMatch];
		}
		
		// Add organization search.
		ABSearchElement *organizationMatch = [ABPerson searchElementForProperty:kABOrganizationProperty
																		  label:nil
																			key:nil
																		  value:displayedName
																	 comparison:kABEqualCaseInsensitive];
		ABSearchElement *organizationAndPhoneNumberMatch = [ABSearchElement searchElementForConjunction:kABSearchAnd
																							   children:[NSArray arrayWithObjects:
																										 organizationMatch,
																										 phoneNumberMatch,
																										 nil]];
		[searchElements addObject:organizationAndPhoneNumberMatch];
		
		ABSearchElement *compoundMatch = [ABSearchElement searchElementForConjunction:kABSearchOr
																			 children:searchElements];
		recordsFound = [AB recordsMatchingSearchElement:compoundMatch];

	} else {
		recordsFound = [AB recordsMatchingSearchElement:phoneNumberMatch];
	}
	
	if ([recordsFound count] > 0) {
		ABRecord *theRecord = [recordsFound objectAtIndex:0];
		
		NSString *firstName = [theRecord valueForProperty:kABFirstNameProperty];
		NSString *lastName = [theRecord valueForProperty:kABLastNameProperty];
		NSString *company = [theRecord valueForProperty:kABOrganizationProperty];
		NSInteger personFlags = [[theRecord valueForProperty:kABPersonFlags] integerValue];
		BOOL isPerson = (personFlags & kABShowAsMask) == kABShowAsPerson;
		BOOL isCompany = (personFlags & kABShowAsMask) == kABShowAsCompany;
		
		// Set person name as a displayName.
		if (isPerson) {
			if ([firstName length] > 0 && [lastName length] > 0) {
				if ([AB defaultNameOrdering] == kABFirstNameFirst) {
					[theURI setDisplayName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
				} else {
					[theURI setDisplayName:[NSString stringWithFormat:@"%@ %@", lastName, firstName]];
				}
			} else if ([firstName length] > 0) {
				[theURI setDisplayName:firstName];
			} else if ([lastName length] > 0) {
				[theURI setDisplayName:lastName];
			}
			
		} else if (isCompany) {
			if ([company length] > 0)
				[theURI setDisplayName:company];
		}
		
		// Get other available phone numbers.
		AKTelephoneNumberFormatter *telephoneNumberFormatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
		ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
		for (NSUInteger i = 0; i < [phones count]; ++i) {
			NSString *phoneNumber = [phones valueAtIndex:i];
			if ([[telephoneNumberFormatter telephoneNumberFromString:phoneNumber]
				 isEqualToString:[telephoneNumberFormatter telephoneNumberFromString:[theURI user]]])
			{
				continue;
			}
			
			AKSIPURI *uri = [SIPURIFormatter SIPURIFromString:phoneNumber];
			[URIs addObject:uri];
		}
		
	}
	
	// First URI in the array is a default call destination.
	[self setCallDestinationURIIndex:0];
	
	return [[URIs copy] autorelease];
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
	if (![representedObject isKindOfClass:[NSArray class]])
		return nil;
	
	AKSIPURI *mainURI = [representedObject objectAtIndex:0];
	
	NSString *returnString = nil;
	
	if ([[mainURI displayName] length] > 0) {
		returnString = [mainURI displayName];
	} else if ([[mainURI host] length] > 0) {
		NSAssert(([[mainURI user] length] > 0), @"User part of the URI must not have zero length in this context");
		returnString = [mainURI SIPAddress];
	} else {
		NSAssert(([[mainURI user] length] > 0), @"User part of the URI must not have zero length in this context");
		if ([[mainURI user] AK_isTelephoneNumber]) {
			AKTelephoneNumberFormatter *formatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
			[formatter setSplitsLastFourDigits:[[NSUserDefaults standardUserDefaults]
												boolForKey:AKTelephoneNumberFormatterSplitsLastFourDigits]];
			returnString = [formatter stringForObjectValue:[mainURI user]];
		} else {
			returnString = [mainURI user];
		}
	}
	
	return returnString;
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject
{
	if (![representedObject isKindOfClass:[NSArray class]])
		return nil;
	
	AKSIPURI *mainURI = [representedObject objectAtIndex:0];
	NSAssert(([[mainURI user] length] > 0), @"User part of the URI must not have zero length in this context");
	
	if ([[mainURI displayName] length] > 0)
		return [NSString stringWithFormat:@"%@ <%@>", [mainURI displayName], [mainURI user]];
	else if ([[mainURI host] length] > 0)
		return [mainURI SIPAddress];
	else
		return [mainURI user];
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject
{
	if ([representedObject isKindOfClass:[NSArray class]] && [[[representedObject objectAtIndex:0] displayName] length] > 0)
		return YES;
	else
		return NO;
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject
{
	NSMenu *tokenMenu = [[[NSMenu alloc] init] autorelease];
	
	for (NSUInteger i = 0; i < [representedObject count]; ++i) {
		AKSIPURI *aURI = [representedObject objectAtIndex:i];
		NSMenuItem *callDestinationURIItem = [[[NSMenuItem alloc] init] autorelease];
		
		if ([[aURI host] length] > 0) {
			[callDestinationURIItem setTitle:[aURI SIPAddress]];
		} else if ([[aURI user] AK_isTelephoneNumber]) {
			AKTelephoneNumberFormatter *formatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
			[formatter setSplitsLastFourDigits:[[NSUserDefaults standardUserDefaults]
												boolForKey:AKTelephoneNumberFormatterSplitsLastFourDigits]];
			[callDestinationURIItem setTitle:[formatter stringForObjectValue:[aURI user]]];
		} else {
			[callDestinationURIItem setTitle:[aURI user]];
		}
		
		[callDestinationURIItem setTag:i];
		[callDestinationURIItem setAction:@selector(changeCallDestinationURIIndex:)];
		
		[tokenMenu addItem:callDestinationURIItem];
	}
	
	[[tokenMenu itemWithTag:[self callDestinationURIIndex]] setState:NSOnState];
	
	return tokenMenu;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
	if (index > 0)
		return nil;
	else
		return tokens;
}

@end
