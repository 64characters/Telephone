//
//  AppController.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>


@class AKTelephone, AKAccountController, AKPreferenceController;

@interface AppController : NSObject {
	AKTelephone *telephone;
	NSMutableDictionary *accountControllers;
	AKPreferenceController *preferenceController;
	
	IBOutlet NSMenuItem *preferencesMenuItem;
}

@property(nonatomic, readonly, retain) AKTelephone *telephone;
@property(nonatomic, readonly, retain) NSMutableDictionary *accountControllers;
@property(nonatomic, readwrite, retain) AKPreferenceController *preferenceController;

// Choose saved previously or first matched sound devices from the list of available devices.
- (void)selectSoundDevices;

- (IBAction)showPreferencePanel:(id)sender;

- (IBAction)addAccountOnFirstLaunch:(id)sender;

@end


// AudioHardware callback to track adding/removing audio devices
OSStatus AHPropertyListenerProc(AudioHardwarePropertyID inPropertyID, void *inClientData);