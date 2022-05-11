//
//  SoundPreferencesViewController.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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

#import "Telephone-Swift.h"

NS_ASSUME_NONNULL_BEGIN

static NSMenu *MenuForSoundsAtPaths(NSArray<NSString *> *paths);
static NSMenu *MenuForDevices(NSArray<PresentationAudioDevice *> *devices);
static NSArray<NSMenuItem *> *MenuItemsForDevices(NSArray<PresentationAudioDevice *> *devices);
static NSMenuItem *MenuItemForDevice(PresentationAudioDevice *device);

@interface SoundPreferencesViewController ()

@property(nonatomic, readonly) SoundPreferencesViewEventTarget *eventTarget;
@property(nonatomic, readonly) AKSIPUserAgent *userAgent;

@property(nonatomic, weak) IBOutlet NSPopUpButton *soundInputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *soundOutputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *ringtoneOutputPopUp;
@property(nonatomic, weak) IBOutlet NSPopUpButton *ringtonePopUp;
@property(nonatomic, weak) IBOutlet NSButton *useG711OnlyCheckBox;

@end

NS_ASSUME_NONNULL_END

@implementation SoundPreferencesViewController

- (instancetype)initWithEventTarget:(SoundPreferencesViewEventTarget *)eventTarget userAgent:(AKSIPUserAgent *)userAgent {
    if ((self = [super initWithNibName:@"SoundPreferencesView" bundle:nil])) {
        _eventTarget = eventTarget;
        _userAgent = userAgent;
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

    [self.eventTarget viewShouldReloadData:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear {
    [self.eventTarget viewWillDisappear:self];
}

- (IBAction)changeSoundIO:(id)sender {
    [self.eventTarget viewDidChangeSoundIO:
     [[PresentationSoundIO alloc] initWithInput:self.soundInputPopUp.selectedItem.representedObject
                                         output:self.soundOutputPopUp.selectedItem.representedObject
                                 ringtoneOutput:self.ringtoneOutputPopUp.selectedItem.representedObject]];
}

- (IBAction)changeUseG711Only:(id)sender {
    self.userAgent.usesG711Only = (self.useG711OnlyCheckBox.state == NSOnState) ? YES : NO;
}

- (void)updateAvailableSounds {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
    if ([libraryPaths count] <= 0) {
        return;
    }
    NSMenu *soundsMenu = MenuForSoundsAtPaths(libraryPaths);
    [[self ringtonePopUp] setMenu:soundsMenu];
    NSString *savedSound = [[NSUserDefaults standardUserDefaults] stringForKey:UserDefaultsKeys.ringingSound];
    if ([soundsMenu itemWithTitle:savedSound] != nil) {
        [[self ringtonePopUp] selectItemWithTitle:savedSound];
    }
}

- (IBAction)changeRingtone:(id)sender {
    [self.eventTarget viewDidChangeRingtoneName:[sender title]];
}


#pragma mark - SoundIOPreferences

- (void)updateSoundIO {
    [self.eventTarget viewShouldReloadSoundIO:self];
}

#pragma mark - SoundPreferencesView

- (void)updateWithSoundIO:(PresentationSoundIO *)soundIO devices:(PresentationAudioDevices *)devices {
    self.soundInputPopUp.menu = MenuForDevices(devices.input);
    self.soundOutputPopUp.menu = MenuForDevices(devices.output);
    self.ringtoneOutputPopUp.menu = MenuForDevices(devices.ringtoneOutput);
    [self.soundInputPopUp selectItemWithTitle:soundIO.input.name];
    [self.soundOutputPopUp selectItemWithTitle:soundIO.output.name];
    [self.ringtoneOutputPopUp selectItemWithTitle:soundIO.ringtoneOutput.name];
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

static NSMenu *MenuForDevices(NSArray<PresentationAudioDevice *> *devices) {
    NSMenu *menu = [[NSMenu alloc] init];
    for (NSMenuItem *item in MenuItemsForDevices(devices)) {
        [menu addItem:item];
    }
    return menu;
}

static NSArray<NSMenuItem *> *MenuItemsForDevices(NSArray<PresentationAudioDevice *> *devices) {
    NSMutableArray<NSMenuItem *> *items = [[NSMutableArray alloc] init];
    for (PresentationAudioDevice *device in devices) {
        [items addObject:MenuItemForDevice(device)];
    }
    if (devices.count > 1 && devices.firstObject.isSystemDefault) {
        [items insertObject:[NSMenuItem separatorItem] atIndex:1];
    }
    return [items copy];
}

static NSMenuItem *MenuItemForDevice(PresentationAudioDevice *device) {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = device.name;
    item.representedObject = device;
    return item;
}
