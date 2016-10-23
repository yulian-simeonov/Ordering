//
//  OrderViewController.h
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTextViewController.h"
#import "RestaurantViewController.h"

@interface OrderViewController : OTextViewController

@property (nonatomic, strong) RestaurantViewController* vcParent;

@end
