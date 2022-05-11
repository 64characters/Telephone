//
//  ActiveAccountViewController.m
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

#import "ActiveAccountViewController.h"

@import AddressBook;
@import UseCases;

#import "AKABRecord+Querying.h"
#import "AKABAddressBook+Localizing.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountController.h"

#import "Telephone-Swift.h"


NSString * const kURI = @"URI";
NSString * const kPhoneLabel = @"PhoneLabel";

@implementation ActiveAccountViewController

- (AKSIPURI *)callDestinationURI {
    NSDictionary *callDestinationDict = [[self callDestinationField] objectValue][0][[self callDestinationURIIndex]];
    
    AKSIPURI *uri = [callDestinationDict[kURI] copy];
    
    // Displayed name is stored in the first URI only.
    AKSIPURI *firstURI = [[self callDestinationField] objectValue][0][0][kURI];
    
    [uri setDisplayName:[firstURI displayName]];
    
    if ([uri isKindOfClass:[AKSIPURI class]] && [[uri user] length] > 0) {
        return uri;
    } else {
        return nil;
    }
}

- (BOOL)allowsCallDestinationInput {
    return !self.callDestinationField.isHidden;
}

- (NSView *)keyView {
    return self.callDestinationField;
}

- (instancetype)initWithAccountController:(AccountController *)accountController {
    NSParameterAssert(accountController);
    if ((self = [super initWithNibName:@"ActiveAccountView" bundle:nil])) {
        _accountController = accountController;
    }
    return self;
}

- (instancetype)initWithNibName:(NSNibName)name bundle:(NSBundle *)bundle {
    return self = [super initWithNibName:name bundle:bundle];
}

- (void)awakeFromNib {
    // Exclude comma from the callDestination tokenizing character set.
    [[self callDestinationField] setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    [[self callDestinationField] setCompletionDelay:0.4];
}

- (IBAction)makeCall:(id)sender {
    if (![self canMakeCall]) {
        return;
    }
    
    NSDictionary *callDestinationDict = [[self callDestinationField] objectValue][0][[self callDestinationURIIndex]];
    NSString *phoneLabel = callDestinationDict[kPhoneLabel];
    
    AKSIPURI *uri = [self callDestinationURI];
    if (uri != nil) {
        [[self accountController] makeCallToURI:uri phoneLabel:phoneLabel];
    }
}

- (BOOL)canMakeCall {
    return [self.callDestinationField.objectValue count] > 0 &&
    [self.callDestinationField.objectValue isKindOfClass:[NSArray class]] &&
    [self.callDestinationField.objectValue[0] isKindOfClass:[NSArray class]] &&
    [self.callDestinationField.objectValue[0][self.callDestinationURIIndex] isKindOfClass:[NSDictionary class]];
}

- (IBAction)changeCallDestinationURIIndex:(id)sender {
    [self setCallDestinationURIIndex:[sender tag]];
}

- (void)allowCallDestinationInput {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        self.callDestinationField.animator.hidden = NO;
    } completionHandler:^{
        if (self.callDestinationField.acceptsFirstResponder) {
            [self.view.window makeFirstResponder:self.callDestinationField];
        }
    }];
}

- (void)disallowCallDestinationInput {
    self.callDestinationField.hidden = YES;
}

- (void)updateNextKeyView:(NSView *)view {
    self.keyView.nextKeyView = view;
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
                                       value:@kABShowAsPerson
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
                                              children:@[firstNamePrefixMatch, isPersonRecord]];
    
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
                                              children:@[lastNamePrefixMatch, isPersonRecord]];
    
    [searchElements addObject:lastNamePrefixPersonMatch];
    
    
    // If entered substring consists of several words separated by spaces,
    // add searches for all possible combinations of the first and the last names.
    for (NSUInteger i = 0; i < [substringComponents count] - 1; ++i) {
        NSMutableString *firstPart = [[NSMutableString alloc] init];
        NSMutableString *secondPart = [[NSMutableString alloc] init];
        NSUInteger j;
        
        for (j = 0; j <= i; ++j) {
            if ([firstPart length] > 0) {
                [firstPart appendFormat:@" %@", substringComponents[j]];
            } else {
                [firstPart appendString:substringComponents[j]];
            }
        }
        
        for (j = i + 1; j < [substringComponents count]; ++j) {
            if ([secondPart length] > 0) {
                [secondPart appendFormat:@" %@", substringComponents[j]];
            } else {
                [secondPart appendString:substringComponents[j]];
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
                                                  children:@[firstNameMatch, lastNamePrefixMatch, isPersonRecord]];
        
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
                                                  children:@[lastNameMatch, firstNamePrefixMatch, isPersonRecord]];
        
        [searchElements addObject:lastNameAndFirstNamePrefixMatch];
    }
    
    ABSearchElement *isCompanyRecord
        = [ABPerson searchElementForProperty:kABPersonFlags
                                       label:nil
                                         key:nil
                                       value:@kABShowAsCompany
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
                                              children:@[companyPrefixMatch, isCompanyRecord]];
    
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
        NSRange searchedStringRange = [completions[0] rangeOfString:substring options:NSCaseInsensitiveSearch];
        if (searchedStringRange.location == 0) {
            NSRange replaceRange = NSMakeRange(0, [substring length]);
            NSString *newFirstElement = [completions[0] stringByReplacingCharactersInRange:replaceRange withString:substring];
            completions[0] = newFirstElement;
        }
    }
    
    // Set appropriate token style depending on the search success.
    if ([completions count] > 0) {
        [tokenField setTokenStyle:NSTokenStyleRounded];
    } else {
        [tokenField setTokenStyle:NSTokenStyleNone];
    }
    
    return [completions copy];
}

// Converts input text to the array of dictionaries containing AKSIPURIs and phone labels (mobile, home, etc).
// Dictionary keys are kURI and kPhoneLabel. If there is no @ sign, the input is treated as a user part of the URI and
// host part will be nil.
- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    AKSIPURIFormatter *SIPURIFormatter = [[AKSIPURIFormatter alloc] init];
    [SIPURIFormatter setFormatsTelephoneNumbers:[defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]];
    [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
     [defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
    
    NSCharacterSet *whitespaceCharset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [editingString stringByTrimmingCharactersInSet:whitespaceCharset];
    
    AKSIPURI *theURI = [SIPURIFormatter SIPURIFromString:trimmedString];
    if (theURI == nil || [[theURI user] length] == 0) {
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
        NSMutableArray *searchElements = [[NSMutableArray alloc] init];
        
        // displayedName matches the first name.
        ABSearchElement *firstNameMatch
            = [ABPerson searchElementForProperty:kABFirstNameProperty
                                           label:nil
                                             key:nil
                                           value:displayedName
                                      comparison:kABEqualCaseInsensitive];
        
        ABSearchElement *firstNameAndPhoneNumberMatch
            = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                  children:@[firstNameMatch, phoneNumberMatch]];
        
        [searchElements addObject:firstNameAndPhoneNumberMatch];
        
        ABSearchElement *firstNameAndSIPAddressMatch
            = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                  children:@[firstNameMatch, SIPAddressMatch]];
        
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
                                                  children:@[lastNameMatch, phoneNumberMatch]];
        
        [searchElements addObject:lastNameAndPhoneNumberMatch];
        
        ABSearchElement *lastNameAndSIPAddressMatch
            = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                  children:@[lastNameMatch, SIPAddressMatch]];
        
        [searchElements addObject:lastNameAndSIPAddressMatch];
        
        // Add person searches for all combination of displayedName components separated by space.
        NSArray *displayedNameComponents = [displayedName componentsSeparatedByString:@" "];
        for (NSUInteger i = 0; i < [displayedNameComponents count] - 1; ++i) {
            NSMutableString *firstPart = [[NSMutableString alloc] init];
            NSMutableString *secondPart = [[NSMutableString alloc] init];
            NSUInteger j;
            
            for (j = 0; j <= i; ++j) {
                if ([firstPart length] > 0) {
                    [firstPart appendFormat:@" %@", displayedNameComponents[j]];
                } else {
                    [firstPart appendString:displayedNameComponents[j]];
                }
            }
            
            for (j = i + 1; j < [displayedNameComponents count]; ++j) {
                if ([secondPart length] > 0) {
                    [secondPart appendFormat:@" %@", displayedNameComponents[j]];
                } else {
                    [secondPart appendString:displayedNameComponents[j]];
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
                                                      children:@[firstNameMatch, lastNameMatch, phoneNumberMatch]];
            
            [searchElements addObject:fullNameAndPhoneNumberMatch];
            
            ABSearchElement *fullNameAndSIPAddressMatch
                = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                      children:@[firstNameMatch, lastNameMatch, SIPAddressMatch]];
            
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
                                                                              children:@[firstNameMatch, lastNameMatch, phoneNumberMatch]];
            
            [searchElements addObject:fullNameAndPhoneNumberMatch];
            
            fullNameAndSIPAddressMatch
                = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                      children:@[firstNameMatch, lastNameMatch, SIPAddressMatch]];
            
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
                                                  children:@[organizationMatch, phoneNumberMatch]];
        
        [searchElements addObject:organizationAndPhoneNumberMatch];
        
        ABSearchElement *organizationAndSIPAddressMatch
            = [ABSearchElement searchElementForConjunction:kABSearchAnd
                                                  children:@[organizationMatch, SIPAddressMatch]];
        
        [searchElements addObject:organizationAndSIPAddressMatch];
        
        ABSearchElement *compoundMatch = [ABSearchElement searchElementForConjunction:kABSearchOr
                                                                             children:searchElements];
        
        recordsFound = [AB recordsMatchingSearchElement:compoundMatch];
        
    } else {
        recordsFound = [AB recordsMatchingSearchElement:phoneNumberMatch];
    }
    
    NSMutableArray *callDestinations = [[NSMutableArray alloc] init];
    NSUInteger destinationIndex = 0;
    
    if ([recordsFound count] > 0) {
        ABRecord *theRecord = recordsFound[0];
        
        if ([[theRecord ak_fullName] length] > 0) {
            [theURI setDisplayName:[theRecord ak_fullName]];
        }
        
        // Get phones.
        AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
        ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
        for (NSUInteger i = 0; i < [phones count]; ++i) {
            NSString *phoneNumber = [phones valueAtIndex:i];
            NSString *localizedPhoneLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
            
            AKSIPURI *uri = [SIPURIFormatter SIPURIFromString:phoneNumber];
            [uri setDisplayName:[theURI displayName]];
            [callDestinations addObject:@{kURI: uri, kPhoneLabel: localizedPhoneLabel}];
            
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
            [callDestinations addObject:@{kURI: uri, kPhoneLabel: localizedPhoneLabel}];
            
            // If we've met entered URI, store its index.
            if ([anEmail caseInsensitiveCompare:[theURI SIPAddress]] == NSOrderedSame) {
                destinationIndex = [callDestinations count] - 1;
            }
        }
        
    } else {
        [callDestinations addObject:@{kURI: theURI, kPhoneLabel: @""}];
    }
    
    // First URI in the array is the default call destination.
    [self setCallDestinationURIIndex:destinationIndex];
    
    return [callDestinations copy];
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
    if (![representedObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    AKSIPURI *uri = representedObject[[self callDestinationURIIndex]][kURI];
    
    NSString *returnString = nil;
    
    if ([[uri displayName] length] > 0) {
        returnString = [uri displayName];
        
    } else if ([[uri host] length] > 0) {
        NSAssert(([[uri user] length] > 0), @"User part of the URI must not have zero length in this context");
        
        returnString = [uri SIPAddress];
        
    } else {
        NSAssert(([[uri user] length] > 0), @"User part of the URI must not have zero length in this context");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[uri user] ak_isTelephoneNumber] && [defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]) {
            AKTelephoneNumberFormatter *formatter = [[AKTelephoneNumberFormatter alloc] init];
            [formatter setSplitsLastFourDigits:[defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
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
    
    AKSIPURI *uri = representedObject[[self callDestinationURIIndex]][kURI];
    
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
    AKSIPURI *uri = representedObject[[self callDestinationURIIndex]][kURI];
    
    if ([representedObject isKindOfClass:[NSArray class]] && [[uri displayName] length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject {
    NSMenu *tokenMenu = [[NSMenu alloc] init];
    
    for (NSUInteger i = 0; i < [representedObject count]; ++i) {
        AKSIPURI *uri = representedObject[i][kURI];
        
        NSString *phoneLabel = representedObject[i][kPhoneLabel];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        
        AKTelephoneNumberFormatter *formatter = [[AKTelephoneNumberFormatter alloc] init];
        [formatter setSplitsLastFourDigits:
         [[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
        
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
