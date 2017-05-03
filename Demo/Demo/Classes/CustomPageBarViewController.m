//
//  CustomPageBarViewController.m
//  Demo
//
//  Created by YXLONG on 16/6/30.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "CustomPageBarViewController.h"
#import "CustomPageBarView.h"
#import "XIPageBar.h"
#import "Masonry.h"
#import "UIColor+Random.h"

@implementation CustomPageBarViewController
{
    XIPageContainerView *containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self prepareViews];
}

- (void)prepareViews
{
    CGFloat top  = 64;
    CustomPageBarView *pageBarView = [[CustomPageBarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    pageBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pageBarView];
    [pageBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(top);
        make.height.mas_equalTo(@(44));
    }];
    [pageBarView setDidSelectItemAtIndex:^(NSUInteger index) {
        if(containerView){
            containerView.selectedIndex = index;
        }
    }];
    
    top += 44;
    
    if(!containerView){
        containerView = [[XIPageContainerView alloc] initWithViewController:self];
        containerView.frame = CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height-top);
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        containerView.customTabBar = pageBarView;
        [self.view addSubview:containerView];
        
        [containerView setNumberOfPages:^NSInteger{
            return 3;
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
}

@end
