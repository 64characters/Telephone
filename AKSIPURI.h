//
//  AKSIPURI.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AKSIPURI : NSObject {
	NSString *displayName;
	NSString *user;
	NSString *password;
	NSString *host;
	NSInteger port;
	NSString *userParameter;
	NSString *methodParameter;
	NSString *transportParameter;
	NSInteger TTLParameter;
	NSInteger looseRoutingParameter;
	NSString *maddrParameter;
}

@property(readonly, copy) NSString *SIPAddress;
@property(readwrite, copy) NSString *displayName;
@property(readwrite, copy) NSString *user;
@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *host;
@property(readwrite, assign) NSInteger port;
@property(readwrite, copy) NSString *userParameter;
@property(readwrite, copy) NSString *methodParameter;
@property(readwrite, copy) NSString *transportParameter;
@property(readwrite, assign) NSInteger TTLParameter;
@property(readwrite, assign) NSInteger looseRoutingParameter;
@property(readwrite, copy) NSString *maddrParameter;

- (id)initWithString:(NSString *)SIPURIString;

+ (id)SIPURIWithString:(NSString *)SIPURIString;

@end
