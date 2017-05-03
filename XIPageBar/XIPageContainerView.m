//
//  XIPageContainerView.m
//
//  Created by YXLONG on 16/5/17.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "XIPageContainerView.h"
#import "XIPageBarUtility.h"

@interface XIPageContainerView ()<UIScrollViewDelegate>
@property(nonatomic, weak) UIViewController *viewController;
- (void)clearPages;
- (void)setupPageAtIndex:(NSUInteger)index;
@end

@implementation XIPageContainerView
{
    UIScrollView *contentView;
    NSMutableArray *pageControllers;
    BOOL scrollByDragging;
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [self initWithFrame:CGRectZero];
    if(self){
        self.viewController = viewController;
        self.viewController.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor redColor];
        pageControllers = [NSMutableArray array];
        scrollByDragging = NO;
        _selectedIndex = -1;
        _contentInsets = UIEdgeInsetsZero;
        
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    contentView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(_contentInsets.top, 0, _contentInsets.bottom, 0));
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
    NSParameterAssert(_numberOfPages);
    NSParameterAssert(_pageAtIndex);
    if(_numberOfPages){
        _pageCount = _numberOfPages();
    }
    else{
        _pageCount = 0;
    }
    [contentView setContentSize:CGSizeMake([UIScreen portraitWidth]*_pageCount, 0)];
    [self clearPages];
    if(!pageControllers){
        pageControllers = [NSMutableArray array];
    }
    else{
        [pageControllers removeAllObjects];
    }
    if(_pageCount>0&&_pageAtIndex){
        for(int i=0; i< _pageCount; i++){
            [pageControllers addObject:[NSNull null]];
        }
    }
    if(_pageCount>0){
        if(self.customTabBar&&[self.customTabBar respondsToSelector:@selector(selectedIndex)]){
            [self setSelectedIndex:[self.customTabBar selectedIndex] animated:NO];
        }
        else{
            [self setSelectedIndex:0 animated:NO];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:self.shouldSwitchWithAnimation];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    if(_selectedIndex!=index){
        if(_selectedIndex>=0){
            if(_willDisplayPageAtIndex){
                _willDisplayPageAtIndex(self.selectedIndex, [self getPageAtIndex:self.selectedIndex]);
            }
        }
    }
    _selectedIndex = index;
    if(_didDisplayPageAtIndex){
        _didDisplayPageAtIndex(index, [self getPageAtIndex:index]);
    }
    [self.customTabBar setSelectedIndex:index];
    [self setupPageAtIndex:_selectedIndex];
    
    [contentView setContentOffset:CGPointMake(_selectedIndex*contentView.frame.size.width, 0) animated:animated];
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
        
        UIEdgeInsets pageInsets = _pageInsetsAtIndex? _pageInsetsAtIndex(index): UIEdgeInsetsZero;
        
        viewController.view.frame = CGRectMake(index*contentView.frame.size.width, pageInsets.top, contentView.frame.size.width, contentView.frame.size.height-pageInsets.top);
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

#pragma mark- scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!scrollByDragging){
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    if(scrollView.contentOffset.x+pageWidth> scrollView.contentSize.width ||
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
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page!=self.selectedIndex){
        [self setSelectedIndex:page];
    }
}
@end

