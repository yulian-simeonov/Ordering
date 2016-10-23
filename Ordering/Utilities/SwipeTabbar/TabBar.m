//
//  TabBar.m
//  SwipeTabBarController
//
//  Created by Mark Glagola on 12/15/12.
//  Copyright (c) 2012 Mark Glagola. All rights reserved.
//

#import "TabBar.h"

@implementation TabBar

- (void) setSelectedIndex:(NSUInteger)selectedIndex {
    
    UIButton *selectedButton = (UIButton*)[self viewWithTag:selectedIndex];
    NSLog(@"%@, frame=%@", [selectedButton class], NSStringFromCGRect(selectedButton.frame));
    CGRect sFrame = selectedView.frame;
    sFrame.origin.x = selectedButton.frame.origin.x;
    selectedView.frame = sFrame;
    
//    NSArray*    arrSel      = @[@"tabitem_feed_h", @"tabitem_create_h", @"tabitem_msg_h"];
//    NSArray*    arrUnSel    = @[@"tabitem_feed", @"tabitem_create", @"tabitem_msg"];
//    
    for (UIButton* btn in [self subviews]) {
        if ([btn isKindOfClass:[UIButton class]]) {
            long i = [btn tag];
            if (i == selectedIndex) {
//                [btn setImage:[UIImage imageNamed:[arrSel objectAtIndex:i]] forState:UIControlStateNormal];
                CGRect sFrame = selectedView.frame;
                sFrame.origin.x = btn.frame.origin.x;
                selectedView.frame = sFrame;
            }
//            else {
//                [btn setImage:[UIImage imageNamed:[arrUnSel objectAtIndex:i]] forState:UIControlStateNormal];
//            }
        }
    }
    
    [super setSelectedIndex:selectedIndex];
}

- (IBAction)viewButtonPressed:(UIButton*)sender {
    if (sender.tag == 4) {
        [self.delegate swipeTabBarDidSelectIndex:sender.tag];
    } else {
        self.selectedIndex = sender.tag; //set in IB
    }
}

@end
