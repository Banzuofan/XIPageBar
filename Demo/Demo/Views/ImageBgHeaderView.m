//
//  InfoHeaderView.m
//  Demo
//
//  Created by YXLONG on 2018/6/27.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "ImageBgHeaderView.h"

@implementation ImageBgHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
        _bgView.frame = self.bounds;
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bgView];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-80, CGRectGetWidth(self.frame), 80)];
        _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
    }
    return self;
}

@end
