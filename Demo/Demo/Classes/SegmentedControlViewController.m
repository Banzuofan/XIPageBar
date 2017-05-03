//
//  SegmentedControlViewController.m
//  Demo
//
//  Created by YXLONG on 16/6/30.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "SegmentedControlViewController.h"
#import "CustomPageBarView.h"
#import "XIPageBar.h"
#import "Masonry.h"
#import "UIColor+Random.h"

@interface UISegmentedControl (XIPage)
- (void)setSelectedIndex:(NSInteger)index;
- (NSInteger)selectedIndex;
@end

@implementation UISegmentedControl (XIPage)
- (void)setSelectedIndex:(NSInteger)index
{
    self.selectedSegmentIndex = index;
}
- (NSInteger)selectedIndex
{
    return self.selectedSegmentIndex;
}
@end

@implementation SegmentedControlViewController
{
    XIPageContainerView *containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareViews];
}

- (void)prepareViews
{
    CGFloat top  = 10;
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"Red", @"Green", @"Blue"]];
    segControl.backgroundColor = [UIColor whiteColor];
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segControl];
    [segControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.top.equalTo(self.view).with.offset(top);
        make.height.mas_equalTo(@(34));
    }];
    
    top += 44;
    
    if(!containerView){
        containerView = [[XIPageContainerView alloc] initWithViewController:self];
        containerView.frame = CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height-top);
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        containerView.customTabBar = (id<XICustomBarConfigurations>)segControl;
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

- (void)valueChanged:(UISegmentedControl *)control
{
    if(containerView){
        containerView.selectedIndex = control.selectedSegmentIndex;
    }
}

@end
