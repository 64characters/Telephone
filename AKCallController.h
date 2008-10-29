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
	NSString *status;
	
	IBOutlet NSView *activeCallView;
	IBOutlet NSView *incomingCallView;
	IBOutlet NSView *endedCallView;
	IBOutlet NSButton *hangUpButton;
	IBOutlet NSButton *acceptCallButton;
	IBOutlet NSButton *declineCallButton;
	IBOutlet NSTextField *statusField;
	IBOutlet NSProgressIndicator *callProgressIndicator;
}

@property(readwrite, retain) AKTelephoneCall *call;
@property(readwrite, assign) AKAccountController *accountController;
@property(readwrite, copy) NSString *status;

@property(readonly, retain) NSView *incomingCallView;
@property(readonly, retain) NSView *activeCallView;
@property(readonly, retain) NSView *endedCallView;
@property(readonly, retain) NSProgressIndicator *callProgressIndicator;

// Designated initializer
- (id)initWithTelephoneCall:(AKTelephoneCall *)aCall
		  accountController:(AKAccountController *)anAccountController;

- (IBAction)acceptCall:(id)sender;
- (IBAction)hangUp:(id)sender;

@end


@interface NSObject(AKCallControllerNotifications)
- (void)telephoneCallWindowWillClose:(NSNotification *)notification;
@end

// Notifications
// accountController will be subscribed to this notification in its setter
APPKIT_EXTERN NSString *AKTelephoneCallWindowWillCloseNotification;