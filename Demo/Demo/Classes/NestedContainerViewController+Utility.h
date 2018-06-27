//
//  NestedContainerViewController+Utility.h
//  Demo
//
//  Created by YXLONG on 2018/6/27.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "NestedContainerViewController.h"
#import "XIPageBarView.h"
#import "XIPageContainerView.h"


@protocol PagerContainerViewControllerChildController <NSObject>
@property(nonatomic, assign) BOOL canScroll;
@property(nonatomic, weak) NestedContainerViewController *containerVC;
@end


@protocol PagerBarHeaderViewDelegate <NSObject>
- (void)pageBarViewDidChange:(NSInteger)newSelectedIndex;
@end

@interface PagerBarHeaderView : UIView
@property(nonatomic, strong) XIPageBarView *pageBarView;
@property(nonatomic, weak) id<PagerBarHeaderViewDelegate> delegate;
@property(nonatomic, assign) NSInteger barSelectedIndex;

- (instancetype)initWithFrame:(CGRect)frame itemsTitles:(NSArray *)itemsTitles;
@end



@protocol PageContainerCellDelegate <NSObject>
///页面个数
- (NSInteger)numberOfPages;
///页面展示
- (UIViewController *)pageControllerAtIndex:(NSInteger)index;

@optional
///页面切换触发
- (void)showPageAtIndex:(NSInteger)index;

- (void)viewControllerWillDisappear:(UIViewController *)viewController;
- (void)viewControllerWillAppear:(UIViewController *)viewController;
@end

@interface PageContainerCell : UITableViewCell
@property(nonatomic, weak) id<PageContainerCellDelegate> delegate;
@property(nonatomic, strong) XIPageContainerView *pageContainerView;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
               viewController:(UIViewController *)viewController;
@end
