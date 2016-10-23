//
//  AppDelegate.h
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {

    CLLocationManager *locationManager;
}

@property (strong, nonatomic)   UIWindow *window;
@property (nonatomic, strong)   CLLocation*   currentLoc;
@property (nonatomic, strong)   NSArray*      arrRestaurants;
@property (nonatomic, strong)   NSMutableArray* arrOrder;
@property (nonatomic, strong)   NSString*   curRestId;
@property (nonatomic, strong)   NSMutableDictionary*        dictOrderCatche;

+ (AppDelegate*) sharedAppDelegate;

- (void) didLogIn;

@end
