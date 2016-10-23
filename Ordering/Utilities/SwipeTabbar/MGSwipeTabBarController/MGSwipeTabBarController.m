//
//  MGSwipeTabBarController.m
//  SwipeTabBarController
//
//  Created by Mark Glagola on 12/15/12.
//  Copyright (c) 2012 Mark Glagola. All rights reserved.
//

#import "MGSwipeTabBarController.h"
#import "UIViewController+MGSwipeTabBarController.h"

@interface MGSwipeTabBarController ()
@end

@implementation MGSwipeTabBarController

@synthesize viewControllers = _viewControllers, selectedIndex = _selectedIndex, tabBar = _tabBar;

- (void) initScrollView {
    if (!self.scrollView) {
        
        CGRect scrollframe = self.view.frame;
        if (self.tabBar) {
            CGRect tabBarFrame = self.tabBar.frame;
            scrollframe.size.height -= tabBarFrame.size.height;
            if (tabBarPosition == MGTabBarPositionTop) {
                scrollframe.origin.y = tabBarFrame.size.height;
            }else {
                tabBarFrame.origin.y += scrollframe.size.height;
                _tabBar.frame = tabBarFrame;
            }
        }
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:scrollframe];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(self.viewControllers.count * scrollframe.size.width, scrollframe.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex >= self.viewControllers.count)
        return;
    
    //don't want to animate to index - just go straight there
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * selectedIndex;
    [self.scrollView scrollRectToVisible:frame animated:NO];
    
    _selectedIndex = selectedIndex;
}

- (id) initWithViewControllers:(NSArray*)viewControllers {
    return [self initWithViewControllers:viewControllers tabBar:nil];
}

- (id) initWithViewControllers:(NSArray*)viewControllers tabBar:(MGSwipeTabBar*)tabBar {
    return [self initWithViewControllers:viewControllers tabBar:tabBar atPosition:MGTabBarPositionTop];
}

- (id) initWithViewControllers:(NSArray*)viewControllers tabBar:(MGSwipeTabBar*)tabBar atPosition:(MGTabBarPosition)position
{
    if (self = [super init]) {
        _viewControllers = viewControllers;
        tabBarPosition = position;
        _tabBar = tabBar;
        _tabBar.delegate = self;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self initScrollView];
    [self.view addSubview: self.scrollView];
    
    if (self.tabBar){
        [self.view addSubview:self.tabBar];
    }
    
    for (UIViewController *controller in self.viewControllers) {
        controller.swipeTabBarController = self;
        [_scrollView addSubview:controller.view];
        [self addChildViewController:controller];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    for (UIViewController *controller in self.viewControllers) {
        NSUInteger index = [self.viewControllers indexOfObject:controller];
        CGRect frame = controller.view.frame;
        frame.origin.x = self.view.frame.size.width * index;
        controller.view.frame = frame;
    }
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
    if (_selectedIndex != index) {
        _selectedIndex = index;
        self.tabBar.selectedIndex = _selectedIndex;
    }
}


#pragma mark - MGSwipeTabBarDelegate methods
- (void) swipeTabBarDidSelectIndex:(NSUInteger)selectedIndex {
    
    if (selectedIndex != 4)
        self.selectedIndex = selectedIndex;
    [_scrollView setContentOffset: CGPointMake(selectedIndex*320, 0) animated: YES];
    NSLog(@"ContentOffset - %@", NSStringFromCGPoint(_scrollView.contentOffset));
    [self.delegate swipeTabBarDidSelectIndex:selectedIndex];
}
@end
