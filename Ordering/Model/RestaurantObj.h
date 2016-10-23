//
//  RestaurantObj.h
//  Ordering
//
//  Created by Yulian on 12/14/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantObj : NSObject

@property (nonatomic, strong) NSString*     strId;
@property (nonatomic, strong) NSString*     strName;
@property (nonatomic, strong) NSString*     strType;
@property (nonatomic, strong) NSString*     strAddr;
@property (nonatomic, strong) NSString*     strDist;
@property (nonatomic, strong) NSString*     strCuisine;
@property (nonatomic, strong) NSString*     strLogo;
@property (nonatomic, strong) NSString*     strLat;
@property (nonatomic, strong) NSString*     strLng;
@property (nonatomic, strong) NSArray*      arrMenus;

+ (RestaurantObj*) convertDictToRestObj:(NSDictionary*)dict;

@end
