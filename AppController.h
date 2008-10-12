//
//  AppController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <pjsua-lib/pjsua.h>


@class AKTelephone, AKAccountController, AKPreferenceController;

@interface AppController : NSObject {
	AKTelephone *telephone;
	NSMutableDictionary *accountControllers;
	AKPreferenceController *preferenceController;
}

@property(readonly, retain) AKTelephone *telephone;
@property(readonly, retain) NSMutableDictionary *accountControllers;
@property(readwrite, retain) AKPreferenceController *preferenceController;

- (IBAction)showPreferencePanel:(id)sender;

@end
