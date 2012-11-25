//
//  ActiveAccountViewController.m
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

#import "ActiveAccountViewController.h"

#import <AddressBook/AddressBook.h>

#import "AKABRecord+Querying.h"
#import "AKABAddressBook+Localizing.h"
#import "AKNSString+Scanning.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountController.h"
#import "PreferencesController.h"


NSString * const kURI = @"URI";
NSString * const kPhoneLabel = @"PhoneLabel";

@implementation ActiveAccountViewController

@synthesize accountController = accountController_;
@synthesize callDestinationField = callDestinationField_;
@synthesize callDestinationURIIndex = callDestinationURIIndex_;
@dynamic callDestinationURI;

- (AKSIPURI *)callDestinationURI {
    NSDictionary *callDestinationDict = [[[[self callDestinationField] objectValue] objectAtIndex:0]
                                         objectAtIndex:[self callDestinationURIIndex]];
    
    AKSIPURI *uri = [[[callDestinationDict objectForKey:kURI] copy] autorelease];
    
    // Displayed name is stored in the first URI only.
    AKSIPURI *firstURI = [[[[[self callDestinationField] objectValue] objectAtIndex:0] objectAtIndex:0]
                          objectForKey:kURI];
    
    [uri setDisplayName:[firstURI displayName]];
    
    if ([uri isKindOfClass:[AKSIPURI class]] && [[uri user] length] > 0) {
        return uri;
    } else {
        return nil;
    }
}

- (id)initWithAccountController:(AccountController *)anAccountController
               windowController:(XSWindowController *)windowController {
    
    self = [super initWithNibName:@"ActiveAccountView" bundle:nil windowController:windowController];
    
    if (self != nil) {
        [self setAccountController:anAccountController];
    }
    return self;
}

- (id)init {
    [self dealloc];
    NSString *reason = @"Initialize ActiveAccountViewController with initWithAccountController:";
    @throw [NSException exceptionWithName:@"AKBadInitCall" reason:reason userInfo:nil];
    return nil;
}

- (void)awakeFromNib {
    // Exclude comma from the callDestination tokenizing character set.
    [[self callDestinationField] setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    [[self callDestinationField] setCompletionDelay:0.4];
}

- (IBAction)makeCall:(id)sender {
    if ([[[self callDestinationField] objectValue] count] == 0) {
        return;
    }
    
    NSDictionary *callDestinationDict = [[[[self callDestinationField] objectValue] objectAtIndex:0]
                                         objectAtIndex:[self callDestinationURIIndex]];
    
    NSString *phoneLabel = [callDestinationDict objectForKey:kPhoneLabel];
    
    AKSIPURI *uri = [self callDestinationURI];
    if (uri != nil) {
        [[self accountController] makeCallToURI:uri phoneLabel:phoneLabel];
    }
}

- (IBAction)changeCallDestinationURIIndex:(id)sender {
    [self setCallDestinationURIIndex:[sender tag]];
}


#pragma mark -
#pragma mark NSTokenField delegate

// Returns completions based on the Address Book search.
// A completion string can be in one of two formats: Display Name <1234567> for person or company name searches,
// 1234567 (Display Name) for the phone number searches.
// Sets tokenField sytle to NSRoundedTokenStyle if the substring is found in the Address Book; otherwise, sets
// tokenField sytle to NSPlainTextTokenStyle.
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
                                       value:[NSNumber numberWithInteger:kABShowAsPerson]
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
            if ([firstPart length] > 0) {
                [firstPart appendFormat:@" %@", [substringComponents objectAtIndex:j]];
            } else {
                [firstPart appendString:[substringComponents objectAtIndex:j]];
            }
        }
        
        for (j = i + 1; j < [substringComponents count]; ++j) {
            if ([secondPart length] > 0) {
                [secondPart appendFormat:@" %@", [substringComponents objectAtIndex:j]];
            } else {
                [secondPart appendString:[substringComponents objectAtIndex:j]];
            }
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
                                       value:[NSNumber numberWithInteger:kABShowAsCompany]
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
    // with kEmailSIPLabel label.) If you set the label to kEmailSIPLabel,
    // it will find only the first email with that label. So, find all emails and
    // filter them later.
    ABSearchElement *SIPAddressPrefixMatch
        = [ABPerson searchElementForProperty:kABEmailProperty
                                       label:nil
                                         key:nil
                                       value:substring
                                  comparison:kABPrefixMatchCaseInsensitive];
    
    [searchElements addObject:SIPAddressPrefixMatch];
    
    ABSearchElement *compoundMatch = [ABSearchElement searchElementForConjunction:kABSearchOr children:searchElements];
    
    // Perform Address Book search.
    NSArray *recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
    
    
    // Populate the completions array.
    
    NSMutableArray *completions = [NSMutableArray arrayWithCapacity:[recordsFound count]];
    
    for (id theRecord in recordsFound) {
        if (![theRecord isKindOfClass:[ABPerson class]]) {
            continue;
        }
        
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
                    completionString = [NSString stringWithFormat:@"%@ (%@)", phoneNumber, [theRecord ak_fullName]];
                } else {
                    completionString = phoneNumber;
                }
                
                if (completionString != nil) {
                    [completions addObject:completionString];
                }
            }
        }
        
        // Check if the substing matches email labelled as kEmailSIPLabel.
        // Display completion as email_address (Display Name).
        for (i = 0; i < [emails count]; ++i) {
            if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel] != NSOrderedSame) {
                continue;
            }
            
            NSString *anEmail = [emails valueAtIndex:i];
            
            NSRange range = [anEmail rangeOfString:substring
                                           options:NSCaseInsensitiveSearch];
            if (range.location == 0) {
                NSString *completionString = nil;
                
                if ([[theRecord ak_fullName] length] > 0) {
                    completionString = [NSString stringWithFormat:@"%@ (%@)", anEmail, [theRecord ak_fullName]];
                } else {
                    completionString = anEmail;
                }
                
                if (completionString != nil) {
                    [completions addObject:completionString];
                }
            }
        }
        
        
        // Check for first name, last name or company name match.
        
        // Determine the contact name including first and last names ordering.
        // Skip if it's not the name match.
        NSString *contactName = nil;
        if (isPerson) {
            NSString *firstNameFirst = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            NSString *lastNameFirst = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
            NSRange firstNameFirstRange = [firstNameFirst rangeOfString:substring options:NSCaseInsensitiveSearch];
            NSRange lastNameFirstRange = [lastNameFirst rangeOfString:substring options:NSCaseInsensitiveSearch];
            NSRange firstNameRange = [firstName rangeOfString:substring options:NSCaseInsensitiveSearch];
            NSRange lastNameRange = [lastName rangeOfString:substring options:NSCaseInsensitiveSearch];
            
            // Continue if the substing does not match person name prefix.
            if (firstNameRange.location != 0 && lastNameRange.location != 0 &&
                firstNameFirstRange.location != 0 &&
                lastNameFirstRange.location != 0) {
                
                continue;
            }
            
            if ([firstName length] > 0 && [lastName length] > 0) {
                // Determine the order of names in the full name the user is looking
                // for.
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
            NSRange companyNamePrefixRange = [company rangeOfString:substring options:NSCaseInsensitiveSearch];
            if (companyNamePrefixRange.location != 0) {
                continue;
            }
            
            if ([company length] > 0) {
                contactName = company;
            }
        }
        
        if (contactName == nil) {
            continue;
        }
        
        // Add phone numbers. Display completion as Display Name <1234567>.
        for (i = 0; i < [phones count]; ++i) {
            NSString *phoneNumber = [phones valueAtIndex:i];
            NSString *completionString = nil;
            
            if (contactName != nil) {
                completionString = [NSString stringWithFormat:@"%@ <%@>", contactName, phoneNumber];
            } else {
                completionString = phoneNumber;
            }
            
            if (completionString != nil) {
                [completions addObject:completionString];
            }
        }
        
        // Add SIP address from the email fields labelled as kEmailSIPLabel.
        // Display completion as Display Name <email_address>
        for (i = 0; i < [emails count]; ++i) {
            if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel] != NSOrderedSame) {
                continue;
            }
            
            NSString *anEmail = [emails valueAtIndex:i];
            NSString *completionString = nil;
            
            if (contactName != nil) {
                completionString = [NSString stringWithFormat:@"%@ <%@>", contactName, anEmail];
            } else {
                completionString = anEmail;
            }
            
            if (completionString != nil) {
                [completions addObject:completionString];
            }
        }
    }
    
    
    // Preserve string capitalization according to the user input.
    if ([completions count] > 0) {
        NSRange searchedStringRange = [[completions objectAtIndex:0] rangeOfString:substring
                                                                           options:NSCaseInsensitiveSearch];
        if (searchedStringRange.location == 0) {
            NSRange replaceRange = NSMakeRange(0, [substring length]);
            NSString *newFirstElement
                = [[completions objectAtIndex:0] stringByReplacingCharactersInRange:replaceRange withString:substring];
            [completions replaceObjectAtIndex:0 withObject:newFirstElement];
        }
    }
    
    // Set appropriate token style depending on the search success.
    if ([completions count] > 0) {
        [tokenField setTokenStyle:NSRoundedTokenStyle];
    } else {
        [tokenField setTokenStyle:NSPlainTextTokenStyle];
    }
    
    return [[completions copy] autorelease];
}

// Converts input text to the array of dictionaries containing AKSIPURIs and phone labels (mobile, home, etc).
// Dictionary keys are AKURI and AKPhoneLabel. If there is no @ sign, the input is treated as a user part of the URI and
// host part will be nil.
- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    AKSIPURIFormatter *SIPURIFormatter = [[[AKSIPURIFormatter alloc] init] autorelease];
    [SIPURIFormatter setFormatsTelephoneNumbers:[defaults boolForKey:kFormatTelephoneNumbers]];
    [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
     [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
    
    AKSIPURI *theURI = [SIPURIFormatter SIPURIFromString:editingString];
    if (theURI == nil) {
        return nil;
    }
    
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    NSArray *recordsFound;
    
    NSAssert(([[theURI user] length] > 0), @"User part of the URI must not have zero length in this context");
    
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
        
        // Add person searches for all combination of displayedName components separated by space.
        NSArray *displayedNameComponents = [displayedName componentsSeparatedByString:@" "];
        for (NSUInteger i = 0; i < [displayedNameComponents count] - 1; ++i) {
            NSMutableString *firstPart = [[[NSMutableString alloc] init] autorelease];
            NSMutableString *secondPart = [[[NSMutableString alloc] init] autorelease];
            NSUInteger j;
            
            for (j = 0; j <= i; ++j) {
                if ([firstPart length] > 0) {
                    [firstPart appendFormat:@" %@", [displayedNameComponents objectAtIndex:j]];
                } else {
                    [firstPart appendString:[displayedNameComponents objectAtIndex:j]];
                }
            }
            
            for (j = i + 1; j < [displayedNameComponents count]; ++j) {
                if ([secondPart length] > 0) {
                    [secondPart appendFormat:@" %@", [displayedNameComponents objectAtIndex:j]];
                } else {
                    [secondPart appendString:[displayedNameComponents objectAtIndex:j]];
                }
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
        
        ABSearchElement *compoundMatch = [ABSearchElement searchElementForConjunction:kABSearchOr
                                                                             children:searchElements];
        
        recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
        
    } else {
        recordsFound = [AB recordsMatchingSearchElement:phoneNumberMatch];
    }
    
    NSMutableArray *callDestinations = [[[NSMutableArray alloc] init] autorelease];
    NSUInteger destinationIndex = 0;
    
    if ([recordsFound count] > 0) {
        ABRecord *theRecord = [recordsFound objectAtIndex:0];
        
        if ([[theRecord ak_fullName] length] > 0) {
            [theURI setDisplayName:[theRecord ak_fullName]];
        }
        
        // Get phones.
        AKTelephoneNumberFormatter *telephoneNumberFormatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
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
                     [telephoneNumberFormatter telephoneNumberFromString:[theURI user]]]) {
                    
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
            if ([[emails labelAtIndex:i] caseInsensitiveCompare:kEmailSIPLabel] != NSOrderedSame) {
                continue;
            }
            
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
                                     @"", kPhoneLabel,
                                     nil]];
    }
    
    // First URI in the array is the default call destination.
    [self setCallDestinationURIIndex:destinationIndex];
    
    return [[callDestinations copy] autorelease];
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
    if (![representedObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    AKSIPURI *uri = [[representedObject objectAtIndex:[self callDestinationURIIndex]] objectForKey:kURI];
    
    NSString *returnString = nil;
    
    if ([[uri displayName] length] > 0) {
        returnString = [uri displayName];
        
    } else if ([[uri host] length] > 0) {
        NSAssert(([[uri user] length] > 0), @"User part of the URI must not have zero length in this context");
        
        returnString = [uri SIPAddress];
        
    } else {
        NSAssert(([[uri user] length] > 0), @"User part of the URI must not have zero length in this context");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[uri user] ak_isTelephoneNumber] && [defaults boolForKey:kFormatTelephoneNumbers]) {
            AKTelephoneNumberFormatter *formatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
            [formatter setSplitsLastFourDigits:[defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
            returnString = [formatter stringForObjectValue:[uri user]];
            
        } else {
            returnString = [uri user];
        }
    }
    
    return returnString;
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject {
    if (![representedObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    AKSIPURI *uri = [[representedObject objectAtIndex:[self callDestinationURIIndex]] objectForKey:kURI];
    
    NSAssert(([[uri user] length] > 0), @"User part of the URI must not have zero length in this context");
    
    NSString *returnString = nil;
    
    if ([[uri displayName] length] > 0) {
        if ([[uri host] length] > 0) {
            returnString = [NSString stringWithFormat:@"%@ <%@>", [uri displayName], [uri SIPAddress]];
        } else {
            returnString =  [NSString stringWithFormat:@"%@ <%@>", [uri displayName], [uri user]];
        }
    } else if ([[uri host] length] > 0) {
        returnString =  [uri SIPAddress];
        
    } else {
        returnString =  [uri user];
    }
    
    return returnString;
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
    AKSIPURI *uri = [[representedObject objectAtIndex:[self callDestinationURIIndex]] objectForKey:kURI];
    
    if ([representedObject isKindOfClass:[NSArray class]] && [[uri displayName] length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject {
    NSMenu *tokenMenu = [[[NSMenu alloc] init] autorelease];
    
    for (NSUInteger i = 0; i < [representedObject count]; ++i) {
        AKSIPURI *uri = [[representedObject objectAtIndex:i] objectForKey:kURI];
        
        NSString *phoneLabel = [[representedObject objectAtIndex:i] objectForKey:kPhoneLabel];
        
        NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
        
        AKTelephoneNumberFormatter *formatter = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
        [formatter setSplitsLastFourDigits:
         [[NSUserDefaults standardUserDefaults] boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
        
        if ([[uri host] length] > 0) {
            [menuItem setTitle:[NSString stringWithFormat:@"%@: %@", phoneLabel, [uri SIPAddress]]];
            
        } else if ([[uri user] ak_isTelephoneNumber]) {
            [menuItem setTitle:[NSString stringWithFormat:@"%@: %@",
                                phoneLabel, [formatter stringForObjectValue:[uri user]]]];
        } else {
            [menuItem setTitle:[NSString stringWithFormat:@"%@: %@", phoneLabel, [uri user]]];
        }
        
        [menuItem setTag:i];
        [menuItem setAction:@selector(changeCallDestinationURIIndex:)];
        
        [tokenMenu addItem:menuItem];
    }
    
    [[tokenMenu itemWithTag:[self callDestinationURIIndex]] setState:NSOnState];
    
    return tokenMenu;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index {
    if (index > 0 && [tokenField tokenStyle] == NSRoundedTokenStyle) {
        return nil;
    } else {
        return tokens;
    }
}

@end
