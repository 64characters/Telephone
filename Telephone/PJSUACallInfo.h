//
//  PJSUACallInfo.h
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

@import Foundation;

#import <pjsua-lib/pjsua.h>

#import "AKSIPCall.h"

NS_ASSUME_NONNULL_BEGIN

@class AKSIPURIParser;

@interface PJSUACallInfo : NSObject

@property(nonatomic, readonly) NSInteger identifier;
@property(nonatomic, readonly) NSInteger accountIdentifier;
@property(nonatomic, readonly) AKSIPCallState state;
@property(nonatomic, readonly) NSString *stateText;
@property(nonatomic, readonly) NSInteger lastStatus;
@property(nonatomic, readonly) NSString *lastStatusText;
@property(nonatomic, readonly) AKSIPURI *localURI;
@property(nonatomic, readonly) AKSIPURI *remoteURI;
@property(nonatomic, readonly, getter=isIncoming) BOOL incoming;

- (instancetype)initWithInfo:(pjsua_call_info)info parser:(AKSIPURIParser *)parser NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
