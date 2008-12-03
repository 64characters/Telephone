//
//  AKPreferenceController.h
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

#import <Cocoa/Cocoa.h>


// Keys for defaults

extern NSString * const AKAccounts;
extern NSString * const AKAccountSortOrder;
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
extern NSString * const AKFormatsTelephoneNumbers;
extern NSString * const AKTelephoneNumberFormatterSplitsLastFourDigits;

// Account keys
extern NSString * const AKFullName;
extern NSString * const AKSIPAddress;
extern NSString * const AKRegistrar;
extern NSString * const AKRealm;
extern NSString * const AKUsername;
extern NSString * const AKPassword;
extern NSString * const AKAccountIndex;
extern NSString * const AKAccountKey;
extern NSString * const AKAccountEnabled;

@interface AKPreferenceController : NSWindowController {
@private
	id delegate;
	
	IBOutlet NSToolbar *toolbar;
	IBOutlet NSToolbarItem *generalToolbarItem;
	IBOutlet NSToolbarItem *accountsToolbarItem;
	IBOutlet NSToolbarItem *soundToolbarItem;
	IBOutlet NSView *generalView;
	IBOutlet NSView *accountsView;
	IBOutlet NSView *soundView;

	// General
	IBOutlet NSPopUpButton *soundInputPopUp;
	IBOutlet NSPopUpButton *soundOutputPopUp;
	IBOutlet NSTextField *STUNServerHost;
	IBOutlet NSTextField *STUNServerPort;
	
	// Account
	IBOutlet NSTableView *accountsTable;
	IBOutlet NSButton *accountEnabledCheckBox;
	IBOutlet NSTextField *fullName;
	IBOutlet NSTextField *SIPAddress;
	IBOutlet NSTextField *registrar;
	IBOutlet NSTextField *username;
	IBOutlet NSTextField *password;
	
	// Account Setup
	IBOutlet NSWindow *addAccountWindow;
	IBOutlet NSTextField *setupFullName;
	IBOutlet NSTextField *setupSIPAddress;
	IBOutlet NSTextField *setupRegistrar;
	IBOutlet NSTextField *setupUsername;
	IBOutlet NSTextField *setupPassword;
	IBOutlet NSButton *addAccountWindowDefaultButton;
	IBOutlet NSButton *addAccountWindowOtherButton;
}

@property(readwrite, assign) id delegate;
@property(readonly, retain) NSWindow *addAccountWindow;
@property(readonly, retain) NSButton *addAccountWindowDefaultButton;
@property(readonly, retain) NSButton *addAccountWindowOtherButton;

// Display view in Preferences window
- (void)displayView:(NSView *)aView withTitle:(NSString *)aTitle;

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

- (void)populateFieldsForAccountAtIndex:(NSUInteger)index;

- (IBAction)changeAccountEnabled:(id)sender;

// Change sound input and output devices
- (IBAction)changeSoundIO:(id)sender;

// Refresh list of available audio devices.
- (void)updateAudioDevices;

@end


// Preferences window toolbar items tags.
enum {
	AKGeneralPreferencesTag		= 0,
	AKAccountsPreferencesTag	= 1,
	AKSoundPreferencesTag		= 2
};


// Notifications.
extern NSString * const AKPreferenceControllerDidAddAccountNotification;
extern NSString * const AKPreferenceControllerDidRemoveAccountNotification; // AKAccountIndex.
extern NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification; // AKAccountIndex, AKAccountEnabled.
extern NSString * const AKPreferenceControllerDidChangeSTUNServerNotification;
