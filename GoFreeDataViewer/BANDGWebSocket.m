//
//  BANDGWebSocket.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 01/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "BANDGWebSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface BANDGWebSocket ()

@end

@implementation BANDGWebSocket

#pragma mark Web Socket
/**
 * Called when the web socket connects and is ready for reading and writing.
 **/
- (void) didOpen
{
    NSLog(@"Socket is open for business.");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SocketOpen"
     object:self];
}

/**
 * Called when the web socket closes. aError will be nil if it closes cleanly.
 **/
- (void) didClose:(NSUInteger) aStatusCode message:(NSString*) aMessage error:(NSError*) aError
{
    NSLog(@"Oops. It closed.");
}

/**
 * Called when the web socket receives an error. Such an error can result in the
 socket being closed.
 **/
- (void) didReceiveError:(NSError*) aError
{
    NSLog(@"Oops. An error occurred.");
}

/**
 * Called when the web socket receives a message.
 **/
- (void) didReceiveTextMessage:(NSString*) aMessage
{
    //Hooray! I got a message to print.
    //NSLog(@"Did receive message: %@", aMessage);
    NSError *e = nil;
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [aMessage dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    
    if(JSON)
    {
        NSArray *devList = [JSON objectForKey:@"DeviceList"];
        if(devList)
        {
            self.deviceList = devList;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DeviceListUpdated"
             object:self];
        }
    }
}

/**
 * Called when the web socket receives a message.
 **/
- (void) didReceiveBinaryMessage:(NSData*) aMessage
{
    //Hooray! I got a binary message.
    NSLog(@"Did receive binary message");
}

/**
 * Called when pong is sent... For keep-alive optimization.
 **/
- (void) didSendPong:(NSData*) aMessage
{
    NSLog(@"Yay! Pong was sent!");
}

- (void)sendMessage:(NSString*)message
{
    [self.ws sendText:message];
    NSLog(@"Did send message: %@", message);
}

- (void)requestDeviceList
{
    [self.ws sendText:@"{\"DeviceListReq\":{\"DeviceTypes\":[]}}"];
}

@synthesize ws;

#pragma mark Web Socket
- (void) startMyWebSocket
{
    [self.ws open];
    //continue processing other stuff
    //...
}

#pragma mark Lifecycle
- (id)init:(NSString*)address
{
    self = [super init];
    if (self)
    {
        //make sure to use the right url, it must point to your specific web socket endpoint or the handshake will fail
        //create a connect config and set all our info here
        WebSocketConnectConfig* config = [WebSocketConnectConfig configWithURLString:address origin:nil protocols:nil tlsSettings:nil headers:nil verifySecurityKey:YES extensions:nil ];
        config.closeTimeout = 15.0;
        config.keepAlive = 15.0;//sends a ws ping every 15s to keep socket alive
        
        //setup dispatch queue for delegate logic (not required, the websocket will create its own if not supplied)
        dispatch_queue_t delegateQueue = dispatch_queue_create("myWebSocketQueue", NULL);
        
        //open using the connect config, it will be populated with server info, such as selected protocol/etc
        ws = [WebSocket webSocketWithConfig:config queue:delegateQueue delegate:self];
    }
    return self;
}

@end
