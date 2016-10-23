//
//  MoreViewController.m
//  Ordering
//
//  Created by Yulian on 12/6/13.
//  Copyright (c) 2013 Yulian. All rights reserved.
//

#import "MoreViewController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface MoreViewController ()

@end

@implementation MoreViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickFacebook:(id)sender {
    
    [self facebook];
}
- (IBAction)onClickTwitter:(id)sender {
    
    [self twitt];
}

- (void) twitt {
    
    SLComposeViewController *mySocialComposer;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        mySocialComposer = [SLComposeViewController
                            composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySocialComposer setInitialText:@"Ordering!"];
//        [mySocialComposer addURL:[NSURL URLWithString:@""]];
//        [mySocialComposer addImage:((OImageView *)[self.view viewWithTag:kTagImageView_Image]).image];
        [self presentViewController:mySocialComposer animated:YES completion:nil];
        
        [mySocialComposer setCompletionHandler:^(SLComposeViewControllerResult result){
            NSString *outout = [[NSString alloc] init];
            
            switch (result) {
                case SLComposeViewControllerResultCancelled: {
                    outout = @"Failed";
                }
                    break;
                case SLComposeViewControllerResultDone: {
                    outout = @"Posted Successfully";
                }
                default:
                    break;
            }
            UIAlertView *myalertView = [[UIAlertView alloc]initWithTitle:@"Twitter"
                                                                 message:outout delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [myalertView show];
        }];
    }
    else{
        NSLog(@"UnAvailable");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Account" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)facebook {
    
    SLComposeViewController *mySocialComposer;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        mySocialComposer = [SLComposeViewController
                            composeViewControllerForServiceType:SLServiceTypeFacebook];
//        [mySocialComposer setTitle:[NSString stringWithFormat:@"via %@", kTitle_StyledFriend]];
        [mySocialComposer setInitialText:@"Ordering!"];
        [mySocialComposer addURL:[NSURL URLWithString:@""]];
//        [mySocialComposer addImage:((OImageView *)[self.view viewWithTag:kTagImageView_Image]).image];
        [self presentViewController:mySocialComposer animated:YES completion:nil];
        
        
        [mySocialComposer setCompletionHandler:^(SLComposeViewControllerResult result){
            NSString *outout = [[NSString alloc] init];
            
            switch (result) {
                case SLComposeViewControllerResultCancelled: {
                    outout = @"Failed";
                }
                    break;
                case SLComposeViewControllerResultDone: {
                    outout = @"Posted Successfully";
                }
                default:
                    break;
            }
            UIAlertView *myalertView = [[UIAlertView alloc]initWithTitle:@"FaceBook"
                                                                 message:outout delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [myalertView show];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

@end
