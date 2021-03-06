//
//  BANDGServiceForDeviceViewController.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 04/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

//Views
#import "BANDGServiceForDeviceViewController.h"
#import "BANDGDataListForGroupViewController.h"

//Data
#import "BANDGGoFreeService.h"
#import "BANDGWebSocket.h"

@interface BANDGServiceForDeviceViewController ()
@property NSArray *services;
@property NSMutableDictionary *dataList;
@property BANDGWebSocket *ws;
- (void) receiveSocketNotification:(NSNotification *) notification;
@end

@implementation BANDGServiceForDeviceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    if ([[notification name] isEqualToString:@"SocketOpen"])
    {
        [self.ws requestDeviceList];
        [self.ws requestDataList];
    }
    
    if ([[notification name] isEqualToString:@"DeviceListUpdated"])
    {
        self.services = self.ws.deviceList;
        [self.tableView reloadData];
    }
    
    if ([[notification name] isEqualToString:@"DataListUpdated"])
    {
        self.dataList = self.ws.dataList;
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.device != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSocketNotification:)
                                                     name:@"SocketOpen"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSocketNotification:)
                                                     name:@"DeviceListUpdated"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSocketNotification:)
                                                     name:@"DataListUpdated"
                                                   object:nil];
        
        NSString* address = [NSString stringWithFormat:@"ws://%@:2053", self.device.IP];
        self.ws = [[BANDGWebSocket alloc] init:address];
        [self.ws startMyWebSocket];
    }

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( self.dataList != nil)
    {
        return [[self.dataList allKeys] count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"deviceEntry";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
    // Sort group names alphabetically
    NSArray *sortedKeys = [[self.dataList allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    //NSArray *keys = [self.dataList allKeys];
    NSString *aKey = [sortedKeys objectAtIndex:indexPath.row];
    
    NSDictionary *group = [self.dataList valueForKey:aKey];
    NSArray *list = [group valueForKey:@"list"];
    NSString *detailText = [NSString stringWithFormat:@"%d", [list count]];
    cell.textLabel.text = aKey;
    cell.detailTextLabel.text = detailText;
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ShowDataForGroup"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //NSArray *keys = [self.dataList allKeys];
        //NSString *aKey = [keys objectAtIndex:indexPath.row];
        
        // Sort group names alphabetically
        NSArray *sortedKeys = [[self.dataList allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSString *aKey = [sortedKeys objectAtIndex:indexPath.row];
        
        NSDictionary *group = [self.dataList valueForKey:aKey];
        
        // Get reference to the destination view controller
        BANDGDataListForGroupViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.group = group;
        vc.ws = self.ws;
    }
}

@end
