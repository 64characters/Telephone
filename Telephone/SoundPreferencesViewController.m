//
//  SoundPreferencesViewController.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[self soundInputPopUp] titleOfSelectedItem] forKey:kSoundInput];
    [defaults setObject:[[self soundOutputPopUp] titleOfSelectedItem] forKey:kSoundOutput];
    [defaults setObject:[[self ringtoneOutputPopUp] titleOfSelectedItem] forKey:kRingtoneOutput];
    
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


#pragma mark - SoundIOView

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
