//
//  RestaurantViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "RestaurantViewController.h"

#import "MenuViewController.h"
#import "OrderViewController.h"
#import "UpdatesViewController.h"
#import "TabBar.h"

@interface RestaurantViewController () <MGSwipeTabBarControllerDelegate> {

    IBOutlet UIView*    vCnt;
}

@end

@implementation RestaurantViewController

@synthesize restObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setHidesBackButton:YES];
        [self setRightBarButtonString:@"Logo"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.restObj.strName;

    
    OrderViewController*    vcOrder = [OrderViewController new];
    vcOrder.vcParent = self;
    
    MenuViewController*     vcMenu = [MenuViewController new];
    vcMenu.restObj = self.restObj;
    
//    UpdatesViewController*  vcUpdates = [UpdatesViewController new];
    
    NSArray *viewControllers = @[vcMenu,vcOrder];
    TabBar *tabBar = [[TabBar alloc] initWithNib];
    MGSwipeTabBarController *tabController = [[MGSwipeTabBarController alloc] initWithViewControllers:viewControllers tabBar:tabBar];
    tabController.delegate = self;
    [tabController.tabBar setSelectedIndex:0];
    CGRect frame = tabController.view.frame;
    tabController.view.frame = frame;
    [vCnt addSubview:tabController.view];
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
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark -
#pragma mark MGSwipeTabBarControllerDelegate

- (void) swipeTabBarDidSelectIndex:(NSUInteger)selectedIndex {
    
    if (selectedIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnTabOrder" object:nil];
    } else if (selectedIndex == 4) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
