//
//  BANDGGoFreeService.h
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 03/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BANDGGoFreeService : NSObject

@property NSString *Name;
@property NSString *IP;
@property NSString *Model;
- (BOOL)isValid;

@end
