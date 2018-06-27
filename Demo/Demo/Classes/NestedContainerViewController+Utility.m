//
//  NestedContainerViewController+Utility.m
//  Demo
//
//  Created by YXLONG on 2018/6/27.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "NestedContainerViewController+Utility.h"
#import "Masonry.h"


@implementation PagerBarHeaderView
- (instancetype)initWithFrame:(CGRect)frame itemsTitles:(NSArray *)itemsTitles
{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = [UIColor lightTextColor];
        
        _pageBarView = [[XIPageBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) , CGRectGetHeight(frame))];
        _pageBarView.autoAdjustItemWidthIfNeeded = YES;
        _pageBarView.contentInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        _pageBarView.backgroundColor = [UIColor clearColor];
        _pageBarView.indicatorColor = [UIColor redColor];
        _pageBarView.adjustIndicatorWidthAsTitle = true;
        _pageBarView.itemTitleColorForNormal = [UIColor darkTextColor];
        _pageBarView.itemTitleColorForSelected = [UIColor redColor];
        _pageBarView.itemSpace = 15;
        _pageBarView.selectedIndex = 0;
        _pageBarView.titleColorTransitionSupported = YES;
        __weak typeof(self) wk_self = self;
        [_pageBarView setDidSelectItemAtIndex:^(XIPageBarView *view, NSUInteger index) {
            if([wk_self.delegate respondsToSelector:@selector(pageBarViewDidChange:)]){
                [wk_self.delegate pageBarViewDidChange:index];
            }
        }];
        [self addSubview:_pageBarView];
        _pageBarView.barItemTitles = itemsTitles;
        
        UIView *hairlineView = [[UIView alloc] initWithFrame:CGRectZero];
        hairlineView.backgroundColor = [UIColor lightGrayColor];
        [self insertSubview:hairlineView atIndex:0];
        [hairlineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.and.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)setBarSelectedIndex:(NSInteger)barSelectedIndex
{
    _pageBarView.selectedIndex = barSelectedIndex;
}
@end


@implementation PageContainerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
               viewController:(UIViewController *)viewController
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _pageContainerView = [[XIPageContainerView alloc] initWithFrame:self.contentView.bounds
                                                         viewController:viewController];
        _pageContainerView.animatedSwitch = YES;
        _pageContainerView.backgroundColor = [UIColor whiteColor];
        _pageContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_pageContainerView];
        
        __weak typeof(self) wk_self = self;
        [_pageContainerView setNumberOfPages:^NSInteger{
            
            return [wk_self.delegate numberOfPages];;
        }];
        
        [_pageContainerView setPageAtIndex:^UIViewController *(NSUInteger index){
            
            return [wk_self.delegate pageControllerAtIndex:index];
        }];
        
//        [_pageContainerView setWillDisplayPageAtIndex:^(NSInteger oldIndex, UIViewController *pageWillDisappear){
//            if(pageWillDisappear){
//                [wk_self.delegate viewControllerWillDisappear:pageWillDisappear];
//                [pageWillDisappear viewWillDisappear:YES];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [pageWillDisappear viewDidDisappear:YES];
//                });
//            }
//        }];
//
//        [_pageContainerView setDidDisplayPageAtIndex:^(NSInteger newIndex, UIViewController *pageDidAppear){
//            if(pageDidAppear){
//                [wk_self.delegate viewControllerWillAppear:pageDidAppear];
//                [pageDidAppear viewWillAppear:YES];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [pageDidAppear viewDidAppear:YES];
//                });
//            }
//        }];
//
//        [_pageContainerView setSelectedIndexDidChange:^(NSInteger index){
//            [wk_self.delegate showPageAtIndex:index];
//        }];
    }
    return self;
}

- (void)setDelegate:(id<PageContainerCellDelegate>)delegate
{
    _delegate = delegate;
    [_pageContainerView reloadData];
}
@end
