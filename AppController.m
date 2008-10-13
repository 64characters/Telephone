//
//  AppController.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "AKAccountController.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneConfig.h"


@implementation AppController

@synthesize telephone;
@synthesize accountControllers;
@synthesize preferenceController;

+ (void)initialize
{
	// Register defaults
	static BOOL initialized = NO;
	
	if (!initialized) {
		NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
		
		[defaultsDict setObject:[NSNumber numberWithInt:3478] forKey:AKSTUNServerPort];
		[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:AKVoiceActivityDetection];
		[defaultsDict setObject:@"~/Library/Logs/Telephone.log" forKey:AKLogFileName];
		[defaultsDict setObject:[NSNumber numberWithInt:5060] forKey:AKTransportPort];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
		
		initialized = YES;
	}
}

- (void)dealloc
{
	[telephone dealloc];
	[accountControllers release];
	
	if ([[[self preferenceController] delegate] isEqual:self])
		[[self preferenceController] setDelegate:nil];
	
	[preferenceController release];
	
	[super dealloc];
}

// Application control starts here
- (void)awakeFromNib
{
	telephone = [AKTelephone telephoneWithConfig:[AKTelephoneConfig telephoneConfig]];
	if (telephone == nil) {
		NSLog(@"Can't create Telephone");
		return;
	}
	
	accountControllers = [[NSMutableDictionary alloc] init];
	
	// Read accounts from defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *savedAccounts = [defaults dictionaryForKey:AKAccounts];
	NSArray *accountSortOrder = [defaults arrayForKey:AKAccountSortOrder];
	
	for (NSString *accountKey in accountSortOrder) {
		NSDictionary *accountDict = [savedAccounts objectForKey:accountKey];
		
		if (![[accountDict objectForKey:AKAccountEnabled] boolValue])
			continue;
		
		NSString *fullName = [accountDict objectForKey:AKFullName];
		NSString *sipAddress = [accountDict objectForKey:AKSIPAddress];
		NSString *registrar = [accountDict objectForKey:AKRegistrar];
		NSString *realm = [accountDict objectForKey:AKRealm];
		NSString *username = [accountDict objectForKey:AKUsername];
		
		AKAccountController *anAccountController = [[AKAccountController alloc] initWithFullName:fullName
																					  sipAddress:sipAddress
																					   registrar:registrar
																						   realm:realm
																						username:username];
		[[self accountControllers] setObject:anAccountController forKey:accountKey];
		
		[[anAccountController window] setTitle:[[anAccountController account] sipAddress]];
		[anAccountController showWindow:self];
		
		[anAccountController release];
	}
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (preferenceController == nil) {
		preferenceController = [[AKPreferenceController alloc] init];
		[[self preferenceController] setDelegate:self];
	}
	
	if (![[[self preferenceController] window] isVisible])
		[[[self preferenceController] window] center];
	
	[[self preferenceController] showWindow:nil];
}

- (void)preferenceControllerDidAddAccount:(NSNotification *)notification
{
	NSString *accountKey = [[[notification userInfo] allKeys] lastObject];
	NSDictionary *accountDict = [[notification userInfo] objectForKey:accountKey];
	AKAccountController *theAccountController =	[[AKAccountController alloc]
												 initWithFullName:[accountDict objectForKey:AKFullName]
												 sipAddress:[accountDict objectForKey:AKSIPAddress]
												 registrar:[accountDict objectForKey:AKRegistrar]
												 realm:[accountDict objectForKey:AKRealm]
												 username:[accountDict objectForKey:AKUsername]];
	
	[[self accountControllers] setObject:theAccountController forKey:accountKey];
	
	[[theAccountController window] setTitle:[[theAccountController account] sipAddress]];
	[theAccountController showWindow:self];
	[theAccountController release];
}

- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification
{
	NSString *accountKey = [[notification userInfo] objectForKey:AKAccountKey];
	AKAccountController *theAccountController = [[self accountControllers] objectForKey:accountKey];
	BOOL isRemoved = [[self telephone] removeAccount:[theAccountController account]];
	if (isRemoved) {
		NSLog(@"Removing %@", theAccountController);
		[[self accountControllers] removeObjectForKey:accountKey];
	}
}

- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification
{
	NSString *accountKey = [[notification userInfo] objectForKey:AKAccountKey];
	AKAccountController *theAccountController = [[self accountControllers] objectForKey:accountKey];
	
	if (theAccountController != nil)
		[[theAccountController account] setRegistered:[[[notification userInfo] objectForKey:AKAccountEnabled] boolValue]];
	else {
		NSDictionary *savedAccounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AKAccounts];
		NSDictionary *accountDict = [savedAccounts objectForKey:accountKey];
		
		NSString *fullName = [accountDict objectForKey:AKFullName];
		NSString *sipAddress = [accountDict objectForKey:AKSIPAddress];
		NSString *registrar = [accountDict objectForKey:AKRegistrar];
		NSString *realm = [accountDict objectForKey:AKRealm];
		NSString *username = [accountDict objectForKey:AKUsername];
		
		AKAccountController *anAccountController = [[AKAccountController alloc] initWithFullName:fullName
																					  sipAddress:sipAddress
																					   registrar:registrar
																						   realm:realm
																						username:username];
		[[self accountControllers] setObject:anAccountController forKey:accountKey];
		
		[[anAccountController window] setTitle:[[anAccountController account] sipAddress]];
		[anAccountController showWindow:self];
		
		[anAccountController release];
	}
}

#pragma mark -
#pragma mark NSApplication Delegate Methods

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	for (NSString *accountKey in [self accountControllers]) {
		AKAccountController *anAccountController = [[self accountControllers] objectForKey:accountKey];
		[anAccountController showWindow:nil];
	}
}

// Shut down underlying sip user agent correctly
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[[self telephone] destroyUserAgent];
	
	return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
//	[self release];
}

@end
