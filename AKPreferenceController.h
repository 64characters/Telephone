//
//  AKPreferenceController.h
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

#import <Cocoa/Cocoa.h>


// Keys for defaults

extern NSString * const AKAccounts;
extern NSString * const AKSTUNServerHost;
extern NSString * const AKSTUNServerPort;
extern NSString * const AKSTUNDomain;
extern NSString * const AKLogFileName;
extern NSString * const AKLogLevel;
extern NSString * const AKConsoleLogLevel;
extern NSString * const AKVoiceActivityDetection;
extern NSString * const AKTransportPort;
extern NSString * const AKSoundInput;
extern NSString * const AKSoundOutput;
extern NSString * const AKRingtoneOutput;
extern NSString * const AKRingingSound;
extern NSString * const AKFormatTelephoneNumbers;
extern NSString * const AKTelephoneNumberFormatterSplitsLastFourDigits;
extern NSString * const AKOutboundProxyHost;
extern NSString * const AKOutboundProxyPort;
extern NSString * const AKUseICE;
extern NSString * const AKUseDNSSRV;
extern NSString * const AKSignificantPhoneNumberLength;

// Account keys
extern NSString * const AKFullName;
extern NSString * const AKSIPAddress;
extern NSString * const AKRegistrar;
extern NSString * const AKRealm;
extern NSString * const AKUsername;
extern NSString * const AKPassword;
extern NSString * const AKAccountIndex;
extern NSString * const AKAccountEnabled;
extern NSString * const AKReregistrationTime;
extern NSString * const AKSubstitutePlusCharacter;
extern NSString * const AKPlusCharacterSubstitutionString;
extern NSString * const AKUseProxy;
extern NSString * const AKProxyHost;
extern NSString * const AKProxyPort;

extern NSString * const AKSourceIndex;
extern NSString * const AKDestinationIndex;

@interface AKPreferenceController : NSWindowController {
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
  NSTextField *outboundProxyHostField_;
  NSTextField *outboundProxyPortField_;
  
  // Account.
  NSTableView *accountsTable_;
  NSButton *accountEnabledCheckBox_;
  NSTextField *fullNameField_;
  NSTextField *SIPAddressField_;
  NSTextField *registrarField_;
  NSTextField *usernameField_;
  NSTextField *passwordField_;
  NSTextField *reregistrationTimeField_;
  NSButton *substitutePlusCharacterCheckBox_;
  NSTextField *plusCharacterSubstitutionField_;
  NSButton *useProxyCheckBox_;
  NSTextField *proxyHostField_;
  NSTextField *proxyPortField_;
  
  // Account Setup.
  NSWindow *addAccountWindow_;
  NSTextField *setupFullNameField_;
  NSTextField *setupSIPAddressField_;
  NSTextField *setupRegistrarField_;
  NSTextField *setupUsernameField_;
  NSTextField *setupPasswordField_;
  NSButton *addAccountWindowDefaultButton_;
  NSButton *addAccountWindowOtherButton_;
}

@property(nonatomic, readwrite, assign) id delegate;

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
@property(nonatomic, retain) IBOutlet NSTextField *outboundProxyHostField;
@property(nonatomic, retain) IBOutlet NSTextField *outboundProxyPortField;

@property(nonatomic, retain) IBOutlet NSTableView *accountsTable;
@property(nonatomic, retain) IBOutlet NSButton *accountEnabledCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *fullNameField;
@property(nonatomic, retain) IBOutlet NSTextField *SIPAddressField;
@property(nonatomic, retain) IBOutlet NSTextField *registrarField;
@property(nonatomic, retain) IBOutlet NSTextField *usernameField;
@property(nonatomic, retain) IBOutlet NSTextField *passwordField;
@property(nonatomic, retain) IBOutlet NSTextField *reregistrationTimeField;
@property(nonatomic, retain) IBOutlet NSButton *substitutePlusCharacterCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *plusCharacterSubstitutionField;
@property(nonatomic, retain) IBOutlet NSButton *useProxyCheckBox;
@property(nonatomic, retain) IBOutlet NSTextField *proxyHostField;
@property(nonatomic, retain) IBOutlet NSTextField *proxyPortField;

@property(nonatomic, retain) IBOutlet NSWindow *addAccountWindow;
@property(nonatomic, retain) IBOutlet NSTextField *setupFullNameField;
@property(nonatomic, retain) IBOutlet NSTextField *setupSIPAddressField;
@property(nonatomic, retain) IBOutlet NSTextField *setupRegistrarField;
@property(nonatomic, retain) IBOutlet NSTextField *setupUsernameField;
@property(nonatomic, retain) IBOutlet NSTextField *setupPasswordField;
@property(nonatomic, retain) IBOutlet NSButton *addAccountWindowDefaultButton;
@property(nonatomic, retain) IBOutlet NSButton *addAccountWindowOtherButton;

// Change view in Preferences window
- (IBAction)changeView:(id)sender;

// Raise a sheet which adds an account
- (IBAction)showAddAccountSheet:(id)sender;

// Close a sheet
- (IBAction)closeSheet:(id)sender;

// Add new account, save to defaults, send a notification
- (IBAction)addAccount:(id)sender;

- (IBAction)showRemoveAccountSheet:(id)sender;

// Remove account, save notification
- (void)removeAccountAtIndex:(NSInteger)index;

- (void)populateFieldsForAccountAtIndex:(NSInteger)index;

- (IBAction)changeAccountEnabled:(id)sender;
- (IBAction)changeSubstitutePlusCharacter:(id)sender;
- (IBAction)changeUseProxy:(id)sender;

// Change sound input and output devices
- (IBAction)changeSoundIO:(id)sender;

// Refresh list of available audio devices.
- (void)updateAudioDevices;

- (void)updateAvailableSounds;
- (IBAction)changeRingtone:(id)sender;

@end


// Preferences window toolbar items tags.
enum {
  AKGeneralPreferencesTag  = 0,
  AKAccountsPreferencesTag = 1,
  AKSoundPreferencesTag    = 2,
  AKNetworkPreferencesTag  = 3
};


// Notifications.

extern NSString * const AKPreferenceControllerDidAddAccountNotification;

// Key: AKAccountIndex.
extern NSString * const AKPreferenceControllerDidRemoveAccountNotification;

// Key: AKAccountIndex.
extern NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification;

// Keys: AKSourceIndex, AKDestinationIndex.
extern NSString * const AKPreferenceControllerDidSwapAccountsNotification;

extern NSString * const AKPreferenceControllerDidChangeNetworkSettingsNotification;
