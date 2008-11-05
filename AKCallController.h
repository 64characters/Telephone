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

@property(nonatomic, readwrite, retain) AKTelephoneCall *call;
@property(nonatomic, readwrite, assign) AKAccountController *accountController;
@property(nonatomic, readwrite, copy) NSString *status;

@property(nonatomic, readonly, retain) NSView *incomingCallView;
@property(nonatomic, readonly, retain) NSView *activeCallView;
@property(nonatomic, readonly, retain) NSView *endedCallView;
@property(nonatomic, readonly, retain) NSProgressIndicator *callProgressIndicator;

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
extern NSString *AKTelephoneCallWindowWillCloseNotification;
