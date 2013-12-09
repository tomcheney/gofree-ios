//
//  BANDGDataDisplayViewController.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 08/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "BANDGDataDisplayViewController.h"

@interface BANDGDataDisplayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
- (void) receiveSocketNotification:(NSNotification *) notification;
@end

@implementation BANDGDataDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) receiveSocketNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    NSLog(@"DataRx");
    NSDictionary *rxData = [notification userInfo];
    NSString *valid = [NSString stringWithFormat:@"%@",[rxData objectForKey:@"valid"]];
    
    if( self.valueLabel == nil ) {
        NSLog(@"Null label");
    }
    
    NSString *unitStr = [self.infoForDataId objectForKey:@"unit"];
    if([[NSString stringWithString:unitStr] isEqualToString:@"&deg;"])
    {
        unitStr = @"\u00B0";
    }
    
    NSString *labelText;
    if([valid isEqualToString:@"1"])
    {
        NSString *valueStr = [rxData objectForKey:@"valStr"];
        NSLog(@"Val = %@",valueStr);
        labelText = [NSString stringWithString:valueStr];
    }
    else
    {
        labelText = @"---";
    }
    
    labelText = [NSString stringWithFormat:@"%@%@",labelText, unitStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.valueLabel setText:labelText];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if((self.infoForDataId != nil) && (self.ws != nil))
    {
        NSString *titleStr = [self.infoForDataId objectForKey:@"sname"];
        [self.navigationItem setTitle:titleStr];
        
        NSNumber *dataId = [self.infoForDataId objectForKey:@"id"];
        NSString *dataIdStr = [dataId stringValue];
        
        NSString *notifyStr = [NSString stringWithFormat:@"DataRx%@", dataIdStr];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSocketNotification:)
                                                     name:notifyStr
                                                   object:nil];
        
        [self.ws requestData:dataIdStr subscribe:true];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if((self.infoForDataId != nil) && (self.ws != nil))
    {
        NSNumber *dataId = [self.infoForDataId objectForKey:@"id"];
        NSString *dataIdStr = [dataId stringValue];
        NSString *notifyStr = [NSString stringWithFormat:@"DataRx%@", dataIdStr];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notifyStr object:nil];
        
        [self.ws unsubscribe:dataIdStr];
    }
}

@end
