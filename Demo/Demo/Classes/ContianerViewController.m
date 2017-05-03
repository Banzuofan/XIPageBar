//
//  ContianerViewController.m
//  Demo
//
//  Created by YXLONG on 2017/5/2.
//  Copyright © 2017年 XIPageBar. All rights reserved.
//

#import "ContianerViewController.h"
#import "XIPageBar.h"
#import "Masonry.h"
#import "XIPageBarUtility.h"
#import "UIColor+Random.h"

@interface ContianerViewController ()
{
    XIPageContainerView *containerView;
    XIPageBarView *pagerBarView;
}
@end

@implementation ContianerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    pagerBarView = [[XIPageBarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    pagerBarView.backgroundColor = [UIColor whiteColor];
    pagerBarView.adjustIndicatorWidthAsTitle = YES;
    pagerBarView.contentInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    pagerBarView.autoAdjustItemWidthIfNeeded = YES;
    pagerBarView.itemTitleColorForNormal = [UIColor blackColor];
    pagerBarView.itemTitleColorForSelected = [UIColor redColor];
    pagerBarView.indicatorColor = [UIColor redColor];
    [self.view addSubview:pagerBarView];
    
    WEAKSELF
    [pagerBarView setDidSelectItemAtIndex:^(XIPageBarView *pagebar, NSUInteger index) {
        ContianerViewController *strongSelf = weakSelf;
        if(strongSelf->containerView){
            strongSelf->containerView.selectedIndex = index;
        }
    }];
    pagerBarView.barItemTitles = @[@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"];
//    pagerBarView.barItemTitles = @[@"Spring",@"Summer",@"Autumn",@"Winter"];
    
    NSInteger total = pagerBarView.barItemTitles.count;
    
    containerView = [[XIPageContainerView alloc] initWithViewController:self];
    containerView.frame = CGRectMake(0, CGRectGetMaxY(pagerBarView.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(pagerBarView.frame));
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    containerView.customTabBar = pagerBarView;
    [self.view addSubview:containerView];
    
    [containerView setNumberOfPages:^NSInteger{
        return total;
    }];
    [containerView setPageAtIndex:^UIViewController *(NSUInteger index) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor randomColor];
        return vc;
    }];
    [containerView setWillDisplayPageAtIndex:^(NSInteger oldIndex, UIViewController *pageWillDisappear) {
        if([pageWillDisappear isViewLoaded]){
            [pageWillDisappear viewWillDisappear:NO];
            [pageWillDisappear viewDidDisappear:NO];
        }
    }];
    [containerView setDidDisplayPageAtIndex:^(NSInteger newIndex, UIViewController *pageDidAppear) {
        if([pageDidAppear isViewLoaded]){
            [pageDidAppear viewWillAppear:NO];
            [pageDidAppear viewDidAppear:NO];
        }
    }];
    [containerView reloadData];
}

@end
