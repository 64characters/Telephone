//
//  SoundPreferencesViewController.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import "SoundPreferencesViewController.h"

#import "AppController.h"
#import "UserDefaultsKeys.h"

#import "Telephone-Swift.h"

NS_ASSUME_NONNULL_BEGIN

static NSMenu *MenuForSoundsAtPaths(NSArray<NSString *> *paths);
static NSMenu *MenuForDevices(NSArray<NSString *> *devices);
static NSMenuItem *MenuItemForDevice(NSString *device);

@interface SoundPreferencesViewController ()

@property(nonatomic, weak) IBOutlet NSPopUpButton *soundInputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *soundOutputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *ringtoneOutputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *ringtonePopUp;
@property(nonatomic, weak) IBOutlet NSButton *useG711OnlyCheckBox;

@end

NS_ASSUME_NONNULL_END

@implementation SoundPreferencesViewController

- (instancetype)initWithObserver:(id<SoundPreferencesViewObserver>)observer {
    if ((self = [super initWithNibName:@"SoundPreferencesView" bundle:nil])) {
        _observer = observer;
        self.title = NSLocalizedString(@"Sound", @"Sound preferences window title.");
    }
    return self;
}

- (instancetype)init {
    assert(NO);
}

- (void)awakeFromNib {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(popUpButtonWillPopUp:)
                               name:NSPopUpButtonWillPopUpNotification
                             object:[self ringtonePopUp]];
    
    [self updateAvailableSounds];

    [self.observer viewShouldReloadData:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)changeSoundIO:(id)sender {
    [self.observer viewDidChangeSoundInput:self.soundInputPopUp.titleOfSelectedItem
                               soundOutput:self.soundOutputPopUp.titleOfSelectedItem
                            ringtoneOutput:self.ringtoneOutputPopUp.titleOfSelectedItem];
    [[NSApp delegate] selectSoundIO];
}

- (IBAction)changeUseG711Only:(id)sender {
    [AKSIPUserAgent sharedUserAgent].usesG711Only = (self.useG711OnlyCheckBox.state == NSOnState) ? YES : NO;
}

- (void)updateAvailableSounds {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
    if ([libraryPaths count] <= 0) {
        return;
    }
    NSMenu *soundsMenu = MenuForSoundsAtPaths(libraryPaths);
    [[self ringtonePopUp] setMenu:soundsMenu];
    NSString *savedSound = [[NSUserDefaults standardUserDefaults] stringForKey:kRingingSound];
    if ([soundsMenu itemWithTitle:savedSound] != nil) {
        [[self ringtonePopUp] selectItemWithTitle:savedSound];
    }
}

- (IBAction)changeRingtone:(id)sender {
    [[[NSApp delegate] ringtone] stop];
    
    NSString *soundName = [sender title];
    [[NSUserDefaults standardUserDefaults] setObject:soundName forKey:kRingingSound];
    [[NSApp delegate] setRingtone:[NSSound soundNamed:soundName]];
    
    [[[NSApp delegate] ringtone] play];
}


#pragma mark - SoundPreferencesView

- (void)setInputAudioDevices:(NSArray<NSString *> *)devices {
    self.soundInputPopUp.menu = MenuForDevices(devices);
}

- (void)setOutputAudioDevices:(NSArray<NSString *> *)devices {
    self.soundOutputPopUp.menu = MenuForDevices(devices);
}

- (void)setRingtoneOutputAudioDevices:(NSArray<NSString *> *)devices {
    self.ringtoneOutputPopUp.menu = MenuForDevices(devices);
}

- (void)setSoundInputDevice:(NSString *)device {
    [self.soundInputPopUp selectItemWithTitle:device];
}

- (void)setSoundOutputDevice:(NSString *)device {
    [self.soundOutputPopUp selectItemWithTitle:device];
}

- (void)setRingtoneOutputDevice:(NSString *)device {
    [self.ringtoneOutputPopUp selectItemWithTitle:device];
}


#pragma mark -
#pragma mark NSPopUpButton notification

- (void)popUpButtonWillPopUp:(NSNotification *)notification {
    [self updateAvailableSounds];
}

@end

static NSMenu *MenuForSoundsAtPaths(NSArray<NSString *> *paths) {
    NSMenu *menu = [[NSMenu alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSSet *allowedSoundFileExtensions = [NSSet setWithObjects:@"aiff", @"aif", @"aifc",
                                         @"mp3", @"wav", @"sd2", @"au", @"snd", @"m4a", @"m4p", nil];

    for (NSUInteger i = 0; i < [paths count]; ++i) {
        NSString *aPath = paths[i];
        NSString *soundPath = [aPath stringByAppendingPathComponent:@"Sounds"];
        NSArray *soundFiles = [fileManager contentsOfDirectoryAtPath:soundPath error:NULL];

        BOOL shouldAddSeparator = ([menu numberOfItems] > 0) ? YES : NO;

        for (NSUInteger j = 0; j < [soundFiles count]; ++j) {
            NSString *aFile = soundFiles[j];
            if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]]) {
                continue;
            }

            NSString *aSound = [aFile stringByDeletingPathExtension];
            if ([menu itemWithTitle:aSound] == nil) {
                if (shouldAddSeparator) {
                    [menu addItem:[NSMenuItem separatorItem]];
                    shouldAddSeparator = NO;
                }

                NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
                [aMenuItem setTitle:aSound];
                [menu addItem:aMenuItem];
            }
        }
    }

    return menu;
}

static NSMenu *MenuForDevices(NSArray<NSString *> *devices) {
    NSMenu *menu = [[NSMenu alloc] init];
    for (NSString *device in devices) {
        [menu addItem:MenuItemForDevice(device)];
    }
    return menu;
}

static NSMenuItem *MenuItemForDevice(NSString *device) {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = device;
    return item;
}
