//
//  SplashViewController.m
//  OnTab
//
//  Created by Yulian on 11/19/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController () {

    IBOutlet UIImageView*   ivSplash;
}

@end

@implementation SplashViewController

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
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onCompletionAnim:) userInfo:nil repeats:NO];
}

- (void) onCompletionAnim:(id)sender {
    
    [APPDELEGATE didLogIn];
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    NSMutableArray*     arr = [[NSMutableArray alloc] init];
    for (int i=0; i<20; i++) {
        NSString* strName = [NSString stringWithFormat:@"splash_%d", i+1];
        [arr addObject:[UIImage imageNamed:strName]];
    }
    ivSplash.animationImages = arr;
    ivSplash.animationDuration = 1.0;
    ivSplash.animationRepeatCount = 3;
    [ivSplash startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
