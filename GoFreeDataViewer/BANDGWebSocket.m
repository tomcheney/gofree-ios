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

static NSDictionary* dataIdDictionary = nil;
+ (NSDictionary*)getDataIdDictionary {
    
    if (dataIdDictionary == nil)
        dataIdDictionary = [[NSDictionary alloc]
                            initWithObjects:[NSArray arrayWithObjects:
                                             @"GPS",
                                             @"Navigation",
                                             @"Vessel",
                                             @"Sonar",
                                             @"Weather",
                                             @"Trip",
                                             @"Time",
                                             @"Engine",
                                             @"Transmission",
                                             @"FuelTank",
                                             @"FreshWaterTank",
                                             @"GrayWaterTank",
                                             @"LiveWellTank",
                                             @"OilTank",
                                             @"BlackWaterTank",
                                             @"EngineRoom",
                                             @"Cabin",
                                             @"BaitWell",
                                             @"Refrigerator",
                                             @"HeatingSystem",
                                             @"Freezer",
                                             @"Battery",
                                             @"Rudder",
                                             @"TrimTab",
                                             @"ACInput",
                                             @"DigitalSwitching",
                                             @"Other",
                                             @"GPSStatus",
                                             @"RouteData",
                                             @"SpeedDepth",
                                             @"LogTimer",
                                             @"Environment",
                                             @"Wind",
                                             @"Pilot",
                                             @"Sailing",
                                             @"AcOutput",
                                             @"Charger",
                                             @"Inverter",
                                             @"Unknown",
                                             nil]
                            forKeys:[NSArray arrayWithObjects:
                                     @"1",
                                     @"2",
                                     @"3",
                                     @"4",
                                     @"5",
                                     @"6",
                                     @"7",
                                     @"8",
                                     @"9",
                                     @"10",
                                     @"11",
                                     @"12",
                                     @"13",
                                     @"14",
                                     @"15",
                                     @"16",
                                     @"17",
                                     @"18",
                                     @"19",
                                     @"20",
                                     @"21",
                                     @"22",
                                     @"23",
                                     @"24",
                                     @"25",
                                     @"26",
                                     @"27",
                                     @"28",
                                     @"29",
                                     @"30",
                                     @"31",
                                     @"32",
                                     @"33",
                                     @"34",
                                     @"35",
                                     @"36",
                                     @"37",
                                     @"38",
                                     @"40",
                                     nil]];
    return dataIdDictionary;
}

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
        NSArray *dataArray = [JSON objectForKey:@"Data"];
        if(dataArray)
        {
            for( NSDictionary* dataItem in dataArray)
            {
                NSNumber *dataId = [dataItem objectForKey:@"id"];
                
                NSString *notifyStr = [NSString stringWithFormat:@"DataRx%@", [dataId stringValue]];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:notifyStr
                 object:self
                 userInfo:dataItem];
                return;
            }
        }
        
        NSArray *devList = [JSON objectForKey:@"DeviceList"];
        if(devList)
        {
            self.deviceList = devList;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DeviceListUpdated"
             object:self];
            return;
        }
        
        NSDictionary *dataList = [JSON objectForKey:@"DataList"];
        if(dataList)
        {
            NSNumber *groupId = [dataList objectForKey:@"groupId"];
            NSString *groupIdString = [groupId stringValue];
            NSArray *list = [dataList objectForKey:@"list"];
            if([list count] > 0)
            {
                NSLog(@"Data available in %@", groupIdString);
            }
            
            NSString *groupString = [[BANDGWebSocket getDataIdDictionary] valueForKey:groupIdString];
            [self.dataList setObject:dataList forKey:groupString];

            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DataListUpdated"
             object:self];
            return;
        }
        
        NSArray *dataInfoArray = [JSON objectForKey:@"DataInfo"];
        if(dataInfoArray)
        {
            for( NSDictionary* dataInfo in dataInfoArray)
            {
                NSNumber *dataId = [dataInfo objectForKey:@"id"];
                NSString *dataIdString = [dataId stringValue];
                [self.dataInfo setObject:dataInfo forKey:dataIdString];
            }
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DataInfoReceived"
             object:self];
            return;
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

- (void)requestDataList
{
    NSDictionary* dataIds = [BANDGWebSocket getDataIdDictionary];
    NSArray *keys = [dataIds allKeys];
    for(NSString* aKey in keys)
    {
        NSString *message = [NSString stringWithFormat:@"{\"DataListReq\":{\"groupId\":%@}}", aKey];
        [self.ws sendText:message];
    }
}

- (void)requestDataInfoForId:(int)dataId
{
    NSString *message = [NSString stringWithFormat:@"{\"DeviceInfoReq\":[%d]}", dataId];
    [self.ws sendText:message];
}

- (void)requestDataInfoForIds:(NSArray*)dataIds
{
    if( [dataIds count] > 0 )
    {
        NSMutableString *message = [NSMutableString stringWithCapacity:1000];
        [message appendString:@"{\"DataInfoReq\":["];
        
        int i = 0;
        NSString *idString = [dataIds[i] stringValue];
        [message appendString:[NSString stringWithFormat:@"%@", idString]];
        for( i = 1; i < [dataIds count]; i++)
        {
            idString = [dataIds[i] stringValue];
            [message appendString:[NSString stringWithFormat:@",%@", idString]];
        }
        [message appendString:@"]}"];
        [self.ws sendText:message];
    }
}


- (void)requestData:(NSString*)dataIdString subscribe:(bool)subscribe
{
    if(subscribe)
    {
        NSString *message = [NSString stringWithFormat:@"{\"DataReq\":[{\"id\":%@,\"repeat\":true}]}", dataIdString];
        
        [self.ws sendText:message];
        NSLog(@"%@", message);

    }
    else
    {
        [self.ws sendText:[NSString stringWithFormat:@"{\"DataReq\":[{\"id\":%@,\"repeat\":false}]}", dataIdString]];
    }
}

- (void)unsubscribe:(NSString*)dataIdString
{
    [self.ws sendText:[NSString stringWithFormat:@"{\"UnsubscribeData\":[{\"id\":%@}]}", dataIdString]];
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
        
        self.dataList = [[NSMutableDictionary alloc] init];
        self.dataInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
