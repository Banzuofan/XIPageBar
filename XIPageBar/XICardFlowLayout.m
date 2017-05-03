//
//  XICardFlowLayout.m
//
//  Created by YXLONG on 2017/4/11.
//  Copyright © 2017年 XIPageBar. All rights reserved.
//

#import "XICardFlowLayout.h"

@implementation XICardFlowLayout
{
    CGFloat _insetsValue;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithItemSize:(CGSize)itemSize
                     itemSpacing:(CGFloat)space
                     scaleFactor:(CGFloat)factor
                     alphaFactor:(CGFloat)factor1
{
    if(self = [self init]){
        self.itemSize = itemSize;
        self.minimumLineSpacing = space;
        self.activeDistance = self.itemSize.width;
        self.scaleFactor = factor;
        self.alphaFactor = factor1;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _insetsValue = (CGRectGetWidth(self.collectionView.frame) - self.itemSize.width)/2;
    self.sectionInset = UIEdgeInsetsMake(0, _insetsValue, 0, _insetsValue);
    
    self.collectionView.contentSize = [self collectionViewContentSize];
}

- (CGSize)collectionViewContentSize
{
    NSInteger rowCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat _contentSizeWidth = _insetsValue*2+self.itemSize.width*rowCount+self.minimumLineSpacing*(rowCount-1);
    return CGSizeMake(_contentSizeWidth, CGRectGetHeight(self.collectionView.frame));
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    NSArray* originalArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes* elem in originalArray) {
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:elem.indexPath];
        [array addObject:attributes];
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.itemSize;
    
    CGFloat itemCenterX = _insetsValue + self.pageWidth * indexPath.row + self.itemSize.width / 2;
    attributes.center = CGPointMake(itemCenterX, CGRectGetHeight(self.collectionView.frame)/2);
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
    CGFloat changeRatio = distance / self.activeDistance;
    CGFloat scale;
    
    if (fabs(distance) < self.activeDistance) {
        scale = 1-self.scaleFactor*ABS(changeRatio);
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
        
        attributes.alpha = 1-self.alphaFactor*ABS(changeRatio);
        attributes.zIndex = 1;
    }
    else{
        scale = 1 - self.scaleFactor;
        attributes.zIndex = 0;
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
        attributes.alpha = 1-self.alphaFactor;
    }
    
    return attributes;
}

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)flickVelocity {
    return 0.3;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
    }
    
    if(fabs(proposedContentOffset.x)<1){
        proposedContentOffset.x = 0;
    }
    
    proposedContentOffset.y = 0;
    return proposedContentOffset;
}
@end
