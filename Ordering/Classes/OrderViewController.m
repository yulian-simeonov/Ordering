//
//  OrderViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "OrderViewController.h"
#import "MoreViewController.h"
#import "ORefreshTableView.h"

#import "OrderCell.h"

#define kHeiCell    44

@interface OrderViewController () <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate> {

    NSMutableArray*     arrOrders;
    int mCurIdx;
}
@property (weak, nonatomic) IBOutlet ORefreshTableView *tblOrder;
@property (weak, nonatomic) IBOutlet UITextField *tfTblnum;
@property (weak, nonatomic) IBOutlet UITextView *tvComment;
@property (weak, nonatomic) IBOutlet UITextField *tfCoupon;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalPrice;

@end

@implementation OrderViewController

@synthesize vcParent, tblOrder;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedNotification:) name:@"OnTabOrder" object:nil];
    
    [self.scrollView setContentSize:CGSizeMake(320.0f, self.view.frame.size.height+1)];
    
    
}

- (void) onReceivedNotification:(NSNotification*)    noti {

    NSLog(@"Tabbed Order");
    arrOrders = [NSMutableArray arrayWithArray:APPDELEGATE.arrOrder];
    [self.tblOrder reloadData];
    
    _lblTotalPrice.text = [NSString stringWithFormat:@"$ %.01f", [self getTotalPrice]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark APICall
- (FSNConnection *) MakeUploadingOrderConnection {
    
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php", kBaseUrl]];
    NSLog(@"url=%@", url);
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    
    NSLog(@"%f", APPDELEGATE.currentLoc.coordinate.latitude);
    NSMutableArray*  arrItems = [NSMutableArray new];
    for (int i=0; i<arrOrders.count; i++) {
        NSDictionary*   dict = [arrOrders objectAtIndex:i];
        NSString*   str = [NSString stringWithFormat:@"%@:%@", [dict objectForKey:@"id"], [dict objectForKey:@"qty"]];
        [arrItems addObject:str];
    }
    NSString*  strItems = [arrItems componentsJoinedByString:@","];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"upload_order", @"action",
     _tfTblnum.text, @"tableNum",
     _tvComment.text, @"comment",
     strItems, @"items",
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
                      
                      [SVProgressHUD dismiss];
                      NSLog(@"restaurants = %@", c.parseResult.description);
                      
                      int success = [[(NSDictionary*)c.parseResult objectForKey:@"success"] intValue];
                      if (success == 1) {
                          [Utilities showMsg:@"Successfully Ordered"];
//                          [arrOrders removeAllObjects];
//                          [APPDELEGATE.arrOrder removeAllObjects];
//                          _tfTblnum.text = @"";
//                          _tvComment.text = @"";
                          
                          
                          MoreViewController* vcMore = [MoreViewController new];
                          [self.vcParent.navigationController pushViewController:vcMore animated:YES];
                      } else {
                          [Utilities showMsg:[(NSDictionary*)c.parseResult objectForKey:@"msg"]];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark -
#pragma mark UIButtonActionDelegate

- (void) onClickDel:(UIButton*) sender {

    int idx = (int) [sender tag];
    mCurIdx = idx;
    UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:@"Do you want to delete this order?" message:nil delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [alert show];
}



- (IBAction) onClickConfirm:(id)sender {

    if (arrOrders.count == 0) {
        [Utilities showMsg:@"Add items first"];
        return;
    }
    if (![Utilities isValidString:_tfTblnum.text]) {
        [Utilities showMsg:@"Input the table number!"];
        return;
    }
//    if (![Utilities isValidString:_tvComment.text]) {
//        [Utilities showMsg:@"Input the Comment!"];
//        return;
//    }
    [_tfTblnum resignFirstResponder];
    [_tfCoupon resignFirstResponder];
    [_tvComment resignFirstResponder];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    FSNConnection* connection = [self MakeUploadingOrderConnection];
    [connection start];
}

- (float) getTotalPrice {

    float totalPrice = 0.0f;
    for (int i=0; i<arrOrders.count; i++) {
        NSDictionary*   dict = (NSDictionary*) [arrOrders objectAtIndex:i];
        int qty = [[dict objectForKey:@"qty"] intValue];
        float price = [[dict objectForKey:@"price"] floatValue];
        totalPrice += qty*price;
    }
    return totalPrice;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [arrOrders removeObjectAtIndex:mCurIdx];
        [APPDELEGATE.arrOrder removeObjectAtIndex:mCurIdx];
        [self.tblOrder reloadData];
        
        _lblTotalPrice.text = [NSString stringWithFormat:@"$ %.01f", [self getTotalPrice]];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -250;
        self.view.frame = frame;
    }];
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -250;
        self.view.frame = frame;
    }];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:self options:nil];
//    
//    return (UIView*) [nib objectAtIndex:1];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    return 30.0f;
//}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrOrders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HomeCellIdentifier = @"OrderCell";
    
    OrderCell *cell = (OrderCell*)[tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:self options:nil];
        
        cell = (OrderCell*) [nib objectAtIndex:0];
    }
    NSDictionary*   dict = (NSDictionary*) [arrOrders objectAtIndex:indexPath.row];
    int qty = [[dict objectForKey:@"qty"] intValue];
    float price = [[dict objectForKey:@"price"] floatValue];
    cell.lblQty.text = [NSString stringWithFormat:@"%d", qty];
    cell.lblName.text = [dict objectForKey:@"item"];
    cell.lblPrice.text = [NSString stringWithFormat:@"$ %.02f", qty*price];
    cell.btnDel.tag = indexPath.row;
    [cell.btnDel addTarget:self action:@selector(onClickDel:) forControlEvents:UIControlEventTouchUpInside];
    return (UITableViewCell*)cell;
}


@end
