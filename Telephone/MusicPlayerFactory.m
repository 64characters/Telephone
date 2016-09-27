//
//  MusicPlayerFactory.m
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

#import "MusicPlayerFactory.h"

#import "AppleMusicPlayer.h"
#import "iTunes.h"
#import "Spotify.h"
#import "SpotifyMusicPlayer.h"

@implementation MusicPlayerFactory

- (nullable id<MusicPlayer>)makeAppleMusicPlayer {
    SBApplication *application = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if (application) {
        return [[AppleMusicPlayer alloc] initWithApplication:(iTunesApplication *)application];
    } else {
        return nil;
    }
}

- (nullable id<MusicPlayer>)makeSpotifyMusicPlayer {
    SBApplication *application = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (application) {
        return [[SpotifyMusicPlayer alloc] initWithApplication:(SpotifyApplication *)application];
    } else {
        return nil;
    }
}

@end
