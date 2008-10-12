//
//  AKCallController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class AKAccountController, AKTelephoneCall;

@interface AKCallController : NSWindowController {
	AKTelephoneCall *call;
	AKAccountController *accountController;
	
//	IBOutlet NSTextField *remoteContact;
	IBOutlet NSButton *hangUpButton;
	IBOutlet NSTextField *statusField;
}

@property(readwrite, retain) AKTelephoneCall *call;
@property(readwrite, assign) AKAccountController *accountController;
@property(readwrite, copy) NSString *status;

// Designated initializer
- (id)initWithTelephoneCall:(AKTelephoneCall *)aCall
		  accountController:(AKAccountController *)anAccountController;

- (IBAction)hangUp:(id)sender;

@end


@interface NSObject(AKCallControllerNotifications)
- (void)telephoneCallWindowWillClose:(NSNotification *)notification;
@end

// Notifications
// accountController will be subscribed to this notification in its setter
APPKIT_EXTERN NSString *AKTelephoneCallWindowWillCloseNotification;