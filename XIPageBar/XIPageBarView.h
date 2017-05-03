//
//  XIPageBarView.h
//
//  Created by YXLONG on 15/10/20.
//  Copyright © 2015年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XICustomBarConfigurations.h"

@interface XIPageBarView : UIView<XICustomBarConfigurations>
@property(nonatomic, strong) NSArray *barItemTitles;
@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, copy) void(^didSelectItemAtIndex)(XIPageBarView *view, NSUInteger index);
//!---
@property(nonatomic, assign) UIEdgeInsets contentInsets; // default value {0,5,0,5}
@property(nonatomic, strong) UIColor *itemTitleColorForNormal;
@property(nonatomic, strong) UIColor *itemTitleColorForSelected;
@property(nonatomic, strong) UIFont *titleFont;
@property(nonatomic, assign) CGFloat itemSpace;// the space between items
// 当autoAdjustItemWidthIfNeeded = YES，如果所有选项尺寸和小于屏幕宽度时
// 会重新计算（平分屏宽）并设置每个选项的宽度
@property(nonatomic, assign) BOOL autoAdjustItemWidthIfNeeded;

@property(nonatomic, assign, getter=isItemWidthFixed) BOOL itemWidthFixed;// 是否是固定尺寸的tab宽度
// 仅当itemWidthFixed = YES时，获取每个选项的宽度；当itemWidthFixed = NO，不影响布局
@property(nonatomic, copy) CGFloat(^fixedItemWidthAtIndex)(NSInteger index);

@property(nonatomic, strong) UIColor *indicatorColor;
@property(nonatomic, assign) BOOL adjustIndicatorWidthAsTitle;
@property(nonatomic, assign) BOOL titleColorTransitionSupported;

- (instancetype)initWithFrame:(CGRect)frame itemTitles:(NSArray *)array;
@end
