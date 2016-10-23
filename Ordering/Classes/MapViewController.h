//
//  MapViewController.h
//  STVNGR
//
//  Created by TianFu on 9/29/13.
//  Copyright (c) 2013 TianFu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OViewController.h"

@interface MapViewController : OViewController

@property (nonatomic, strong) NSMutableArray*       arrPosts;

- (void) onSetLocation;

@end
