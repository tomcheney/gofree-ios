//
//  BANDGDataListForGroupViewController.h
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 08/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BANDGWebSocket.h"

@interface BANDGDataListForGroupViewController : UITableViewController
@property NSDictionary *group;
@property BANDGWebSocket *ws;
@end
