//
//  BANDGGoFreeService.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 03/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "BANDGGoFreeService.h"

@implementation BANDGGoFreeService

- (BOOL)isValid{
    return (self.Name && self.IP && self.Model);
}

@end
