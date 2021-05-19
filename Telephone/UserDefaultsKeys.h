//
//  UserDefaultsKeys.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2021 64 Characters
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

@import Foundation;
@import UseCases;

#import "AKSIPAccountKeys.h"

extern NSString * const kAccounts;
extern NSString * const kSTUNServerHost;
extern NSString * const kSTUNServerPort;
extern NSString * const kSTUNDomain;
extern NSString * const kLogLevel;
extern NSString * const kConsoleLogLevel;
extern NSString * const kVoiceActivityDetection;
extern NSString * const kTransportPort;
extern NSString * const kRingingSound;
extern NSString * const kFormatTelephoneNumbers;
extern NSString * const kTelephoneNumberFormatterSplitsLastFourDigits;
extern NSString * const kOutboundProxyHost;
extern NSString * const kOutboundProxyPort;
extern NSString * const kUseICE;
extern NSString * const kUseDNSSRV;
extern NSString * const kUseQoS;
extern NSString * const kSignificantPhoneNumberLength;
extern NSString * const kAutoCloseCallWindow;
extern NSString * const kAutoCloseMissedCallWindow;
extern NSString * const kKeepCallWindowOnTop;
extern NSString * const kCallWaiting;
extern NSString * const kUseG711Only;
extern NSString * const kLockCodec;
extern NSString * const kSettingsVersion;

// Account keys
extern NSString * const kAccountIndex;
extern NSString * const kAccountEnabled;
extern NSString * const kSubstitutePlusCharacter;
extern NSString * const kPlusCharacterSubstitutionString;
