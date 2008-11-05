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

@property(nonatomic, readonly, copy) NSString *SIPAddress;
@property(nonatomic, readwrite, copy) NSString *displayName;
@property(nonatomic, readwrite, copy) NSString *user;
@property(nonatomic, readwrite, copy) NSString *password;
@property(nonatomic, readwrite, copy) NSString *host;
@property(nonatomic, readwrite, assign) NSInteger port;
@property(nonatomic, readwrite, copy) NSString *userParameter;
@property(nonatomic, readwrite, copy) NSString *methodParameter;
@property(nonatomic, readwrite, copy) NSString *transportParameter;
@property(nonatomic, readwrite, assign) NSInteger TTLParameter;
@property(nonatomic, readwrite, assign) NSInteger looseRoutingParameter;
@property(nonatomic, readwrite, copy) NSString *maddrParameter;

- (id)initWithString:(NSString *)SIPURIString;

+ (id)SIPURIWithString:(NSString *)SIPURIString;

@end
