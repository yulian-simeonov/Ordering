//
//  HomeViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "HomeViewController.h"
#import "MapViewController.h"
#import "HomeCell.h"
#import "RestaurantViewController.h"



#define kHeiCell    50.0f

#define kTagLabel_Name          100
#define kTagLabel_Cuisine       101
#define kTagLabel_Dist          102
#define kTagBtn_Pin             103

#define kTagBtn_Cuisine         109

@interface HomeViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {

    IBOutlet UIPickerView*  pkCuisine;
    IBOutlet UIView*        vCuisine;
    NSMutableArray*         mArrCuisine;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"NEARBY RESTAURANTS";
        [self setRightBarButtonString:@"Updates"];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    FSNConnection* connection = [self MakeGetRestaurantsConnection:@""];
    [connection start];
    
    FSNConnection* connection1 = [self MakeGetCuisineConnection];
    [connection1 start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView reloadData];
    
    mArrCuisine = [[NSMutableArray alloc] initWithObjects:@"Chinese", @"Italian", @"Thai", @"Indian", @"Australian", @"Lebaunes", @"All", nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark APICall

- (FSNConnection *) MakeGetRestaurantsConnection:(NSString*)strCuisine {
    
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php", kBaseUrl]];
    NSLog(@"url=%@", url);
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    
    NSLog(@"%f", APPDELEGATE.currentLoc.coordinate.latitude);
    
    NSDictionary *parameters;
    if ([strCuisine isEqualToString:@""]) {
        parameters =     [NSDictionary dictionaryWithObjectsAndKeys:
                          @"search_resturants", @"action",
                          [NSString stringWithFormat:@"%f", APPDELEGATE.currentLoc.coordinate.latitude],               @"lat",
                          [NSString stringWithFormat:@"%f", APPDELEGATE.currentLoc.coordinate.latitude],               @"lon",
                          @"10000000",               @"distance",
                          
                          nil];

    } else {
        parameters =     [NSDictionary dictionaryWithObjectsAndKeys:
                          @"search_resturants", @"action",
                          [NSString stringWithFormat:@"%f", APPDELEGATE.currentLoc.coordinate.latitude],               @"lat",
                          [NSString stringWithFormat:@"%f", APPDELEGATE.currentLoc.coordinate.latitude],               @"lon",
                          @"10000000",               @"distance",
                          strCuisine, @"cuisine",
                          
                          nil];
    }
    
    NSLog(@"url = %@", url);
    
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
                      
                      [self finishRefresh:nil];
                      [SVProgressHUD dismiss];
                      NSLog(@"url = %@, restaurants = %@", c.url, c.parseResult.description);
                      NSArray* arrRests = (NSArray*) [(NSDictionary*) c.parseResult objectForKey:@"data"];
                      
                      [self.tableData removeAllObjects];
                      
                      for (int i=0; i<arrRests.count; i++) {
                          NSDictionary* dict = (NSDictionary*) [arrRests objectAtIndex:i];
                          RestaurantObj*    restObj = [RestaurantObj convertDictToRestObj:dict];
                          [self.tableData addObject:restObj];
                      }
                      [self.tableView reloadData];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) MakeGetCuisineConnection {
    
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php", kBaseUrl]];
    NSLog(@"url=%@", url);
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    
    NSLog(@"%f", APPDELEGATE.currentLoc.coordinate.latitude);
    
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"cusine_list", @"action",
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
                      NSLog(@"restaurants = %@", c.parseResult.description);
                      NSArray* arr = [(NSDictionary*)c.parseResult objectForKey:@"data"];
                      [mArrCuisine removeAllObjects];
                      
                      for (int i=0; i<arr.count; i++) {
                          NSDictionary* dict = (NSDictionary*) [arr objectAtIndex:i];
                          [mArrCuisine addObject:[dict objectForKey:@"cuisine"]];
                      }
                      [mArrCuisine addObject:@"All"];
                      
                      [pkCuisine reloadAllComponents];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark -
#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [mArrCuisine objectAtIndex:row];
}



#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [mArrCuisine count];
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
    FSNConnection* connection = [self MakeGetRestaurantsConnection:@""];
    [connection start];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
}

- (void)tableViewDidTriggerRefreshFooter:(ORefreshTableView *)tableView
{
    FSNConnection* connection = [self MakeGetRestaurantsConnection:@""];
    [connection start];
    NSLog(@"Refresh Footer");
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishRefresh:) userInfo:nil repeats:NO];
}

- (void) finishRefresh:(id) sender {

    [(ORefreshTableView *)self.tableView finishTriggerRefreshView];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeiCell;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [APPDELEGATE.arrOrder removeAllObjects];
    
    RestaurantViewController*   vcRestaurant = [[RestaurantViewController alloc] initWithNib];
    vcRestaurant.restObj = (RestaurantObj*) [self.tableData objectAtIndex:indexPath.row];
    APPDELEGATE.curRestId = vcRestaurant.restObj.strId;
    [self.navigationController pushViewController:vcRestaurant animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HomeCellIdentifier = @"HomeCell";
    
    HomeCell *cell = (HomeCell*)[tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];

        cell = (HomeCell*) [nib objectAtIndex:0];
    }
    
    RestaurantObj*   restObj = (RestaurantObj*) [self.tableData objectAtIndex:indexPath.row];

    UILabel*    lblName = (UILabel*) [cell viewWithTag:kTagLabel_Name];
    lblName.text = restObj.strName;
    
    UILabel*    lblCui = (UILabel*) [cell viewWithTag:kTagLabel_Cuisine];
    lblCui.text = restObj.strCuisine;
    
    UILabel*    lblDist = (UILabel*) [cell viewWithTag:kTagLabel_Dist];
    lblDist.text = [NSString stringWithFormat:@"%d km", [restObj.strDist intValue]];
    
    UIButton*   btnTag = (UIButton*) [cell viewWithTag:kTagBtn_Pin];
    [btnTag addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return (UITableViewCell*)cell;
}


#pragma mark -
#pragma mark OActionDelegate Methods

- (IBAction) onClickDone:(id)sender {

    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = vCuisine.frame;
        frame.origin.y = SCRN_HEIGHT;
        vCuisine.frame = frame;
    }];
    
    NSString* strCui = [mArrCuisine objectAtIndex:[pkCuisine selectedRowInComponent:0]];
    if ([strCui isEqualToString:@"All"])
        strCui = @"";
    FSNConnection* connection = [self MakeGetRestaurantsConnection:strCui];
    [connection start];
}

- (void)pressedButton:(id)sender
{
    int tag = (int) [sender tag];
    switch (tag) {
        case kLeftBarButtonItem: {
        }   break;
        case kRightBarButtonItem: {
        }
            break;
        case kTagBtn_Pin: {
            MapViewController*  vcMap = [[MapViewController alloc] initWithNib];
            vcMap.arrPosts = self.tableData;
            [self.navigationController pushViewController:vcMap animated:YES];
        }
            break;
        case kTagBtn_Cuisine: {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame = vCuisine.frame;
                if (frame.origin.y == SCRN_HEIGHT) {
                    frame.origin.y = SCRN_HEIGHT-frame.size.height-64;
                    vCuisine.frame = frame;
                }
            }];
        }
            break;
    }
}

@end
