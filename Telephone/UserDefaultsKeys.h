//
//  UserDefaultsKeys.h
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

@import Foundation;
@import UseCases;

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
extern NSString * const kSettingsVersion;

// Account keys
extern NSString * const kUUID;
extern NSString * const kDescription;
extern NSString * const kFullName;
extern NSString * const kSIPAddress;
extern NSString * const kRegistrar;
extern NSString * const kDomain;
extern NSString * const kRealm;
extern NSString * const kUsername;
extern NSString * const kAccountIndex;
extern NSString * const kAccountEnabled;
extern NSString * const kReregistrationTime;
extern NSString * const kSubstitutePlusCharacter;
extern NSString * const kPlusCharacterSubstitutionString;
extern NSString * const kUseProxy;
extern NSString * const kProxyHost;
extern NSString * const kProxyPort;
extern NSString * const kTransport;
extern NSString * const kTransportUDP;
extern NSString * const kTransportTCP;
extern NSString * const kIPVersion;
extern NSString * const kIPVersion4;
extern NSString * const kIPVersion6;
extern NSString * const kUpdateContactHeader;
extern NSString * const kUpdateViaHeader;
extern NSString * const kUpdateSDP;
extern NSString * const kUseIPv6Only;
extern NSString * const kLockCodec;
