//
//  UIColor+Random.m
//  Demo
//
//  Created by YXLONG on 16/6/29.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor(Random)
+ (UIColor *)randomColor {
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        (time(NULL));
    }
    CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
@end
