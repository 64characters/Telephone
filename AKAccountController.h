//
//  AKAccountController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class AKTelephoneAccount;

// Account registration pull-down list tags
enum {
	AKTelephoneAccountUnregisterTag	= 0,
	AKTelephoneAccountRegisterTag	= 1
};

@interface AKAccountController : NSWindowController {
	AKTelephoneAccount *account;
	NSMutableArray *callControllers;
	
	IBOutlet NSView *registeredAccountView;
	IBOutlet NSView *unregisteredAccountView;
	IBOutlet NSPopUpButton *accountRegistrationPopUp;
	IBOutlet NSMenuItem *registerAccountMenuItem;
	IBOutlet NSMenuItem *unregisterAccountMenuItem;
	IBOutlet NSTextField *callDestination;
	IBOutlet NSButton *callButton;
}

@property(readwrite, retain) AKTelephoneAccount *account;
@property(readonly, retain) NSMutableArray *callControllers;

// Designated initializer
- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount;

- (id)initWithFullName:(NSString *)aFullName
			sipAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername;

- (IBAction)makeCall:(id)sender;

- (IBAction)changeAccountRegistration:(id)sender;

@end
