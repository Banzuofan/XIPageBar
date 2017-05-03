//
//  XIPageBarUtility.m
//
//  Created by YXLONG on 2017/4/6.
//  Copyright © 2017年 XIPageBar. All rights reserved.
//

#import "XIPageBarUtility.h"
#include <objc/runtime.h>

@implementation XIPageBarUtility

@end

@implementation UIColor (XIPageBarView)

- (NSDictionary *)RGBValue
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return @{@"R":@(r),
             @"G":@(g),
             @"B":@(b),
             @"A":@(a)};
}

@end

static void* kRValueKey = &kRValueKey;
static void* kGValueKey = &kGValueKey;
static void* kBValueKey = &kBValueKey;
static void* kAValueKey = &kAValueKey;

static void* kSavedRGBValuesKey = &kSavedRGBValuesKey;

@implementation UIColor (RGBValueGetter)

- (void)resetRGBValues
{
    objc_setAssociatedObject(self, kSavedRGBValuesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)checkValues
{
    NSDictionary * values = objc_getAssociatedObject(self, kSavedRGBValuesKey);
    if(!values){
        values = [self RGBValue];
        objc_setAssociatedObject(self, kSavedRGBValuesKey, values, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return values;
}

- (CGFloat)rValue
{
    return [self.checkValues[@"R"] floatValue];
}

- (CGFloat)gValue
{
    return [self.checkValues[@"G"] floatValue];
}

- (CGFloat)bValue
{
    return [self.checkValues[@"B"] floatValue];
}

- (CGFloat)aValue
{
    return [self.checkValues[@"A"] floatValue];
}

@end


@implementation UIScreen (BoundSize)
+ (CGFloat)portraitWidth
{
    return MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}
+ (CGFloat)portraitHeight
{
    return MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

@end
