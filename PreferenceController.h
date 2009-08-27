//
//  PreferenceController.h
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

#import <Cocoa/Cocoa.h>


// Preferences window toolbar items tags.
enum {
  kGeneralPreferencesTag  = 0,
  kAccountsPreferencesTag = 1,
  kSoundPreferencesTag    = 2,
  kNetworkPreferencesTag  = 3
};

// Keys for defaults
//
extern NSString * const kAccounts;
extern NSString * const kSTUNServerHost;
extern NSString * const kSTUNServerPort;
extern NSString * const kSTUNDomain;
extern NSString * const kLogFileName;
extern NSString * const kLogLevel;
extern NSString * const kConsoleLogLevel;
extern NSString * const kVoiceActivityDetection;
extern NSString * const kTransportPort;
extern NSString * const kTransportPublicHost;
extern NSString * const kSoundInput;
extern NSString * const kSoundOutput;
extern NSString * const kRingtoneOutput;
extern NSString * const kRingingSound;
extern NSString * const kFormatTelephoneNumbers;
extern NSString * const kTelephoneNumberFormatterSplitsLastFourDigits;
extern NSString * const kOutboundProxyHost;
extern NSString * const kOutboundProxyPort;
extern NSString * const kUseICE;
extern NSString * const kUseDNSSRV;
extern NSString * const kSignificantPhoneNumberLength;
extern NSString * const kPauseITunes;
extern NSString * const kAutoCloseCallWindow;
//
// Account keys
extern NSString * const kDescription;
extern NSString * const kFullName;
extern NSString * const kSIPAddress;
extern NSString * const kRegistrar;
extern NSString * const kDomain;
extern NSString * const kRealm;
extern NSString * const kUsername;
extern NSString * const kAccountIndex;
extern NSString * const kAccountEnabled;
extern NSString * const kReregistrationTime;
extern NSString * const kSubstitutePlusCharacter;
extern NSString * const kPlusCharacterSubstitutionString;
extern NSString * const kUseProxy;
extern NSString * const kProxyHost;
extern NSString * const kProxyPort;

extern NSString * const kSourceIndex;
extern NSString * const kDestinationIndex;

// Notifications.
//
// Sent when preference controller adds an account.
extern NSString * const AKPreferenceControllerDidAddAccountNotification;
//
// Sent when preference controller removes an accont.
// Key: AKAccountIndex.
extern NSString * const AKPreferenceControllerDidRemoveAccountNotification;
//
// Sent when preference controller enables or disables an account.
// Key: AKAccountIndex.
extern NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification;
//
// Sent when preference controller changes account order.
// Keys: AKSourceIndex, AKDestinationIndex.
extern NSString * const AKPreferenceControllerDidSwapAccountsNotification;
//
// Sent when preference controller changes network settings.
extern NSString * const AKPreferenceControllerDidChangeNetworkSettingsNotification;

// A preference controler.
@interface PreferenceController : NSWindowController {
 @private
  id delegate_;
  
  NSToolbar *toolbar_;
  NSToolbarItem *generalToolbarItem_;
  NSToolbarItem *accountsToolbarItem_;
  NSToolbarItem *soundToolbarItem_;
  NSToolbarItem *networkToolbarItem_;
  NSView *generalView_;
  NSView *accountsView_;
  NSView *soundView_;
  NSView *networkView_;
  
  // Sound.
  NSPopUpButton *soundInputPopUp_;
  NSPopUpButton *soundOutputPopUp_;
  NSPopUpButton *ringtoneOutputPopUp_;
  NSPopUpButton *ringtonePopUp_;
  
  // Network.
  NSTextField *transportPortField_;
  NSTextFieldCell *transportPortCell_;
  NSTextField *STUNServerHostField_;
  NSTextField *STUNServerPortField_;
  NSButton *useICECheckBox_;
  NSButton *useDNSSRVCheckBox_;
  NSTextField *outboundProxyHostField_;
  NSTextField *outboundProxyPortField_;
  
  // Account.
  NSTableView *accountsTable_;
  NSButton *accountEnabledCheckBox_;
  NSTextField *accountDescriptionField_;
  NSTextField *fullNameField_;
  NSTextField *domainField_;
  NSTextField *usernameField_;
  NSTextField *passwordField_;
  NSTextField *reregistrationTimeField_;
  NSButton *substitutePlusCharacterCheckBox_;
  NSTextField *plusCharacterSubstitutionField_;
  NSButton *useProxyCheckBox_;
  NSTextField *proxyHostField_;
  NSTextField *proxyPortField_;
  NSTextField *SIPAddressField_;
  NSTextField *registrarField_;
  
  // Account Setup.
  NSWindow *addAccountWindow_;
  NSTextField *setupFullNameField_;
  NSTextField *setupDomainField_;
  NSTextField *setupUsernameField_;
  NSTextField *setupPasswordField_;
  NSImageView *setupFullNameInvalidDataView_;
  NSImageView *setupDomainInvalidDataView_;
  NSImageView *setupUsernameInvalidDataView_;
  NSImageView *setupPasswordInvalidDataView_;
  NSButton *addAccountWindowDefaultButton_;
  NSButton *addAccountWindowOtherButton_;
}

// The receiver's delegate.
@property(nonatomic, assign) id delegate;

// Outlets.

@property(nonatomic, retain) IBOutlet NSToolbar *toolbar;
@property(nonatomic, retain) IBOutlet NSToolbarItem *generalToolbarItem;
@property(nonatomic, retain) IBOutlet NSToolbarItem *accountsToolbarItem;
@property(nonatomic, retain) IBOutlet NSToolbarItem *soundToolbarItem;
@property(nonatomic, retain) IBOutlet NSToolbarItem *networkToolbarItem;
@property(nonatomic, retain) IBOutlet NSView *generalView;
@property(nonatomic, retain) IBOutlet NSView *accountsView;
@property(nonatomic, retain) IBOutlet NSView *soundView;
@property(nonatomic, retain) IBOutlet NSView *networkView;

@property(nonatomic, retain) IBOutlet NSPopUpButton *soundInputPopUp;
@property(nonatomic, retain) IBOutlet NSPopUpButton *soundOutputPopUp;
@property(nonatomic, retain) IBOutlet NSPopUpButton *ringtoneOutputPopUp;
@property(nonatomic, retain) IBOutlet NSPopUpButton *ringtonePopUp;

@property(nonatomic, retain) IBOutlet NSTextField *transportPortField;
@property(nonatomic, retain) IBOutlet NSTextFieldCell *transportPortCell;
@property(nonatomic, retain) IBOutlet NSTextField *STUNServerHostField;
@property(nonatomic, retain) IBOutlet NSTextField *STUNServerPortField;
@property(nonatomic, retain) IBOutlet NSButton *useICECheckBox;
@property(nonatomic, retain) IBOutlet NSButton *useDNSSRVCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *outboundProxyHostField;
@property(nonatomic, retain) IBOutlet NSTextField *outboundProxyPortField;

@property(nonatomic, retain) IBOutlet NSTableView *accountsTable;
@property(nonatomic, retain) IBOutlet NSButton *accountEnabledCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *accountDescriptionField;
@property(nonatomic, retain) IBOutlet NSTextField *fullNameField;
@property(nonatomic, retain) IBOutlet NSTextField *domainField;
@property(nonatomic, retain) IBOutlet NSTextField *usernameField;
@property(nonatomic, retain) IBOutlet NSTextField *passwordField;
@property(nonatomic, retain) IBOutlet NSTextField *reregistrationTimeField;
@property(nonatomic, retain) IBOutlet NSButton *substitutePlusCharacterCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *plusCharacterSubstitutionField;
@property(nonatomic, retain) IBOutlet NSButton *useProxyCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *proxyHostField;
@property(nonatomic, retain) IBOutlet NSTextField *proxyPortField;
@property(nonatomic, retain) IBOutlet NSTextField *SIPAddressField;
@property(nonatomic, retain) IBOutlet NSTextField *registrarField;

@property(nonatomic, retain) IBOutlet NSWindow *addAccountWindow;
@property(nonatomic, retain) IBOutlet NSTextField *setupFullNameField;
@property(nonatomic, retain) IBOutlet NSTextField *setupDomainField;
@property(nonatomic, retain) IBOutlet NSTextField *setupUsernameField;
@property(nonatomic, retain) IBOutlet NSTextField *setupPasswordField;
@property(nonatomic, retain) IBOutlet NSImageView *setupFullNameInvalidDataView;
@property(nonatomic, retain) IBOutlet NSImageView *setupDomainInvalidDataView;
@property(nonatomic, retain) IBOutlet NSImageView *setupUsernameInvalidDataView;
@property(nonatomic, retain) IBOutlet NSImageView *setupPasswordInvalidDataView;
@property(nonatomic, retain) IBOutlet NSButton *addAccountWindowDefaultButton;
@property(nonatomic, retain) IBOutlet NSButton *addAccountWindowOtherButton;

// Changes window's content view.
- (IBAction)changeView:(id)sender;

// Raises |Add Account| sheet.
- (IBAction)showAddAccountSheet:(id)sender;

// Closes a sheet.
- (IBAction)closeSheet:(id)sender;

// Adds new account.
- (IBAction)addAccount:(id)sender;

// Raises |Remove Account| sheet.
- (IBAction)showRemoveAccountSheet:(id)sender;

// Removes account with specified index.
- (void)removeAccountAtIndex:(NSInteger)index;

// Populates fields and checkboxes for the account with a specified index.
- (void)populateFieldsForAccountAtIndex:(NSInteger)index;

// Enables or disables an account.
- (IBAction)changeAccountEnabled:(id)sender;

// Enables or disables plus character replacement for an account.
- (IBAction)changeSubstitutePlusCharacter:(id)sender;

// Enables or disables proxy usage for an account.
- (IBAction)changeUseProxy:(id)sender;

// Changes sound input and output devices.
- (IBAction)changeSoundIO:(id)sender;

// Refreshes list of available audio devices.
- (void)updateAudioDevices;

// Updates the list of available sounds for a ringtone. Sounds are being
// searched in the following locations.
//
// ~/Library/Sounds
// /Library/Sounds
// /Network/Library/Sounds
// /System/Library/Sounds
- (void)updateAvailableSounds;

// Changes a ringtone sound.
- (IBAction)changeRingtone:(id)sender;

@end
