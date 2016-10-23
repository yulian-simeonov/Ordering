//
//  UpdatesViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "UpdatesViewController.h"

#import "ORefreshTableView.h"

#import "UpdatesCell.h"
#import "MenuCell.h"

#define kHeiCell    50.0f;

@interface UpdatesViewController () {

    
}
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@end

@implementation UpdatesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onClickCheck:(id)sender {

    FSNConnection* connection = [self MakeGetMenusConnection];
    [connection start];
}

#pragma mark -
#pragma mark APICall

- (FSNConnection *) MakeGetMenusConnection {
    
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php", kBaseUrl]];
    NSLog(@"url=%@", url);
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    
    NSLog(@"%f", APPDELEGATE.currentLoc.coordinate.latitude);
    
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"menu_list", @"action",
     APPDELEGATE.curRestId, @"businessid",
     nil];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSDate* date = [NSDate date];
                      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                      
                      //Optionally for time zone converstions
                      [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                      
                      NSString *stringFromDate = [formatter stringFromDate:date];
                      
                      _lblTime.text = stringFromDate;
                      [SVProgressHUD dismiss];
                      NSLog(@"menus = %@", c.parseResult.description);
                      self.tableData = [(NSDictionary*)c.parseResult objectForKey:@"data"];
                      [self.tableView reloadData];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark -
#pragma mark Scroll View Delegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [(ORefreshTableView *)scrollView scrollViewWillBeginDragging];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [(ORefreshTableView *)scrollView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [(ORefreshTableView *)scrollView scrollViewDidEndDragging];
}

#pragma mark -
#pragma mark Refresh Table View Delegate Methods

- (void)tableViewDidTriggerRefreshHeader:(ORefreshTableView *)tableView
{
    NSLog(@"Refresh Header");
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
}

- (void)tableViewDidTriggerRefreshFooter:(ORefreshTableView *)tableView
{
    NSLog(@"Refresh Footer");
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
}

- (void) finishRefresh:(id) sender {
    
    [(ORefreshTableView *)self.tableView finishTriggerRefreshView];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeiCell;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.tableData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary* dict = (NSDictionary*) [self.tableData objectAtIndex:section];
    return [dict objectForKey:@"menu"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray*   arr = (NSArray*) [[self.tableData objectAtIndex:section] objectForKey:@"items"];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HomeCellIdentifier = @"HomeCell";
    
    MenuCell *cell = (MenuCell*)[tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        
        cell = (MenuCell*) [nib objectAtIndex:0];
    }
    cell.btnAdd.tag = indexPath.section*10926 + indexPath.row;
    cell.btnMin.tag = indexPath.section*10926 + indexPath.row;
    cell.btnPlus.tag = indexPath.section*10926 + indexPath.row;
    
    NSArray*   arr = (NSArray*) [[self.tableData objectAtIndex:indexPath.section] objectForKey:@"items"];
    NSDictionary*   dict = [arr objectAtIndex:indexPath.row];
    cell.lblName.text = [dict objectForKey:@"item"];
    cell.lblPrice.text = [NSString stringWithFormat:@"$ %@", [dict objectForKey:@"price"]];
    cell.lblQty.text = @"0";
    cell.curItem = dict;
    return (UITableViewCell*)cell;
}


@end
