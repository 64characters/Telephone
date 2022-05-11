//
//  MusicAppMusicPlayer.m
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

#import "MusicAppMusicPlayer.h"

#import "MusicApp.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicAppMusicPlayer ()

@property(nonatomic, readonly) MusicAppApplication *application;
@property(nonatomic) BOOL didPause;

@end

NS_ASSUME_NONNULL_END

@implementation MusicAppMusicPlayer

- (instancetype)initWithApplication:(MusicAppApplication *)application {
    if ((self = [super init])) {
        _application = application;
    }
    return self;
}

#pragma mark - MusicPlayer

- (void)pause {
    if (!self.application.isRunning || self.application.playerState != MusicAppEPlSPlaying) {
        return;
    }
    [self.application pause];
    self.didPause = YES;
}

- (void)resume {
    if (!self.application.isRunning || !self.didPause) {
        return;
    }
    if (self.application.playerState == MusicAppEPlSPaused) {
        [self.application playOnce:NO];
    }
    self.didPause = NO;
}

@end
