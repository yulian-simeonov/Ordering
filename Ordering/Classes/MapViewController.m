//
//  MapViewController.m
//  STVNGR
//
//  Created by TianFu on 9/29/13.
//  Copyright (c) 2013 TianFu. All rights reserved.
//

#import "MapViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlaceMark.h"
#import "RestaurantViewController.h"
#import "UIImageView+Cached.h"



@interface MapViewController () <UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate> {

    IBOutlet UIView*        viewMapCnt;
    IBOutlet UISearchBar*   mySearchbar;
    NSMutableArray*     mArrCnt;
    MKMapView *mMapView;
}
                
@end

@implementation MapViewController

@synthesize arrPosts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = kTitle_MAP;
        [self setLeftBarButtonImage:@"btn_back"];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
//    [APPDELEGATE.leveyTabBarController hidesTabBar:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mArrCnt = [NSMutableArray arrayWithArray:self.arrPosts];
    
    mMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0, viewMapCnt.frame.size.width, viewMapCnt.frame.size.height)];
	mMapView.showsUserLocation = NO;
	mMapView.scrollEnabled = YES;
	mMapView.zoomEnabled = YES;
	mMapView.delegate = self;
	NSArray * annotations = [mMapView annotations];
	[mMapView removeAnnotations:annotations];
    //	[self showUserLocation];
	
	[viewMapCnt insertSubview:mMapView atIndex:0];
    
    [self onSetLocation];
}

/* ----------- Place Detail ---------------
created = "2013-11-04 08:45:48";
description = "This is second Place";
id = 4;
latitude = "40.129788";
longitude = "124.394313";
photo = "http://50.22.168.74/DontEatAlone/api/data/place/666-208729220-201106101834492221_1_large.jpg";
title = "Second Place";
udpated = "<null>";
user =             {
    avatar = "http://50.22.168.74/DontEatAlone/api/data/profile/229-161067781--100534175-365-165468340-avatar.jpeg";
    email = "jianbong@bong.com";
    latitude = "40.129788";
    longitude = "124.384700";
    username = Jian;
};
---------------------------------------------*/

- (void) onSetLocation {
    
    [mMapView removeAnnotations:mMapView.annotations];
    
    NSMutableArray* pins = [[NSMutableArray alloc] init];
    
    for (int i=0; i<mArrCnt.count; i++) {
        RestaurantObj* restObj = (RestaurantObj*) [mArrCnt objectAtIndex:i];
        float lat = [restObj.strLat floatValue];
        float lng = [restObj.strLng floatValue];
        NSString* strWhere = restObj.strName;

        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
        PlaceMark *ann = [[PlaceMark alloc] initWithCoordinate:center];
        ann.index = i;
        ann.strThumbUrl = restObj.strLogo;
        ann.line1 = strWhere;
        [pins addObject:ann];
    }
    
    [self performSelectorOnMainThread:@selector(addAnnotationToMapView:) withObject:pins waitUntilDone:NO];
}

- (void) addAnnotationToMapView:(NSArray *)pins
{
    for (int i=0; i<pins.count; i++)
        [mMapView addAnnotation:[pins objectAtIndex:i]];
	
	[self fitToPinsRegion];
}

- (void) fitToPinsRegion
{
	if ([mMapView.annotations count] == 0)
	{
		return;
	}
	
	//NSLog(@"[map] user loc: %.1f %.1f", userLocationCoordinate.latitude, userLocationCoordinate.longitude);
	
	PlaceMark *firstMark = [mMapView.annotations objectAtIndex: 0];
	
	CLLocationCoordinate2D topLeftCoord = firstMark.coordinate;
	CLLocationCoordinate2D bottomRightCoord = firstMark.coordinate;
	
	for(PlaceMark *item in mMapView.annotations)
	{
		if (item.coordinate.latitude < topLeftCoord.latitude)
		{
			topLeftCoord.latitude = item.coordinate.latitude;
		}
		
		if (item.coordinate.longitude > topLeftCoord.longitude)
		{
			topLeftCoord.longitude = item.coordinate.longitude;
		}
		
		if (item.coordinate.latitude > bottomRightCoord.latitude)
		{
			bottomRightCoord.latitude = item.coordinate.latitude;
		}
		
		if (item.coordinate.longitude < bottomRightCoord.longitude)
		{
			bottomRightCoord.longitude = item.coordinate.longitude;
		}
	}
	
    //	if (mHasUserLocation)
    //	{
    //		topLeftCoord.latitude = fmin(topLeftCoord.latitude, mUserLocation.latitude);
    //		topLeftCoord.longitude = fmax(topLeftCoord.longitude, mUserLocation.longitude);
    //
    //		bottomRightCoord.latitude = fmax(bottomRightCoord.latitude, mUserLocation.latitude);
    //		bottomRightCoord.longitude = fmin(bottomRightCoord.longitude, mUserLocation.longitude);
    //	}
	
	MKCoordinateRegion region;
	region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude)/2.0;
	region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude)/2.0;
	region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
	
	if (region.span.latitudeDelta < 0.01)
	{
		region.span.latitudeDelta = 0.01;
	}
	if (region.span.longitudeDelta < 0.01)
	{
		region.span.longitudeDelta = 0.01;
	}
	
	NSLog(@"region: (%.2f,%.2f) %.1fx%.1f", topLeftCoord.latitude, topLeftCoord.longitude,
		  region.span.latitudeDelta, region.span.longitudeDelta);
	
	region = [mMapView regionThatFits:region];
	[mMapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark MkMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(PlaceMark *)annotation
{
    static NSString *PinIdentifier = @"PinIdentifier";
    if ([annotation isKindOfClass:[PlaceMark class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mMapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
          
            NSString*   strCate;
            strCate = @"pin_beef";
            annotationView.image = [UIImage imageNamed:strCate];
			annotationView.canShowCallout = YES;
            annotationView.enabled = YES;
            
        }
        
        if (annotation.strThumbUrl != nil)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            OImageView *imageView = (OImageView*) [[OImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            
            [imageView setImageWithUrl:annotation.strThumbUrl defaultImage:[UIImage imageNamed:@"image2@2x.jpg"]];
            imageView.backgroundColor = [UIColor clearColor];
            [button addSubview:imageView];
            annotationView.leftCalloutAccessoryView = button;
        }
        
        
        UIView *description = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 185, 32)];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor darkGrayColor];
        label1.font = [UIFont fontWithName:@"Arial-BoldMT" size:13];
        label1.text = [NSString stringWithFormat:@"%@", annotation.line1];
        [description addSubview:label1];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btn.frame = CGRectMake(155, 0, 30, 30);
        btn.tag = annotation.index;
        [btn addTarget:self action:@selector(onClickGo:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:annotation.title forState:UIControlStateNormal];
        [description addSubview:btn];
        
        annotationView.rightCalloutAccessoryView = description;
        return annotationView;
	}
	return nil;
}

- (void) onClickGo:(id) sender {
    
    int idx = [sender tag];
    RestaurantViewController*   vcRestaurant = [[RestaurantViewController alloc] initWithNib];
    vcRestaurant.restObj = (RestaurantObj*) [self.arrPosts objectAtIndex:idx];
    APPDELEGATE.curRestId = vcRestaurant.restObj.strId;
    [self.navigationController pushViewController:vcRestaurant animated:YES];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *action = (__bridge NSString*)context;
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)object;
	if (annotationView.pinColor != MKPinAnnotationColorGreen)
	{
		PlaceMark *pin = (PlaceMark *)annotationView.annotation;
		
		if ([action isEqualToString:@"ANSELECTED"])
		{
			BOOL annotationSelected = [[change valueForKey:@"new"] boolValue];
			if (annotationSelected)
			{
				if (pin.strThumbUrl == nil)
				{
//					[NSThread detachNewThreadSelector:@selector(getThumbImage:) toTarget:self withObject:annotationView];
				}
			}
			else
			{
				// Annotation deselected
			}
		}
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"tapped!");
//	PlaceMark *pin = (PlaceMark *)view.annotation;
    //	if ( pin.item )
    //	{
    //		DetailedPropertyViewController* detailViewController = [[DetailedPropertyViewController alloc]
    //																initWithProperty: pin.item
    //																isRent: pin.item.isRent];
    //		[self.navigationController pushViewController:detailViewController animated:YES];
    //		[detailViewController release];
    //	}
}

- (void) showUserLocation
{
	CLLocation* userLoc = mMapView.userLocation.location;
	CLLocationCoordinate2D userCoord = userLoc.coordinate;
	PlaceMark *pin = [[PlaceMark alloc] initWithCoordinate: userCoord];
	[mMapView addAnnotation: pin];
}

#pragma mark- UISearchbarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [searchBar resignFirstResponder];
    
    [mArrCnt removeAllObjects];
    if ([searchBar.text isEqualToString:@""]) {
        [mArrCnt addObjectsFromArray:self.arrPosts];
    } else {
        for (int i=0; i<self.arrPosts.count; i++) {
            NSDictionary* dict = (NSDictionary*) [self.arrPosts objectAtIndex:i];
            NSRange subStrRange = [[dict objectForKey:@"Name"]  rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if (subStrRange.location != NSNotFound) {
                [mArrCnt addObject:dict];
            }
        }
    }
    [self onSetLocation];
}

@end
