//
//  XISpacingPageContainerView.h
//
//  Created by YXLONG on 2016/11/26.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XICustomBarConfigurations.h"
#import "XICardFlowView.h"

@interface XISpacingPageContainerView : UIView

@property(nonatomic, weak) id<XICustomBarConfigurations> customTabBar;
@property(nonatomic, strong, readonly) XICardFlowView *pagingScrollView;
@property(nonatomic, copy) NSInteger(^numberOfPages)(void);
@property(nonatomic, copy) id (^pageAtIndex)(NSUInteger index);

- (instancetype)initWithViewController:(UIViewController *)viewController
                     preferredPageSize:(CGSize)preferredPageSize
                    preferredPageCount:(NSInteger)preferredPageCount
                            pageMargin:(CGFloat)pageMargin;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;
@end
