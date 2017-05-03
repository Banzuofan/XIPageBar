//
//  XICustomBarConfigurations.h
//
//  Created by YXLONG on 16/5/17.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

@protocol XICustomBarConfigurations <NSObject>
- (void)setSelectedIndex:(NSInteger)index;
@optional
- (NSInteger)selectedIndex;
- (void)pageViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)pageViewDidScroll:(UIScrollView *)scrollView;
@end
