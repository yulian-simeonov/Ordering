//
//  MenuViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "MenuViewController.h"

#import "ORefreshTableView.h"

#import "MenuCell.h"

#define kHeiCell    80

@interface MenuViewController () {

    
}

@end

@implementation MenuViewController

@synthesize restObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    FSNConnection* connection = [self MakeGetMenusConnection];
    [connection start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
     self.restObj.strId, @"businessid",
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
                      
                      [SVProgressHUD dismiss];
                      NSLog(@"menus = %@", c.parseResult.description);
                      self.tableData = [(NSDictionary*)c.parseResult objectForKey:@"data"];
                      [self.tableView reloadData];
                      
                      [APPDELEGATE.arrOrder removeAllObjects];
                      
                      for (int i=0; i<self.tableData.count; i++) {
                          NSArray*   arrItems = [[self.tableData objectAtIndex:i] objectForKey:@"items"];
                          for (int j=0; j<arrItems.count; j++) {
                              NSDictionary*   dict = [arrItems objectAtIndex:j];
                              NSLog(@"%@", arrItems);
                              NSLog(@"%@, %@", [dict objectForKey:@"id"], [APPDELEGATE.dictOrderCatche objectForKey:[dict objectForKey:@"id"]]);
                              if ([APPDELEGATE.dictOrderCatche objectForKey:[dict objectForKey:@"id"]] != nil) {
                                  NSMutableDictionary*    dict1 = [NSMutableDictionary dictionaryWithDictionary:dict];
                                  [dict1 setObject:[NSNumber numberWithInt:[[APPDELEGATE.dictOrderCatche objectForKey:[dict objectForKey:@"id"]] intValue]] forKey:@"qty"];
                                  [APPDELEGATE.arrOrder addObject:dict1];
                              }
                          }
                      }
                      
                      [self finishRefresh:nil];
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
    FSNConnection* connection = [self MakeGetMenusConnection];
    [connection start];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
}

- (void)tableViewDidTriggerRefreshFooter:(ORefreshTableView *)tableView
{
    FSNConnection* connection = [self MakeGetMenusConnection];
    [connection start];
    NSLog(@"Refresh Footer");
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
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
    
    [cell.btnAdd addTarget:self action:@selector(onClickAdd:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnMin addTarget:self action:@selector(onClickMin:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnPlus addTarget:self action:@selector(onClickPlus:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray*   arr = (NSArray*) [[self.tableData objectAtIndex:indexPath.section] objectForKey:@"items"];
    NSDictionary*   dict = [arr objectAtIndex:arr.count - indexPath.row - 1];
    cell.lblName.text = [dict objectForKey:@"item"];
    cell.lblPrice.text = [NSString stringWithFormat:@"$ %@", [dict objectForKey:@"price"]];
    if ([APPDELEGATE.dictOrderCatche objectForKey:[dict objectForKey:@"id"]] != nil)
        cell.lblQty.text = [NSString stringWithFormat:@"%@", [APPDELEGATE.dictOrderCatche objectForKey:[dict objectForKey:@"id"]]];
    else
        cell.lblQty.text = @"0";
    cell.curItem = dict;
    return (UITableViewCell*)cell;
}


- (void) onClickPlus:(UIButton*)sender {
    
    MenuCell* menuCell = (MenuCell*)sender.superview.superview.superview;
    
    int qty = [menuCell.lblQty.text intValue];

    menuCell.lblQty.text = [NSString stringWithFormat:@"%d", qty+1];
}

- (void) onClickMin:(UIButton*)sender {
    
    MenuCell* menuCell = (MenuCell*)sender.superview.superview.superview;
    
    int qty = [menuCell.lblQty.text intValue];
    if (qty > 0) {
        menuCell.lblQty.text = [NSString stringWithFormat:@"%d", qty-1];
    }
}

- (void) onClickAdd:(UIButton*)sender {
    
    MenuCell* menuCell = (MenuCell*)sender.superview.superview.superview;
    int qty = [menuCell.lblQty.text intValue];
    if (qty == 0) {
        [Utilities showMsg:@"This item has 0 Quantity. It should be more than 1."];
        return;
    }
    NSMutableDictionary*    dict = [NSMutableDictionary dictionaryWithDictionary:menuCell.curItem];
    [dict setObject:[NSNumber numberWithInt:qty] forKey:@"qty"];
    [APPDELEGATE.dictOrderCatche setObject:[NSNumber numberWithInt:qty] forKey:[menuCell.curItem objectForKey:@"id"]];
    
    bool isExist = NO;
    for (int i=0; i<APPDELEGATE.arrOrder.count; i++) {
        NSDictionary*   dict1 = [APPDELEGATE.arrOrder objectAtIndex:i];
        if ([[dict1 objectForKey:@"id"] isEqualToString:[menuCell.curItem objectForKey:@"id"]]) {
            [APPDELEGATE.arrOrder replaceObjectAtIndex:i withObject:dict];
            isExist = YES;
            break;
        }
    }
    if (!isExist)
        [APPDELEGATE.arrOrder addObject:dict];
    
    [SVProgressHUD showSuccessWithStatus:@"Successfully Added"];
}

@end
