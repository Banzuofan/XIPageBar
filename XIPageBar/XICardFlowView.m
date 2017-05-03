//
//  XICardFlowView.m
//
//  Created by YXLONG on 15/11/26.
//
//

#import "XICardFlowView.h"
#import <objc/runtime.h>

#define kDefaultItemSpacing 20
#define kDefaultInvisibleViewMinScaleValue 0.95
#define kDefaultInvisibleViewMinAlphaValue 0.8

@implementation XICardFlowCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /*
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0
                                               green:arc4random_uniform(255)/255.0
                                                blue:arc4random_uniform(255)/255.0
                                               alpha:1];
         */
    }
    return self;
}

@end

@interface XICardFlowView ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger lastPageIndex;
    BOOL scrollingByDragging;
}
- (XICardFlowLayout *)cardFlowLayout;
@end

@implementation XICardFlowView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if(self=[super initWithFrame:frame collectionViewLayout:layout]){
        self.backgroundColor = [UIColor clearColor];
        self.scrollsToTop = NO;
        lastPageIndex = 0;
        scrollingByDragging = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    XICardFlowLayout* lineLayout = [[XICardFlowLayout alloc] initWithItemSize:CGSizeMake(5, 5)
                                                                  itemSpacing:kDefaultItemSpacing
                                                                  scaleFactor:kDefaultInvisibleViewMinScaleValue
                                                                  alphaFactor:kDefaultInvisibleViewMinAlphaValue];
    if(self=[self initWithFrame:frame collectionViewLayout:lineLayout]){
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.dataSource = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return self;
}

- (XICardFlowLayout *)cardFlowLayout
{
    return (XICardFlowLayout *)self.collectionViewLayout;
}

- (void)centerCardIfNeeded
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    [self scrollToItemAtIndexPath:centeredIndexPath
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                         animated:NO];
}

- (void)setItemSpace:(NSInteger)itemSpace
{
    _itemSpace = itemSpace;
    
    self.cardFlowLayout.minimumLineSpacing = _itemSpace;
    
    if(self.superview){
        [self.cardFlowLayout invalidateLayout];
        [self centerCardIfNeeded];
    }
}

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    self.cardFlowLayout.itemSize = itemSize;
    self.cardFlowLayout.activeDistance = itemSize.width;
    
    if(self.superview){
        [self.cardFlowLayout invalidateLayout];
        [self centerCardIfNeeded];
    }
}

- (void)setInvisibleViewMinAlphaValue:(CGFloat)invisibleViewMinAlphaValue
{
    _invisibleViewMinAlphaValue = invisibleViewMinAlphaValue;
    self.cardFlowLayout.alphaFactor = 1.0-invisibleViewMinAlphaValue;
    
    if(self.superview){
        [self.cardFlowLayout invalidateLayout];
    }
}

- (void)setInvisibleViewMinScaleValue:(CGFloat)invisibleViewMinScaleValue
{
    _invisibleViewMinScaleValue = invisibleViewMinScaleValue;
    self.cardFlowLayout.scaleFactor = 1-invisibleViewMinScaleValue;
    
    if(self.superview){
        [self.cardFlowLayout invalidateLayout];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    lastPageIndex = [self currentPageIndex];
    [super setContentOffset:contentOffset animated:animated];
    
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    lastPageIndex = [self currentPageIndex];
    [super scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (CGRect)visibleRect
{
    CGRect _visibleRect;
    _visibleRect.origin = self.contentOffset;
    _visibleRect.size = self.bounds.size;
    return _visibleRect;
}

- (NSInteger)currentPageIndex
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    
    return centeredIndexPath.row;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger numberOfItems = 0;
    if([self.wrappedDelegate respondsToSelector:@selector(numberOfCardsForCardFlowView:)]){
        
        numberOfItems = [self.wrappedDelegate numberOfCardsForCardFlowView:self];
        if([self.pageControl respondsToSelector:@selector(setNumberOfPages:)]){
            [self.pageControl setNumberOfPages:numberOfItems];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:cardViewAtIndexPath:)]){
        cell = [self.wrappedDelegate cardFlowView:self cardViewAtIndexPath:indexPath];
        return cell;
    }
    return cell;
}

#pragma mark-- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollingByDragging = YES;
    if (_pageControl && [_pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        
        lastPageIndex = [_pageControl currentPage];
    }
    else{
        CGPoint point = [self.superview convertPoint:self.center toView:self];
        NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
        
        lastPageIndex = centeredIndexPath.row;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    
    UICollectionViewFlowLayout *flowlayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGPoint paddingPoint = CGPointMake(self.center.x + flowlayout.itemSize.width+flowlayout.minimumLineSpacing, self.center.y);
    
    CGPoint nextPoint = [self.superview convertPoint:paddingPoint toView:self];
    NSIndexPath *nextIndexPath = [self indexPathForItemAtPoint:nextPoint];
    
    if (scrollingByDragging && centeredIndexPath.row != nextIndexPath.row) {
        if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:centeredIndexWillChange:)]){
            [self.wrappedDelegate cardFlowView:self centeredIndexWillChange:centeredIndexPath.row];
        }
    }
    
    if (scrollingByDragging && _pageControl && [_pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        
        if (centeredIndexPath.row != nextIndexPath.row) {
            [_pageControl setCurrentPage:centeredIndexPath.row];
        }
    }
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidScroll:)]){
        [self.wrappedDelegate cardFlowViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndDragging:willDecelerate:)]){
        [self.wrappedDelegate cardFlowViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.wrappedDelegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    scrollingByDragging = NO;
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndDecelerating:)]){
        [self.wrappedDelegate cardFlowViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.wrappedDelegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndScrollingAnimation:)]){
        [self.wrappedDelegate cardFlowViewDidEndScrollingAnimation:scrollView];
    }
}

@end
