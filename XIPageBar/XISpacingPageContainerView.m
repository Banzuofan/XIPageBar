//
//  XISpacingPageContainerView.m
//
//  Created by YXLONG on 2016/11/26.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "XISpacingPageContainerView.h"

@interface _UIPagingScrollViewCell : UICollectionViewCell

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface XISpacingPageContainerView ()<XICardFlowViewDelegate>
{
    NSMutableArray *totalViews;
    NSMutableArray *totalViewControllers;
}
@property(nonatomic, weak) UIViewController *viewController;
@end

@implementation XISpacingPageContainerView

- (instancetype)initWithViewController:(UIViewController *)viewController
                     preferredPageSize:(CGSize)preferredPageSize
                    preferredPageCount:(NSInteger)preferredPageCount
                            pageMargin:(CGFloat)pageMargin
{
    self = [self initWithFrame:CGRectZero];
    if(self){
        
        self.viewController = viewController;
        self.viewController.automaticallyAdjustsScrollViewInsets = NO;
        
        totalViews = @[].mutableCopy;
        totalViewControllers = @[].mutableCopy;
        
        _pagingScrollView = [[XICardFlowView alloc] initWithFrame:CGRectMake(0, 0, preferredPageSize.width, preferredPageSize.height)];
        _pagingScrollView.itemSize = preferredPageSize;
        _pagingScrollView.itemSpace = pageMargin;
        _pagingScrollView.invisibleViewMinAlphaValue = 1;
        _pagingScrollView.invisibleViewMinScaleValue = 1;
        _pagingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _pagingScrollView.wrappedDelegate = self;
        [self addSubview:_pagingScrollView];
        
        if(preferredPageCount<=0){
            [_pagingScrollView registerClass:[_UIPagingScrollViewCell class] forCellWithReuseIdentifier:@"ReusedCell"];
        }
        else{
            for(int i=0;i<preferredPageCount;i++){
                [_pagingScrollView registerClass:[_UIPagingScrollViewCell class] forCellWithReuseIdentifier:[NSString stringWithFormat:@"ReusedCell%@", @(i)]];
            }
        }
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    if(self.customTabBar){
        [self.customTabBar setSelectedIndex:index];
    }
    
    if(index==_pagingScrollView.currentPageIndex){
        return;
    }
    
    if(index<totalViews.count){
        [_pagingScrollView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                          animated:YES];
    }
}

- (void)reloadData
{
    if(totalViewControllers>0){
        for(UIViewController *vc in totalViewControllers){
            [vc willMoveToParentViewController:nil];
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
    
    if(totalViews.count>0){
        [totalViews removeAllObjects];
    }
    
    [self.pagingScrollView reloadData];
    
    NSInteger count = _numberOfPages? _numberOfPages(): 0;
    if(count>0){
        for(int i=0;i<count;i++){
            [totalViews addObject:[NSNull null]];
            [totalViewControllers addObject:[NSNull null]];
        }
    }
    
    [self.pagingScrollView reloadData];
    
    [self setSelectedIndex:0 animated:NO];
}

- (NSInteger)numberOfCardsForCardFlowView:(XICardFlowView *)flowView
{
    return totalViews.count;
}

- (UICollectionViewCell *)cardFlowView:(XICardFlowView *)flowView cardViewAtIndexPath:(NSIndexPath *)indexPath
{
    _UIPagingScrollViewCell *cell = [flowView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"ReusedCell%@", @(indexPath.row)] forIndexPath:indexPath];
    
    UIView *subView = [cell.contentView viewWithTag:999];
    if(!subView){
        subView = [self findPageAtIndex:indexPath.row];
        subView.tag = 999;
        [cell.contentView addSubview:subView];
    }
    return cell;
}

- (UIView *)findPageAtIndex:(NSInteger)pageIndex
{
    UIView *v = [totalViews objectAtIndex:pageIndex];
    if(v && ![v isKindOfClass:[NSNull class]]){
        return v;
    }
    
    if(totalViewControllers.count>0 && ![totalViewControllers[pageIndex] isKindOfClass:[NSNull class]]){
        
        UIViewController *pageVc = totalViewControllers[pageIndex];
        return pageVc.view;
    }
    else{
        id page = _pageAtIndex? _pageAtIndex(pageIndex) : nil;
        NSAssert(page!=nil, @"the 'page' must be assigned");
        if([page isKindOfClass:[UIViewController class]]){
            UIViewController *pageVc = (UIViewController *)page;
            [totalViewControllers replaceObjectAtIndex:pageIndex withObject:pageVc];
            
            NSParameterAssert(_viewController!=nil);
            [_viewController addChildViewController:pageVc];
            
            v = pageVc.view;
        }
        else{
            v = (UIView *)page;
            [totalViews replaceObjectAtIndex:pageIndex withObject:v];
        }
    }
    return v;
}

- (void)cardFlowView:(XICardFlowView *)flowView centeredIndexWillChange:(NSInteger)newCenteredIndex
{
    if(self.customTabBar){
        [self.customTabBar setSelectedIndex:newCenteredIndex];
    }
}

- (void)cardFlowView:(XICardFlowView *)flowView didSelectFromIndex:(NSInteger)from to:(NSInteger)to
{
    NSLog(@"%s, (from: %@ - to: %@ )",  __FUNCTION__, @(from), @(to));
    if(totalViewControllers.count==0){
        return;
    }
    
    if(from<totalViewControllers.count){
        
        UIViewController *vc = totalViewControllers[from];
        if([vc isKindOfClass:[UIViewController class]]){
            [vc viewWillDisappear:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc viewDidDisappear:YES];
            });
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(to<totalViewControllers.count){
            UIViewController *vc = totalViewControllers[to];
            if([vc isKindOfClass:[UIViewController class]]){
                [vc viewWillAppear:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [vc viewDidAppear:YES];
                });
            }
        }
    });
    
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation _UIPagingScrollViewCell


@end
