//
//  AKTelephoneConfig.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <pjsua-lib/pjsua.h>


@interface AKTelephoneConfig : NSObject {
	pjsua_config userAgentConfig;
	pjsua_logging_config loggingConfig;
	pjsua_media_config mediaConfig;
	pjsua_transport_config transportConfig;
}

@property(readonly, assign) pjsua_config *userAgentConfig;
@property(readonly, assign) pjsua_logging_config *loggingConfig;
@property(readonly, assign) pjsua_media_config *mediaConfig;
@property(readonly, assign) pjsua_transport_config *transportConfig;

+ (id)telephoneConfig;

@end
