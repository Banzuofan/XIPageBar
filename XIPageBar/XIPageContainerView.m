//
//  XIPageContainerView.m
//  XIPagedView
//
//  Created by YXLONG on 16/5/17.
//  Copyright © 2016年 jdstock. All rights reserved.
//

#import "XIPageContainerView.h"

@interface XIPageContainerView ()<UIScrollViewDelegate>
@property(nonatomic, weak) UIViewController *viewController;
- (void)clearPages;
- (BOOL)isViewDidLoadAtIndex:(NSInteger)index;
- (void)setupPageAtIndex:(NSUInteger)index;
@end

@implementation XIPageContainerView
{
    UIScrollView *contentView;
    NSMutableArray *pageControllers;
    BOOL scrollByDragging;
    
    CGFloat _scrollWidth;
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    if(self=[self initWithFrame:CGRectZero viewController:viewController]){
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [self initWithFrame:frame];
    if(self){
        self.viewController = viewController;
        self.viewController.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];
        pageControllers = [NSMutableArray array];
        scrollByDragging = NO;
        _contentInsets = UIEdgeInsetsZero;
        _pageMargin = 0;
        
        contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        contentView.delegate = self;
        contentView.pagingEnabled = YES;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.bounces = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentView];
    }
    return self;
}

- (UIScrollView *)scrollView
{
    return contentView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self updatePageLayouts];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    
    [self updatePageLayouts];
}

- (void)setPageMargin:(CGFloat)pageMargin
{
    _pageMargin = pageMargin;
    
    [self updatePageLayouts];
}

- (void)updatePageLayouts
{
    CGFloat _width = CGRectGetWidth(self.frame);
    CGFloat _height = CGRectGetHeight(self.frame);
    _scrollWidth = _width+_pageMargin;
    
    CGRect r = contentView.frame;
    r.origin.y = _contentInsets.top;
    r.size.width = _width + _pageMargin;
    r.size.height = _height - _contentInsets.top - _contentInsets.bottom;
    contentView.frame = r;
    
    [contentView setContentSize:CGSizeMake(_scrollWidth*_pageCount, _height)];
    
    for(int i=0;i<pageControllers.count;i++){
        UIViewController *vc = pageControllers[i];
        if([vc isKindOfClass:[UIViewController class]]){
            CGRect rect = vc.view.frame;
            rect.origin.x = _scrollWidth*i;
            rect.size.width = _width;
            vc.view.frame = rect;
        }
    }
    
    
    
    [contentView setContentOffset:CGPointMake(_selectedIndex*_scrollWidth, 0) animated:NO];
}

- (CGPoint)contentOffset
{
    return contentView.contentOffset;
}

- (void)clearPages
{
    for(id elem in self.viewController.childViewControllers){
        if([elem isKindOfClass:[UIViewController class]]){
            UIViewController *vc = (UIViewController *)elem;
            [vc willMoveToParentViewController:nil];
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
}

- (void)reloadData
{
    CGFloat _width = CGRectGetWidth(self.frame);
    CGFloat _height = CGRectGetHeight(self.frame);
    _scrollWidth = _width+_pageMargin;
    
    CGRect r = contentView.frame;
    r.origin.y = _contentInsets.top;
    r.size.width = _width + _pageMargin;
    r.size.height = _height - _contentInsets.top - _contentInsets.bottom;
    contentView.frame = r;
    
    NSParameterAssert(_numberOfPages);
    NSParameterAssert(_pageAtIndex);
    if(_numberOfPages){
        _pageCount = _numberOfPages();
    }
    else{
        _pageCount = 0;
    }
    [contentView setContentSize:CGSizeMake(_scrollWidth*_pageCount, _height)];
    
    [self clearPages];
    
    if(!pageControllers){
        pageControllers = [NSMutableArray array];
    }
    else{
        [pageControllers removeAllObjects];
    }
    if(_pageCount>0 && _pageAtIndex){
        for(int i=0; i< _pageCount; i++){
            [pageControllers addObject:[NSNull null]];
        }
    }
    if(_pageCount>0){
        
        if(self.customTabBar&&[self.customTabBar respondsToSelector:@selector(selectedIndex)]){
            NSInteger selectedIndex = ([self.customTabBar selectedIndex]>_pageCount-1)?0:[self.customTabBar selectedIndex];
            [self setSelectedIndex:selectedIndex animated:NO];
        }
        else{
            [self setSelectedIndex:0 animated:NO];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:self.animatedSwitch];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    // 防止频繁调用ViewController的生命周期方法
    if(_selectedIndex==index && [self doesScrollLoadedView]) return;
    
    if(_selectedIndexDidChange){
        _selectedIndexDidChange(index);
    }
    
    // ViewController首次加载会触发生命周期函数的调用，所以需要用-isViewDidLoadAtIndex:方法屏蔽掉手动触发的调用
    if([self isViewDidLoadAtIndex:_selectedIndex]){
        
        if(_willDisplayPageAtIndex){
            _willDisplayPageAtIndex(self.selectedIndex, [self getPageAtIndex:self.selectedIndex]);
        }
    }
    
    if([self isViewDidLoadAtIndex:index]){
        
        if(_didDisplayPageAtIndex){
            _didDisplayPageAtIndex(index, [self getPageAtIndex:index]);
        }
    }
    
    _selectedIndex = index;
    
    [self.customTabBar setSelectedIndex:index];
    
    [self setupPageAtIndex:_selectedIndex];
    
    [contentView setContentOffset:CGPointMake(_selectedIndex*contentView.frame.size.width, 0) animated:animated];
    
}

/**
 判断Scroll是否是第一次加载子视图
 */
- (BOOL)doesScrollLoadedView
{
    BOOL found = NO;
    for(id elem in pageControllers){
        if(![elem isKindOfClass:[NSNull class]]){
            found = YES;
            break;
        }
    }
    return found;
}

/**
 判断对应索引位置的子视图是否已加载
 */
- (BOOL)isViewDidLoadAtIndex:(NSInteger)index
{
    if(pageControllers.count==0){
        return NO;
    }
    if(index>=pageControllers.count){
        return NO;
    }
    UIViewController *viewController = pageControllers[index];
    return ![viewController isKindOfClass:[NSNull class]];
}

- (void)setupPageAtIndex:(NSUInteger)index
{
    if(pageControllers.count==0){
        return;
    }
    NSParameterAssert(nil!=self.viewController);
    UIViewController *viewController = [self getPageAtIndex:index];
    if(viewController&&[self.viewController.childViewControllers containsObject:viewController]==NO){
        [self.viewController addChildViewController:viewController];
        
        CGFloat _width = CGRectGetWidth(self.frame);
        
        UIEdgeInsets pageInsets = _pageInsetsAtIndex? _pageInsetsAtIndex(index): UIEdgeInsetsZero;
        
        viewController.view.frame = CGRectMake(index*_scrollWidth, pageInsets.top, _width, contentView.frame.size.height-pageInsets.top);
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self.viewController];
        
    }
}

- (UIViewController *)getPageAtIndex:(NSUInteger)index
{
    if(pageControllers.count==0){
        return nil;
    }
    NSParameterAssert(index<pageControllers.count);
    NSParameterAssert(_numberOfPages);
    if(index>=pageControllers.count){
        return nil;
    }
    UIViewController *viewController = pageControllers[index];
    if([viewController isEqual:[NSNull null]]){
        if(_pageAtIndex){
            viewController = _pageAtIndex(index);
            [pageControllers replaceObjectAtIndex:index withObject:viewController];
        }
        else{
            viewController = nil;
        }
    }
    return viewController;
}

- (UIViewController *)currentViewController
{
    return [self getPageAtIndex:self.selectedIndex];
}

#pragma mark- scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!scrollByDragging){
        return;
    }
    
    if(scrollView.contentOffset.x+_scrollWidth> scrollView.contentSize.width ||
       scrollView.contentOffset.x<0){
        return;
    }
    
    if(_pageDidScroll){
        _pageDidScroll(scrollView.contentOffset);
    }
    
    if([self.customTabBar respondsToSelector:@selector(pageViewDidScroll:)]){
        [self.customTabBar pageViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollByDragging = YES;
    if([self.customTabBar respondsToSelector:@selector(pageViewWillBeginDragging:)]){
        [self.customTabBar pageViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollByDragging = NO;
    
    int page = floor((scrollView.contentOffset.x - _scrollWidth / 2) / _scrollWidth) + 1;
    if(page!=self.selectedIndex){
        [self setSelectedIndex:page];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        scrollByDragging = NO;
        
        int page = floor((scrollView.contentOffset.x - _scrollWidth / 2) / _scrollWidth) + 1;
        if(page!=self.selectedIndex){
            [self setSelectedIndex:page];
        }
    }
}
@end

