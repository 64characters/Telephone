//
//  NetworkPreferencesViewController.h
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

#import <Cocoa/Cocoa.h>


@class AKSIPUserAgent, PreferencesController;

// A view controller to manage network preferences.
@interface NetworkPreferencesViewController : NSViewController

@property(nonatomic, readonly, weak) PreferencesController *preferencesController;
@property(nonatomic, readonly) AKSIPUserAgent *userAgent;

// Outlets.
@property(nonatomic, weak) IBOutlet NSTextField *transportPortField;
@property(nonatomic, weak) IBOutlet NSTextField *STUNServerHostField;
@property(nonatomic, weak) IBOutlet NSTextField *STUNServerPortField;
@property(nonatomic, weak) IBOutlet NSButton *useICECheckBox;
@property(nonatomic, weak) IBOutlet NSButton *useDNSSRVCheckBox;
@property(nonatomic, weak) IBOutlet NSTextField *outboundProxyHostField;
@property(nonatomic, weak) IBOutlet NSTextField *outboundProxyPortField;
@property(nonatomic, weak) IBOutlet NSButton *deleteOutboundProxyButton;

- (instancetype)initWithPreferencesController:(PreferencesController *)preferencesController
                                    userAgent:(AKSIPUserAgent *)userAgent;

// Returns YES if network settings have been changed.
- (BOOL)areNetworkSettingsChanged:(id)sender;

@end
