//
//  BANDGDataDisplayViewController.h
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 08/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BANDGWebSocket.h"

@interface BANDGDataDisplayViewController : UIViewController
@property BANDGWebSocket *ws;
@property NSDictionary *infoForDataId;
@end
