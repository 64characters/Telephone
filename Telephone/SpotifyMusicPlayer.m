//
//  SpotifyMusicPlayer.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#import "SpotifyMusicPlayer.h"

#import "Spotify.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyMusicPlayer ()

@property(nonatomic, readonly) SpotifyApplication *app;
@property(nonatomic) BOOL didPause;

@end

NS_ASSUME_NONNULL_END

@implementation SpotifyMusicPlayer

- (nullable instancetype)init {
    if ((self = [super init])) {
        _app = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
        if (!_app) {
            return nil;
        }
    }
    return self;
}

#pragma mark - MusicPlayer

- (void)pause {
    if (!self.app.isRunning || self.app.playerState != SpotifyEPlSPlaying) {
        return;
    }
    [self.app pause];
    self.didPause = YES;
}

- (void)resume {
    if (!self.app.isRunning || !self.didPause) {
        return;
    }
    if (self.app.playerState == SpotifyEPlSPaused) {
        [self.app play];
    }
    self.didPause = NO;
}

@end
