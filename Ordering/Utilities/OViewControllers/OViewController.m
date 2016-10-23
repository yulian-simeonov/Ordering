//
//  OViewController.m
//  StyledFriend
//
//  Created by Jungrak Lee on 8/16/12.
//  Copyright (c) 2012 orfeostory, inc. All rights reserved.
//

#import "OViewController.h"

@interface OViewController ()

@end

@implementation OViewController

@synthesize delegate = _delegate;
@synthesize leftBarButtonImage = _leftBarButtonImage;
@synthesize rightBarButtonImage = _rightBarButtonImage;
@synthesize rightBarButtonString = _rightBarButtonString;
@synthesize leftBarButtonString = _leftBarButtonString;
@synthesize isModal = _isModal;
@synthesize bundle = _bundle;

- (void)setLeftBarButtonImage:(NSString *)leftBarButtonImage
{
    self.navigationItem.hidesBackButton = YES;

    _leftBarButtonImage = leftBarButtonImage;
        
    UIImage *norImage = [UIImage imageNamed:[_leftBarButtonImage stringByAppendingString:@""]];
//    UIImage *highImage = [UIImage imageNamed:[_leftBarButtonImage stringByAppendingString:@"_high"]];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, norImage.size.width, norImage.size.height)];
    button.tag = kLeftBarButtonItem;
    
    [button setImage:norImage forState:UIControlStateNormal];
//    [button setImage:highImage forState:UIControlStateHighlighted];

    [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setLeftBarButtonString:(NSString *)leftBarButtonImage
{
    self.navigationItem.hidesBackButton = YES;
    
    _leftBarButtonImage = leftBarButtonImage;
    
    UIFont* font = [UIFont systemFontOfSize:20.0f];
    CGSize size = [leftBarButtonImage sizeWithFont:font
                                      forWidth:320.0
                                 lineBreakMode:NSLineBreakByClipping];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [button setTitleColor:[UIColor colorWithRed:148/255.0f green:231/255.0f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
    button.tag = kLeftBarButtonItem;
    
    [button setTitle:leftBarButtonImage forState:UIControlStateNormal];
    //    [button setImage:highImage forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setRightBarButtonImage:(NSString *)rightBarButtonImage
{
    _rightBarButtonImage = rightBarButtonImage;

    UIImage *norImage = [UIImage imageNamed:[_rightBarButtonImage stringByAppendingString:@""]];
//    UIImage *highImage = [UIImage imageNamed:[_rightBarButtonImage stringByAppendingString:@"_high"]];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, norImage.size.width, norImage.size.height)];
    button.tag = kRightBarButtonItem;
    
    [button setImage:norImage forState:UIControlStateNormal];
//    [button setImage:highImage forState:UIControlStateHighlighted];

    [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setRightBarButtonString:(NSString *)rightBarButton
{
    UIFont* font = [UIFont systemFontOfSize:20.0f];
    CGSize size = [rightBarButton sizeWithFont:font
                                  forWidth:320.0
                             lineBreakMode:NSLineBreakByClipping];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, self.navigationController.navigationBar.frame.size.height)];
    [button setTitle:rightBarButton forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:148/255.0f green:231/255.0f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
    button.tag = kRightBarButtonItem;
    [button setTitleColor:[UIColor colorWithRed:13/255.0f green:180/255.0f blue:228/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    //    [button setImage:highImage forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.scrollForHideNavigation){
        float topInset = self.navigationController.navigationBar.frame.size.height;
        
        self.scrollForHideNavigation.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    }
    
    if (self.navigationItem != nil) {
        if (self.title.length > 0) {
            UILabel *label = [[UILabel alloc] init];
            label.text = self.title;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
            [label setTextAlignment:NSTextAlignmentCenter];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            
            [label sizeToFit];

            self.navigationItem.titleView = label;
        }
    }
}

#pragma mark
#pragma Navigation hide Scroll

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    isDecelerating = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isDecelerating = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.scrollForHideNavigation != scrollView)
        return;
    if(scrollView.frame.size.height >= scrollView.contentSize.height)
        return;
    
    if(scrollView.contentOffset.y > -self.navigationController.navigationBar.frame.size.height && scrollView.contentOffset.y < 0)
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    else if(scrollView.contentOffset.y >= 0)
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if(lastOffsetY < scrollView.contentOffset.y && scrollView.contentOffset.y >= -self.navigationController.navigationBar.frame.size.height){//moving up
        
        if(self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y  > 0){//not yet hidden
            float newY = self.navigationController.navigationBar.frame.origin.y - (scrollView.contentOffset.y - lastOffsetY);
            if(newY < -self.navigationController.navigationBar.frame.size.height)
                newY = -self.navigationController.navigationBar.frame.size.height;
            self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,
                                                                       newY,
                                                                       self.navigationController.navigationBar.frame.size.width,
                                                                       self.navigationController.navigationBar.frame.size.height);
        }
    }else
        if(self.navigationController.navigationBar.frame.origin.y < [UIApplication sharedApplication].statusBarFrame.size.height  &&
           (self.scrollForHideNavigation.contentSize.height > self.scrollForHideNavigation.contentOffset.y + self.scrollForHideNavigation.frame.size.height)){//not yet shown
            float newY = self.navigationController.navigationBar.frame.origin.y + (lastOffsetY - scrollView.contentOffset.y);
            if(newY > [UIApplication sharedApplication].statusBarFrame.size.height)
                newY = [UIApplication sharedApplication].statusBarFrame.size.height;
            self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,
                                                                       newY,
                                                                       self.navigationController.navigationBar.frame.size.width,
                                                                       self.navigationController.navigationBar.frame.size.height);
        }
    
    lastOffsetY = scrollView.contentOffset.y;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.bundle = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController != nil) {
        if (self.title != nil) {
            self.navigationController.navigationBarHidden = NO;
            
            if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] == YES) {
                [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forBarMetrics:UIBarMetricsDefault];
            }
            
            if (self.navigationController.childViewControllers.count > 1) {
//                self.leftBarButtonImage = [OUtils chineseButtonName:@"titlebar_btn_back"];
            } else if (self.isModal == YES) {
//                self.rightBarButtonImage = [OUtils chineseButtonName:@"titlebar_btn_cancel"];
            }
        } else {
            self.navigationController.navigationBarHidden = YES;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (IBAction)pressedButton:(id)sender
{
    NSInteger tag = ((UIView *) sender).tag;
    
    switch (tag) {
        case kLeftBarButtonItem: {
            if (self.navigationController.childViewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }   break;
        case kRightBarButtonItem:
            if (self.navigationController.childViewControllers.count == 1 && self.isModal == YES) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
    }
}

//#pragma mark -
//#pragma mark HTTP Client Delegate Methods
//- (void)httpClient:(OHttpClient *)httpClient didExecuteWithResult:(NSDictionary *)result
//{
//    NSString *error = [result objectForKey:@"error"];
//    
//    if (error != nil) {
//        [OAlertView showWithTitle:kTitle_Error message:error buttonTitle:kText_OKay];
//    }
//}
//
//- (void)httpClient:(OHttpClient *)httpClient didFailWithError:(NSError *)error
//{
//    if (httpClient.synchronized == YES) {
//        [OAlertView showWithTitle:kTitle_Error message:kMessage_NetworkFailed buttonTitle:kText_OKay];
//    }
//}

@end
