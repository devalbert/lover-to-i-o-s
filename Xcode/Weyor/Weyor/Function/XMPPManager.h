//
//  XMPPManager.h
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"

@interface XMPPManager : NSObject<XMPPRosterDelegate, XMPPRosterStorage> {
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    BOOL isRegUser;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect:(NSString *)myJID password:(NSString *)myPassword;
- (void)disconnect;
- (BOOL)regUser:(NSString *)myJID password:(NSString *)myPassword;
- (void)inviteUser:(NSString *)userJID;

- (NSString *)loginedUser;
- (void)requestUserVcard:(NSString *)userJID;
- (void)updateMyVcard;

+ (XMPPManager *)sharedManager;

- (void)acceptInvitation:(NSString *)userJID;
- (void)rejectInvitation:(NSString *)userJID;
- (void)removeInvitation:(NSString *)userJID;

@end
