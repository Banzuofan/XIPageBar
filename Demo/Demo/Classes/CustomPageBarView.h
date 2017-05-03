//
//  CustomPageBarView.h
//  Demo
//
//  Created by YXLONG on 16/6/29.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XICustomBarConfigurations.h"

@interface CustomPageBarView : UIView<XICustomBarConfigurations>
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, copy) void(^didSelectItemAtIndex)(NSUInteger index);
@end
