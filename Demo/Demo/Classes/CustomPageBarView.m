//
//  CustomPageBarView.m
//  Demo
//
//  Created by YXLONG on 16/6/29.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "CustomPageBarView.h"
#import "Masonry.h"

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define _bar_item_tag_base 1000
#define _indicatorView_height 2.5
#define _content_padding 10.0
#define _indicator_width (kSCREEN_WIDTH-_content_padding*2)/3

@implementation CustomPageBarView
{
    UIView *indicatorView;
    UIView *indicatorMovingRail;
    UIView *contentView;
    UIView *separatorLine;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        _selectedIndex = 0;
        NSArray *titles = @[@"Left",@"Middle",@"Right"];
        contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(_content_padding);
            make.right.equalTo(self).with.offset(-_content_padding);
            make.top.and.bottom.equalTo(self);
        }];
        
        indicatorMovingRail = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:indicatorMovingRail];
        [indicatorMovingRail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.equalTo(contentView);
            make.width.equalTo(contentView);
            make.height.mas_equalTo(@(_indicatorView_height));
        }];
        
        NSMutableArray *arr = @[].mutableCopy;
        for(int i=0;i<titles.count;i++){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(barItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btn];
            if(_selectedIndex==i){
                btn.selected = YES;
            }
            btn.tag = _bar_item_tag_base+i;
            [arr addObject:btn];
        }
        [arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [arr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(contentView);
        }];
        
        self.separatorLine.hidden = NO;
    }
    return self;
}

- (UIView *)separatorLine
{
    if(!separatorLine){
        separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        [self insertSubview:separatorLine aboveSubview:contentView];
        
        [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return separatorLine;
}

- (UIView *)indicatorView
{
    if(!indicatorView){
        indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        indicatorView.backgroundColor = [UIColor redColor];
        [indicatorMovingRail addSubview:indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(indicatorMovingRail);
            make.top.and.bottom.equalTo(indicatorMovingRail);
            make.width.mas_equalTo(@(_indicator_width));
        }];
    }
    return indicatorView;
}

- (void)changeIndicatorPositionWithSelectedIndex:(NSInteger)index
{
    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(index==0){
            make.left.equalTo(indicatorMovingRail);
        }
        else if(index==1){
            make.centerX.equalTo(indicatorMovingRail);
        }
        else{
            make.right.equalTo(indicatorMovingRail);
        }
        make.top.and.bottom.equalTo(indicatorMovingRail);
        make.width.mas_equalTo(@(_indicator_width));
    }];
    
    [indicatorMovingRail setNeedsUpdateConstraints];
    [indicatorMovingRail updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [indicatorMovingRail layoutIfNeeded];
    }];
}

- (void)barItemSelected:(UIButton *)btn
{
    NSUInteger willSelectedIndex = btn.tag-_bar_item_tag_base;
    if(willSelectedIndex==_selectedIndex){
        return;
    }
    if(_didSelectItemAtIndex){
        _didSelectItemAtIndex(willSelectedIndex);
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    UIButton *lastBtn = (UIButton *)[contentView viewWithTag:(_selectedIndex+_bar_item_tag_base)];
    lastBtn.selected = NO;
    
    _selectedIndex = index;
    
    UIButton *selectedBtn = (UIButton *)[contentView viewWithTag:(index+_bar_item_tag_base)];
    selectedBtn.selected = YES;
    
    [self changeIndicatorPositionWithSelectedIndex:index];
}

@end
