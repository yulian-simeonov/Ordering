//
//  AppDelegate.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeViewController.h"

#import "MenuViewController.h"
#import "OrderViewController.h"
#import "UpdatesViewController.h"

#import "SplashViewController.h"


#import "TabBar.h"
#import "MGSwipeTabBarController.h"

@implementation AppDelegate

@synthesize currentLoc, arrRestaurants, arrOrder, curRestId, dictOrderCatche;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    self.arrOrder = [NSMutableArray new];
    self.dictOrderCatche = [NSMutableDictionary new];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    SplashViewController*   vcSplash = [[SplashViewController alloc] initWithNib];
    self.window.rootViewController = vcSplash;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.currentLoc = currentLocation;
    }
    [locationManager stopUpdatingLocation];
}

+ (AppDelegate*) sharedAppDelegate {
    
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

+ (void) saveRestaurants {

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];// 保存获取的access_token
    
    NSMutableArray* arrRest = [NSMutableArray new];
    for (int i=0; i<APPDELEGATE.arrRestaurants.count; i++) {
        RestaurantObj*  rest = (RestaurantObj*) [APPDELEGATE.arrRestaurants objectAtIndex:i];
        NSMutableArray*    arrMenus = [NSMutableArray new];
        for (int j=0; j<rest.arrMenus.count; j++) {
            MenuObj*    menu = (MenuObj*) [rest.arrMenus objectAtIndex:j];
            NSDictionary*   dictMenu = [NSDictionary dictionaryWithObjectsAndKeys:menu.strId, @"MenuId", menu.strMenu, @"MenuName", menu.arrItems, @"ItemsArray", nil];
            [arrMenus addObject:dictMenu];
        }
        NSDictionary*   dictRest = [NSDictionary dictionaryWithObjectsAndKeys:rest.strId, @"RestId",
                                    rest.strName, @"RestName",
                                    rest.strType, @"RestType",
                                    rest.strAddr, @"RestAddr",
                                    rest.strDist, @"RestDist",
                                    rest.strCuisine, @"RestCuisine",
                                    rest.strLogo, @"RestLogo",
                                    rest.arrMenus, @"RestArrMenus", nil];
        [arrRest addObject:dictRest];
    }
    [userDefaults setObject:arrRest forKey:@"ArrRests"];
    
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) loadRestaurants {

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];// 保存获取的access_token
    NSMutableArray*     arrRestaurants = [NSMutableArray new];
    NSArray*    arrRests = (NSArray*) [userDefaults objectForKey:@"ArrRests"];
    for (int i=0; i<arrRests.count; i++) {
        NSDictionary*   dictRest = (NSDictionary*) [arrRests objectAtIndex:i];
        NSArray*    arrMenus = (NSArray*) [dictRest objectForKey:@"RestArrMenus"];
        RestaurantObj* restObj = [RestaurantObj new];

        NSMutableArray* arr = [NSMutableArray new];
        
        for (int j=0; j<arrMenus.count; j++) {
            NSDictionary*   dictMenu = [arrMenus objectAtIndex:j];
            MenuObj*    menu = [MenuObj new];
            menu.strId = [dictMenu objectForKey:@"MenuId"];
            menu.strMenu = [dictMenu objectForKey:@"MenuName"];
            menu.arrItems = (NSArray*) [dictMenu objectForKey:@"ItemsArray"];
            [arr addObject:menu];
        }
        
        restObj.arrMenus = arr;
        restObj.strId = [dictRest objectForKey:@"RestId"];
        restObj.strName = [dictRest objectForKey:@"RestName"];
        restObj.strType = [dictRest objectForKey:@"RestType"];
        restObj.strAddr = [dictRest objectForKey:@"RestAddr"];
        restObj.strDist = [dictRest objectForKey:@"RestDist"];
        restObj.strCuisine = [dictRest objectForKey:@"RestCuisine"];
        restObj.strLogo = [dictRest objectForKey:@"RestLogo"];
        
        [arrRestaurants addObject:restObj];
    }
    APPDELEGATE.arrRestaurants = arrRestaurants;
}

- (void) didLogIn {
    
    [AppDelegate loadRestaurants];
    
    HomeViewController* vcHome = [[HomeViewController alloc] initWithNib];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vcHome];
    
//    NSArray *viewControllers = @[[[MenuViewController alloc] initWithNib],[[OrderViewController alloc] initWithNib], [[UpdatesViewController alloc] initWithNib]];
//    TabBar *tabBar = [[TabBar alloc] initWithNib];
//    MGSwipeTabBarController *tabController = [[MGSwipeTabBarController alloc] initWithViewControllers:viewControllers tabBar:tabBar];
//    [tabController.tabBar setSelectedIndex:0];
//    
//    CGRect frame = tabController.view.frame;
//
//    tabController.view.frame = frame;
//    
//    [self.window addSubview:tabController.view];;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
