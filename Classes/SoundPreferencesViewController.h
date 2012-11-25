//
//  SoundPreferencesViewController.h
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
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

#import <Cocoa/Cocoa.h>


// A view controller to manage sound preferences.
@interface SoundPreferencesViewController : NSViewController {
  @private
    NSPopUpButton *soundInputPopUp_;
    NSPopUpButton *soundOutputPopUp_;
    NSPopUpButton *ringtoneOutputPopUp_;
    NSPopUpButton *ringtonePopUp_;
}

// Outlets.
@property (nonatomic, retain) IBOutlet NSPopUpButton *soundInputPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *soundOutputPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *ringtoneOutputPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *ringtonePopUp;

// Changes sound input and output devices.
- (IBAction)changeSoundIO:(id)sender;

// Refreshes list of available audio devices.
- (void)updateAudioDevices;

// Updates the list of available sounds for a ringtone. Sounds are being searched in the following locations.
//
// ~/Library/Sounds
// /Library/Sounds
// /Network/Library/Sounds
// /System/Library/Sounds
//
- (void)updateAvailableSounds;

// Changes a ringtone sound.
- (IBAction)changeRingtone:(id)sender;

@end
