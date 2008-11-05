//
//  AKPreferenceController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Keys for defaults

extern NSString *AKAccounts;
extern NSString *AKAccountSortOrder;
extern NSString *AKSTUNServerHost;
extern NSString *AKSTUNServerPort;
extern NSString *AKSTUNDomain;
extern NSString *AKLogFileName;
extern NSString *AKLogLevel;
extern NSString *AKConsoleLogLevel;
extern NSString *AKVoiceActivityDetection;
extern NSString *AKTransportPort;
extern NSString *AKSoundInput;
extern NSString *AKSoundOutput;

// Account keys
extern NSString *AKFullName;
extern NSString *AKSIPAddress;
extern NSString *AKRegistrar;
extern NSString *AKRealm;
extern NSString *AKUsername;
extern NSString *AKPassword;
extern NSString *AKAccountIndex;
extern NSString *AKAccountKey;
extern NSString *AKAccountEnabled;

@interface AKPreferenceController : NSWindowController {
	id delegate;
	
	IBOutlet NSToolbar *toolbar;
	IBOutlet NSToolbarItem *generalToolbarItem;
	IBOutlet NSToolbarItem *accountsToolbarItem;
	IBOutlet NSView *generalView;
	IBOutlet NSView *accountsView;

	// General
	IBOutlet NSPopUpButton *soundInputPopUp;
	IBOutlet NSPopUpButton *soundOutputPopUp;
	
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

@property(nonatomic, readwrite, assign) id delegate;
@property(nonatomic, readonly, retain) NSWindow *addAccountWindow;
@property(nonatomic, readonly, retain) NSButton *addAccountWindowDefaultButton;
@property(nonatomic, readonly, retain) NSButton *addAccountWindowOtherButton;

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

// Refresh list of available sound devices
- (void)updateSoundDevices;

@end

@interface NSObject(AKPreferenceControllerNotifications)
- (void)preferenceControllerDidAddAccount:(NSNotification *)notification;
- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification;
- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification;
@end

// Notifications
extern NSString *AKPreferenceControllerDidAddAccountNotification;
extern NSString *AKPreferenceControllerDidRemoveAccountNotification; // AKAccountIndex
extern NSString *AKPreferenceControllerDidChangeAccountEnabledNotification; // AKAccountIndex, AKAccountEnabled
