//
//  UserDefaultsKeys.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

#import "UserDefaultsKeys.h"

NSString * const kAccounts = @"Accounts";
NSString * const kSTUNServerHost = @"STUNServerHost";
NSString * const kSTUNServerPort = @"STUNServerPort";
NSString * const kSTUNDomain = @"STUNDomain";
NSString * const kLogLevel = @"LogLevel";
NSString * const kConsoleLogLevel = @"ConsoleLogLevel";
NSString * const kVoiceActivityDetection = @"VoiceActivityDetection";
NSString * const kTransportPort = @"TransportPort";
NSString * const kRingingSound = @"RingingSound";
NSString * const kFormatTelephoneNumbers = @"FormatTelephoneNumbers";
NSString * const kTelephoneNumberFormatterSplitsLastFourDigits = @"TelephoneNumberFormatterSplitsLastFourDigits";
NSString * const kOutboundProxyHost = @"OutboundProxyHost";
NSString * const kOutboundProxyPort = @"OutboundProxyPort";
NSString * const kUseICE = @"UseICE";
NSString * const kUseDNSSRV = @"UseDNSSRV";
NSString * const kUseQoS = @"UseQoS";
NSString * const kSignificantPhoneNumberLength = @"SignificantPhoneNumberLength";
NSString * const kAutoCloseCallWindow = @"AutoCloseCallWindow";
NSString * const kAutoCloseMissedCallWindow = @"AutoCloseMissedCallWindow";
NSString * const kKeepCallWindowOnTop = @"KeepCallWindowOnTop";
NSString * const kCallWaiting = @"CallWaiting";
NSString * const kUseG711Only = @"UseG711Only";
NSString * const kLockCodec = @"LockCodec";
NSString * const kSettingsVersion = @"SettingsVersion";

NSString * const kAccountIndex = @"AccountIndex";
NSString * const kAccountEnabled = @"AccountEnabled";
NSString * const kSubstitutePlusCharacter = @"SubstitutePlusCharacter";
NSString * const kPlusCharacterSubstitutionString = @"PlusCharacterSubstitutionString";
