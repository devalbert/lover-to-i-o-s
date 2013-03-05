//
//  XMPPManager.m
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "XMPPManager.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface XMPPManager()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

static XMPPManager *instance = nil;

@implementation XMPPManager

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

+ (XMPPManager *)sharedManager {
    if (!instance) {
        @synchronized(self) {
            instance = [[XMPPManager alloc] init];
            [instance setupStream];
        }
    }
    return instance;
}

- (void)dealloc
{
	[self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO; // Checked by Albert
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
	[xmppStream setHostName:@"www.weyor.com"];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = YES;
}

- (NSString *)loginedUser {
    if (![xmppStream isDisconnected]) {
		return [xmppStream.myJID user];
	}
    return nil;
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect:(NSString *)myJID password:(NSString *)myPassword {
    isRegUser = NO;
	if (![xmppStream isDisconnected]) {
        if (!xmppStream.isAuthenticated) {
            [xmppStream disconnect];
        } else {
            return YES;
        }
	}
    
    
    
//	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
//	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
//    NSString *myJID = @"29054@weyor.com";
//    NSString *myPassword = @"12345678";
    
    NSLog(@"XMPP SignIn: %@, %@", myJID, myPassword);
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
    
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		NSLog(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
    isRegUser = NO;
	[self goOffline];
	[xmppStream disconnect];
}

- (BOOL)regUser:(NSString *)myJID password:(NSString *)myPassword {
    NSLog(@"regUser: %@, %@", myJID, myPassword);
    isRegUser = YES;
    if (![xmppStream isDisconnected]) {
        [self goOffline];
        [xmppStream disconnect];
    }
    
    if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
    NSError *error = nil;
    [xmppStream connect:&error];
    if (error)
	{
        NSLog(@"RegUser Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPP_REGUSER_ERROR_NOTIFICATION" object:error];
		return NO;
	}
    
	return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
    // Turn off if reg user
    if (!isRegUser) {
        if (![[self xmppStream] authenticateWithPassword:password error:&error])
        {
            NSLog(@"Error authenticating: %@", error);
        }
    } else {
        if ([[self xmppStream] registerWithPassword:password error:&error]) {
            NSLog(@"Register user ok");
        } else {
            NSLog(@"%@", error);
        }
    }
    
    // register user on xmpp server
    /*
     if ([[self xmppStream] registerWithPassword:password error:&error]) {
     NSLog(@"Register user ok");
     } else {
     NSLog(@"%@", error);
     }
     */
    
    // XMPP Package
    // Register user using iq package
    /*
     XMPPIQ *regIQ = [XMPPIQ iqWithType:@"set"];
     [regIQ addAttributeWithName:@"to" stringValue:@"weyor.com"];
     NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
     [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:register"];
     
     NSXMLElement *username = [NSXMLElement elementWithName:@"username"];
     [username setStringValue:@"29005"];
     NSXMLElement *passwordNode = [NSXMLElement elementWithName:@"password"];
     [passwordNode setStringValue:@"12345678"];
     
     [query addChild:username];
     [query addChild:passwordNode];
     [regIQ addChild:query];
     
     NSLog(@"SEND: %@", regIQ);
     [[self xmppStream] sendElement:regIQ];
     */
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPP_AUTHENTICATE_SUCCESS" object:nil];
    // try send IQ
    // Check Status
    //    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    //    [iq addAttributeWithName:@"to" stringValue:@"29040@weyor.com"];
    //    [iq addAttributeWithName:@"from" stringValue:@"29039@weyor.com"];
    //    NSLog(@"SEND: %@", iq);
    //    [[self xmppStream] sendElement:iq];
    
    // Add match user
    // <presence xmlns="jabber:client" id="LBF0x-29" to="29039@weyor.com" type="subscribe" from="29040@weyor.com"/>
    // try invite user
    /*
     XMPPPresence *presence = [XMPPPresence presence];
     [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
     [presence addAttributeWithName:@"id" stringValue:@"lI92q-32"];
     [presence addAttributeWithName:@"to" stringValue:@"29042@weyor.com"];
     [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
     [presence addAttributeWithName:@"from" stringValue:@"29041@weyor.com"];
     NSLog(@"%@", presence);
     
     [[self xmppStream] sendElement:presence];
     */
    
    // try send Message
    /*
     NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
     [body setStringValue:@"Hi from XMPPFramework"];
     
     XMPPJID *toJID = [XMPPJID jidWithString:@"29040@weyor.com"];
     
     NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
     [message addAttributeWithName:@"type" stringValue:@"chat"];
     [message addAttributeWithName:@"to" stringValue:[toJID full]];
     [message addChild:body];
     [[self xmppStream] sendElement:message];
     */
    
    // roster
    //    [self fetchRoster];
    // remove the relationship with 29040
    //    [self removeBuddy:[XMPPJID jidWithString:@"29042@weyor.com"]];
    
    // Check status
    //    XMPPPresence *presence = [XMPPPresence presence];
    //    [presence addAttributeWithName:@"type" stringValue:@"unsubscribed"];
    //    [presence addAttributeWithName:@"to" stringValue:@"29040@weyor.com"];
    //    [presence addAttributeWithName:@"from" stringValue:@"29039@weyor.com"];
    //
    //    [[self xmppStream] sendElement:presence];
}

#pragma mark - XMPPRosterStorage
- (BOOL)configureWithParent:(XMPPRoster *)aParent queue:(dispatch_queue_t)queue {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    return YES;
}

- (void)beginRosterPopulationForXMPPStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)endRosterPopulationForXMPPStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)handleRosterItem:(NSXMLElement *)item xmppStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)userExistsWithJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    return YES;
}

- (void)clearAllResourcesForXMPPStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)clearAllUsersAndResourcesForXMPPStream:(XMPPStream *)stream {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}
// END..........

- (void)fetchRoster
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"to" stringValue:@"29042@weyor.com"];
	[iq addChild:query];
	
	[xmppStream sendElement:iq];
}

- (void)removeBuddy:(XMPPJID *)jid
{
	if(jid == nil) return;
	
	// Remove the buddy from our roster
	// Unsubscribe from presence
	// And revoke contact's subscription to our presence
	// ...all in one step
	
	NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
	[item addAttributeWithName:@"jid" stringValue:[jid bare]];
	[item addAttributeWithName:@"subscription" stringValue:@"remove"];
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
	[query addChild:item];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"set"];
	[iq addChild:query];
	
	[xmppStream sendElement:iq];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPP_AUTHENTICATE_ERROR" object:nil];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"%@", iq);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
			[alertView show];
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	NSLog(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    // Approving: <presence to='romeo@example.net' type='subscribed'/>
    // Refuse: <presence to='romeo@example.net' type='unsubscribed'/>
    
    /*
     XMPPPresence *p = [XMPPPresence presence];
     [p addAttributeWithName:@"to" stringValue:presence.from.full];
     [p addAttributeWithName:@"from" stringValue:presence.to.full];
     [p addAttributeWithName:@"type" stringValue:@"unsubscribed"];
     NSLog(@"%@", p);
     
     [[self xmppStream] sendElement:p];
     [self removeBuddy:presence.from];
     */
    NSLog(@"Get Presence Finished======");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PERSENSE_ARRIVED" object:presence];
}

- (void)acceptInvitation:(NSString *)userJID {
    XMPPPresence *p = [XMPPPresence presence];
    NSString *myJID = [NSString stringWithFormat:@"%@@weyor.com", [xmppStream.myJID user]];
    [p addAttributeWithName:@"to" stringValue:userJID];
    [p addAttributeWithName:@"from" stringValue:myJID];
    [p addAttributeWithName:@"type" stringValue:@"subscribed"];
    NSLog(@"%@", p);
    
    [[self xmppStream] sendElement:p];
}

- (void)rejectInvitation:(NSString *)userJID {
    XMPPPresence *p = [XMPPPresence presence];
    NSString *myJID = [NSString stringWithFormat:@"%@@weyor.com", [xmppStream.myJID user]];
    [p addAttributeWithName:@"to" stringValue:userJID];
    [p addAttributeWithName:@"from" stringValue:myJID];
    [p addAttributeWithName:@"type" stringValue:@"unsubscribed"];
    NSLog(@"%@", p);
    
    [[self xmppStream] sendElement:p];
    [self removeBuddy:[XMPPJID jidWithString:userJID]];
}

- (void)removeInvitation:(NSString *)userJID {
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		NSLog(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

- (void)inviteUser:(NSString *)userJID {
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [presence addAttributeWithName:@"id" stringValue:@"lI92q-32"];
    [presence addAttributeWithName:@"to" stringValue:userJID];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    NSString *myJID = [NSString stringWithFormat:@"%@@weyor.com", [xmppStream.myJID user]];
    [presence addAttributeWithName:@"from" stringValue:myJID];
    NSLog(@"%@", presence);
    
    [[self xmppStream] sendElement:presence];
}

- (void)requestUserVcard:(NSString *)userJID {
    NSXMLElement *vcard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:@"v3"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"to" stringValue:userJID];
	[iq addChild:vcard];
    
    NSLog(@"%@", iq);
    
    [[self xmppStream] sendElement:iq];
}

- (void)updateMyVcard {
    NSXMLElement *vc = [NSXMLElement elementWithName:@"VC" stringValue:@"0de5fb6ee4ee1d8c"];
    NSXMLElement *taweid = [NSXMLElement elementWithName:@"taweid" stringValue:@"0"]; // 对方微号,缺省值为"0"表示未匹配
    NSXMLElement *email = [NSXMLElement elementWithName:@"email" stringValue:@"albert1@a.com"];
    NSXMLElement *gender = [NSXMLElement elementWithName:@"gender" stringValue:@"男"];
    NSXMLElement *nickname = [NSXMLElement elementWithName:@"NICKNAME" stringValue:@"nickname"];
    NSXMLElement *face = [NSXMLElement elementWithName:@"face" stringValue:@"face"];// 头像文件名，缺省值为"face" (face+次数)第一次是1
    NSXMLElement *ourphoto = [NSXMLElement elementWithName:@"ourphoto" stringValue:@"ourphoto"];// 合影文件名，缺省值为"ourphoto" (ourphoto+次数)第一次是1
    NSXMLElement *tatel = [NSXMLElement elementWithName:@"tatel" stringValue:@"0"];//对方手机号码,缺省值为"0"
    
    NSXMLElement *vcard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [vcard addChild:vc];
    [vcard addChild:taweid];
    [vcard addChild:email];
    [vcard addChild:gender];
    [vcard addChild:nickname];
    [vcard addChild:face];
    [vcard addChild:ourphoto];
    [vcard addChild:tatel];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:@"v2"];
	[iq addAttributeWithName:@"type" stringValue:@"set"];
	[iq addChild:vcard];
    
    NSLog(@"%@", iq);
    
    [[self xmppStream] sendElement:iq];
}

@end
