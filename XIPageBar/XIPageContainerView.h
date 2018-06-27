//
//  XIPageContainerView.h
//
//  Created by YXLONG on 16/5/17.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XICustomBarConfigurations.h"

@interface XIPageContainerView : UIView
@property(nonatomic, weak) id<XICustomBarConfigurations> customTabBar;
@property(nonatomic, strong, readonly) UIScrollView *scrollView;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, readonly) NSInteger pageCount;
@property(nonatomic, assign) BOOL animatedSwitch;
@property(nonatomic, assign) UIEdgeInsets contentInsets;
@property(nonatomic, assign) CGPoint contentOffset;
@property(nonatomic, assign) CGFloat pageMargin;
//!---
@property(nonatomic, copy) NSInteger(^numberOfPages)(void);
@property(nonatomic, copy) UIViewController *(^pageAtIndex)(NSUInteger index);
@property(nonatomic, assign) UIEdgeInsets(^pageInsetsAtIndex)(NSUInteger index);
@property(nonatomic, copy) void(^pageDidScroll)(CGPoint contentOffset);
@property(nonatomic, copy) void(^selectedIndexDidChange)(NSInteger newIndex);
@property(nonatomic, copy) void(^willDisplayPageAtIndex)(NSInteger oldIndex, UIViewController *pageWillDisappear);
@property(nonatomic, copy) void(^didDisplayPageAtIndex)(NSInteger newIndex, UIViewController *pageDidAppear);

- (instancetype)initWithViewController:(UIViewController *)viewController;
- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController;
- (void)reloadData;
- (UIViewController *)getPageAtIndex:(NSUInteger)index;
- (UIViewController *)currentViewController;
@end
