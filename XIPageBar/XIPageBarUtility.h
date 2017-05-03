//
//  XIPageBarUtility.h
//
//  Created by YXLONG on 2017/4/6.
//  Copyright © 2017年 XIPageBar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WEAKSELF __weak __typeof(&*self)weakSelf = self;

@interface XIPageBarUtility : NSObject

@end

@interface UIColor (XIPageBarView)
- (NSDictionary *)RGBValue;
@end

@interface UIColor (RGBValueGetter)
@property(nonatomic, assign, readonly) CGFloat rValue;
@property(nonatomic, assign, readonly) CGFloat gValue;
@property(nonatomic, assign, readonly) CGFloat bValue;
@property(nonatomic, assign, readonly) CGFloat aValue;
- (void)resetRGBValues;
@end

@interface UIScreen (BoundSize)
+ (CGFloat)portraitWidth;
+ (CGFloat)portraitHeight;
@end
