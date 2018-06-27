//
//  ContainerTableView.m
//  Demo
//
//  Created by YXLONG on 2018/6/27.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "ContainerTableView.h"

@implementation ContainerTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
