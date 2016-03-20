//
//  SoundPreferencesViewController.h
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

#import <Cocoa/Cocoa.h>

#import "SoundIOPreferences.h"
#import "SoundPreferencesView.h"

@protocol SoundPreferencesViewEventTarget;

NS_ASSUME_NONNULL_BEGIN

@interface SoundPreferencesViewController : NSViewController <SoundIOPreferences, SoundPreferencesView>

@property(nonatomic, readonly) id<SoundPreferencesViewEventTarget> eventTarget;

- (instancetype)initWithEventTarget:(id<SoundPreferencesViewEventTarget>)eventTarget;

- (void)ak_viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
