//
//  RestaurantObj.m
//  Ordering
//
//  Created by Yulian on 12/14/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "RestaurantObj.h"

@implementation RestaurantObj

@synthesize strAddr, strCuisine, strDist, strId, strLogo, strType, arrMenus, strLat, strLng, strName;

+ (RestaurantObj*) convertDictToRestObj:(NSDictionary*)dict {

    RestaurantObj* restObj = [RestaurantObj new];
    restObj.strId = [dict objectForKey:@"id"];
    restObj.strName = [dict objectForKey:@"businessName"];
    restObj.strType = [dict objectForKey:@"businessType"];
    restObj.strAddr = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"businessAddress1"], [dict objectForKey:@"businessAddress2"]];
    restObj.strCuisine = [dict objectForKey:@"cuisine"];
    restObj.strDist = [dict objectForKey:@"distance"];
    restObj.strLogo = [dict objectForKey:@"businessLogo"];
    restObj.strLat = [dict objectForKey:@"latitude"];
    restObj.strLng = [dict objectForKey:@"longitude"];
    return restObj;
}

@end
