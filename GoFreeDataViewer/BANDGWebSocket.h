//
//  BANDGWebSocket.h
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 01/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "WebSocket.h"
#import <Foundation/Foundation.h>

@interface BANDGWebSocket : NSObject <WebSocketDelegate>
{
@private
    WebSocket* ws;
}

@property (nonatomic, readonly) WebSocket* ws;
@property NSArray *deviceList;
- (id)init:(NSString*)address;

- (void) startMyWebSocket;

- (void) sendMessage:(NSString*)message;
- (void) requestDeviceList;

@end