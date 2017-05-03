//
//  XICardFlowLayout.h
//
//  Created by YXLONG on 2017/4/11.
//  Copyright © 2017年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XICardFlowLayout : UICollectionViewFlowLayout
@property(nonatomic, assign) CGFloat scaleFactor;
@property(nonatomic, assign) CGFloat activeDistance;
@property(nonatomic, assign) CGFloat alphaFactor;

- (instancetype)initWithItemSize:(CGSize)itemSize
                     itemSpacing:(CGFloat)space
                     scaleFactor:(CGFloat)factor
                     alphaFactor:(CGFloat)factor1;
@end
