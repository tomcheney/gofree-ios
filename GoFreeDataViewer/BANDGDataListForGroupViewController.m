//
//  BANDGDataListForGroupViewController.m
//  GoFreeDataViewer
//
//  Created by Tom Cheney on 08/12/2013.
//  Copyright (c) 2013 navico. All rights reserved.
//

#import "BANDGDataListForGroupViewController.h"
#import "BANDGWebSocket.h"

@interface BANDGDataListForGroupViewController ()
- (NSArray*) getListOfIds;
- (void) receiveSocketNotification:(NSNotification *) notification;
@property NSDictionary *dataInfo;
@end

@implementation BANDGDataListForGroupViewController


- (NSArray*) getListOfIds
{
    return [self.group objectForKey:@"list"];
}

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
    
    if ([[notification name] isEqualToString:@"DataInfoReceived"])
    {
        NSLog(@"DataInfoRx");
        self.dataInfo = self.ws.dataInfo;
        [self.tableView reloadData];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.group != nil)
    {
        NSNumber *groupId = [self.group objectForKey:@"groupId"];
        NSString *groupIdStr = [groupId stringValue];
        
        NSString *titleStr = [[BANDGWebSocket getDataIdDictionary] objectForKey:groupIdStr];
        [self.navigationItem setTitle:titleStr];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSocketNotification:)
                                                     name:@"DataInfoReceived"
                                                   object:nil];
        
        [self.ws requestDataInfoForIds:[self getListOfIds]];
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
    return [[self getListOfIds] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataIdEntry";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSNumber *aKey = [[self getListOfIds] objectAtIndex:indexPath.row];
    NSString *idString = [aKey stringValue];
    
    NSString *titleStr = idString;
    
    if(self.dataInfo != nil)
    {
        NSDictionary *infoForId = [self.dataInfo objectForKey:idString];
        if(infoForId != nil)
        {
            titleStr = [infoForId objectForKey:@"lname"];
        }
    }

    cell.textLabel.text = titleStr;
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
