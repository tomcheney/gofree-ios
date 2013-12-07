//
//  BANDGDeviceTableViewController.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 03/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "BANDGDeviceTableViewController.h"
#import "BANDGServiceForDeviceViewController.h"
#import "BANDGGoFreeService.h"
#import "GCDAsyncUdpSocket.h"

@interface BANDGDeviceTableViewController ()
@property NSMutableDictionary *devices;
@property BANDGGoFreeService *selectedDevice;
@property GCDAsyncUdpSocket *udpSocket;
- (void)setupMulticastListener;
@end

@implementation BANDGDeviceTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.devices = [[NSMutableDictionary alloc] init];
    [self setupMulticastListener];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.devices allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *keys = [self.devices allKeys];
    id aKey = [keys objectAtIndex:indexPath.row];
    
    BANDGGoFreeService *device = [self.devices objectForKey:aKey];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", device.Model, device.Name];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ShowServicesForDevice"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *keys = [self.devices allKeys];
        id aKey = [keys objectAtIndex:indexPath.row];
        
        self.selectedDevice = [self.devices objectForKey:aKey];
        
        // Get reference to the destination view controller
        BANDGServiceForDeviceViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.device = self.selectedDevice;
    }
}


- (void)setupMulticastListener
{
    // Constants.m
    NSString *const cGroupAddress = @"239.2.1.1";
    uint16_t const cGroupPort = 2052;
    
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![self.udpSocket bindToPort:cGroupPort error:&error])
    {
        NSLog(@"Error binding to port: %@", error);
        return;
    }
    if(![self.udpSocket joinMulticastGroup:cGroupAddress error:&error]){
        NSLog(@"Error connecting to multicast group: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"UDP Socket Ready");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		//NSLog(@"Did receive message: %@", msg);
        NSError *e = nil;
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [msg dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
        
        NSString *name = [JSON valueForKey:@"Name"];
        //NSLog(@"Name: %@", name);
        
        NSString *ip = [JSON valueForKey:@"IP"];
        //NSLog(@"IP: %@", ip);
        
        NSString *model = [JSON valueForKey:@"Model"];
        //NSLog(@"Model: %@", model);
        
        //NSArray *services = [JSON objectForKey: @"Services"];
        //for ( NSDictionary *service in services )
        //{
            //NSLog(@"Service: %@", service[@"Service"] );
            //NSLog(@"Version: %@", service[@"Version"] );
            //NSLog(@"Port: %@", service[@"Port"] );
        //}
        
        if( !self.devices[ip] )
        {
            BANDGGoFreeService *device = [[BANDGGoFreeService alloc] init];
            device.Name = name;
            device.IP = ip;
            device.Model = model;
            [self.devices setObject:device forKey:ip];
            [self.tableView reloadData];
        }
        //NSUInteger keyCount = [[self.devices allKeys] count];
        //NSLog(@"Devices: %d", keyCount );
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		NSLog(@"Unknown message from: %@:%hu", host, port);
		//[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
	}
}

@end
