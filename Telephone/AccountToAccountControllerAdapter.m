//
//  AccountToAccountControllerAdapter.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

#import "AccountToAccountControllerAdapter.h"

#import "AKSIPURI.h"

@interface AccountToAccountControllerAdapter ()

@property(nonatomic, nullable, weak, readonly) AccountController *controller;

@end

@implementation AccountToAccountControllerAdapter

- (instancetype)initWithController:(AccountController *)controller {
    if ((self = [super init])) {
        _controller = controller;
    }
    return self;
}

#pragma mark - Account

- (NSString *)uuid {
    return self.controller.account.uuid;
}

- (NSString *)domain {
    return self.controller.account.domain;
}

- (void)makeCallTo:(URI *)uri {
    [self.controller makeCallToURI:[AKSIPURI SIPURIWithUser:uri.user host:uri.host displayName:@""] phoneLabel:@""];
}

@end
