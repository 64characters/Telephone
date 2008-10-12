//
//  AKPreferenceController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Keys for defaults

APPKIT_EXTERN NSString *AKAccounts;
APPKIT_EXTERN NSString *AKAccountSortOrder;
APPKIT_EXTERN NSString *AKSTUNServerHost;
APPKIT_EXTERN NSString *AKSTUNServerPort;
APPKIT_EXTERN NSString *AKSTUNDomain;
APPKIT_EXTERN NSString *AKLogFileName;
APPKIT_EXTERN NSString *AKVoiceActivityDetection;
APPKIT_EXTERN NSString *AKTransportPort;

// Account keys
APPKIT_EXTERN NSString *AKFullName;
APPKIT_EXTERN NSString *AKSIPAddress;
APPKIT_EXTERN NSString *AKRegistrar;
APPKIT_EXTERN NSString *AKRealm;
APPKIT_EXTERN NSString *AKUsername;
APPKIT_EXTERN NSString *AKPassword;
APPKIT_EXTERN NSString *AKAccountIndex;
APPKIT_EXTERN NSString *AKAccountKey;
APPKIT_EXTERN NSString *AKAccountEnabled;

@interface AKPreferenceController : NSWindowController {
	id delegate;
	
	IBOutlet NSToolbar *toolbar;
	IBOutlet NSToolbarItem *generalToolbarItem;
	IBOutlet NSToolbarItem *accountsToolbarItem;
	IBOutlet NSView *generalView;
	IBOutlet NSView *accountsView;
	IBOutlet NSTableView *accountsTable;
	IBOutlet NSWindow *addAccountSheet;
	
	// Account fields
	IBOutlet NSButton *accountEnabledCheckBox;
	IBOutlet NSTextField *fullName;
	IBOutlet NSTextField *sipAddress;
	IBOutlet NSTextField *registrar;
	IBOutlet NSTextField *username;
	IBOutlet NSTextField *password;
	
	// Account Setup fields
	IBOutlet NSTextField *setupFullName;
	IBOutlet NSTextField *setupSIPAddress;
	IBOutlet NSTextField *setupRegistrar;
	IBOutlet NSTextField *setupUsername;
	IBOutlet NSTextField *setupPassword;
}

@property(readwrite, assign) id delegate;

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

@end

@interface NSObject(AKPreferenceControllerNotifications)
- (void)preferenceControllerDidAddAccount:(NSNotification *)notification;
- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification;
- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification;
@end

// Notifications
APPKIT_EXTERN NSString *AKPreferenceControllerDidAddAccountNotification;
APPKIT_EXTERN NSString *AKPreferenceControllerDidRemoveAccountNotification; // AKAccountIndex
APPKIT_EXTERN NSString *AKPreferenceControllerDidChangeAccountEnabledNotification; // AKAccountIndex, AKAccountEnabled
