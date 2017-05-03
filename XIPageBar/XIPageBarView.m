//
//  XIPageBarView.m
//
//  Created by YXLONG on 15/10/20.
//  Copyright © 2015年 XIPageBar. All rights reserved.
//

#import "XIPageBarView.h"
#import "XIPageBarUtility.h"

#define _bar_item_tag_base 1000
#define defaultIndicatorColor [UIColor orangeColor]
#define defaultItemSpace 25
#define defaultItemWidth 60
#define defaultIndicatorHeight 2.0f

@interface XIPagerBarItem : UIButton
@property(nonatomic, strong) UIColor *titleColorForNormalState;
@property(nonatomic, strong) UIColor *titleColorForSelectedState;

- (void)setTitleLabelFont:(UIFont *)font;
- (void)setTitleLabelFontAsStateChanged:(UIFont *)font;
- (CGSize)fitSize;
@end

@interface XIPageBarView ()
{
    UIScrollView *_contentView;
    NSMutableArray *_buttonItems;
    
    NSInteger lastIndex;
    NSInteger theNextIndex;
}
@property(nonatomic, strong) UIView *indicatorView;
@property(nonatomic, strong) XIPagerBarItem *sharedBarItem;

- (void)commonInit;
- (void)layoutSubviewsNeeded;
@end

@implementation XIPageBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame itemTitles:(NSArray *)array
{
    if(self=[self initWithFrame:frame]){
        self.barItemTitles = array;
    }
    return self;
}

- (void)commonInit
{
    _contentInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    _buttonItems = @[].mutableCopy;
    
    _titleFont = [UIFont systemFontOfSize:15.0];
    _itemSpace = defaultItemSpace;
    _indicatorColor = defaultIndicatorColor;
    _itemTitleColorForNormal = [UIColor blackColor];
    _itemTitleColorForSelected = [UIColor lightGrayColor];
    _autoAdjustItemWidthIfNeeded = NO;
    _itemWidthFixed = NO;
    _titleColorTransitionSupported = YES;
    
    _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_contentView];
}

- (UIView *)indicatorView
{
    if(!_indicatorView){
        _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _indicatorView.backgroundColor = _indicatorColor;
        [_contentView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (XIPagerBarItem *)sharedBarItem
{
    if(!_sharedBarItem){
        _sharedBarItem = [[XIPagerBarItem alloc] init];
    }
    return _sharedBarItem;
}

- (void)setBarItemTitles:(NSArray *)array
{
    _barItemTitles = array;
    
    if(_buttonItems.count>0){
        [_buttonItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_buttonItems removeAllObjects];
    }
    
    if(_barItemTitles.count>0){
        
        if(_itemWidthFixed){
            NSAssert(_fixedItemWidthAtIndex!=nil, @"make sure _fixedItemWidthAtIndex initilized when _itemWidthFixed is YES");
        }
        
        UIView *lastView;
        
        float itemWidth = 0;
        float adjustedItemSpace = _itemSpace;
        BOOL autoAdjustItemWidth = NO;
        if(!_itemWidthFixed && _autoAdjustItemWidthIfNeeded){
            if(_autoAdjustItemWidthIfNeeded){
                float totalWidth = _contentInsets.left;
                [self.sharedBarItem setTitleLabelFont:_titleFont];
                for(NSInteger i=0;i<_barItemTitles.count;i++){
                    NSString *title = _barItemTitles[i];
                    [self.sharedBarItem setTitle:title forState:UIControlStateNormal];
                    self.sharedBarItem.selected = (_selectedIndex==i);
                    totalWidth += [self.sharedBarItem fitSize].width;
                }
                totalWidth += _contentInsets.right;
                totalWidth += _itemSpace*(_barItemTitles.count-1);
                autoAdjustItemWidth = (totalWidth>[UIScreen portraitWidth])?NO:YES;
                if(autoAdjustItemWidth){
                    itemWidth = ([UIScreen portraitWidth]-_contentInsets.right-_contentInsets.left)/_barItemTitles.count;
                    adjustedItemSpace = 0;
                }
            }
        }
        
        for(NSInteger i=0;i<_barItemTitles.count;i++){
            NSString *title = _barItemTitles[i];
            XIPagerBarItem *btn = [[XIPagerBarItem alloc] init];
            [btn setTitleLabelFont:_titleFont];
            btn.tag = _bar_item_tag_base+i;
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColorForNormalState:_itemTitleColorForNormal];
            [btn setTitleColorForSelectedState:_itemTitleColorForSelected];
            [btn addTarget:self action:@selector(_barItemSelect:) forControlEvents:UIControlEventTouchUpInside];
            [_contentView addSubview:btn];
            
            if(_selectedIndex==i){
                btn.selected = YES;
            }
            
            if(self.isItemWidthFixed){
                itemWidth = _fixedItemWidthAtIndex?_fixedItemWidthAtIndex(i):defaultItemWidth;
            }
            else{
                if(!autoAdjustItemWidth){
                    itemWidth = [btn fitSize].width;
                }
            }
            
            if(lastView){
                btn.frame = CGRectMake(CGRectGetMaxX(lastView.frame)+adjustedItemSpace, 0, itemWidth, self.frame.size.height);
            }
            else{
                btn.frame = CGRectMake(_contentInsets.left, 0, itemWidth, self.frame.size.height);
            }
            lastView = btn;
            
            [_buttonItems addObject:btn];
        }
        [_contentView setContentSize:CGSizeMake(CGRectGetMaxX(lastView.frame)+_contentInsets.right, self.frame.size.height)];
    }
}

- (void)layoutSubviewsNeeded
{
    if(_buttonItems.count>0){
        if(_itemWidthFixed){
            NSAssert(_fixedItemWidthAtIndex!=nil, @"You should setup '_fixedItemWidthAtIndex' when _itemWidthFixed is YES");
        }
        
        XIPagerBarItem *selectedBarItem;
        UIView *lastView;
        float itemWidth = 0;
        float adjustedItemSpace = _itemSpace;
        BOOL autoAdjustItemWidth = NO;
        
        if(!_itemWidthFixed && _autoAdjustItemWidthIfNeeded){
            float totalWidth = _contentInsets.left;
            [self.sharedBarItem setTitleLabelFont:_titleFont];
            for(NSInteger i=0;i<_barItemTitles.count;i++){
                
                NSString *title = _barItemTitles[i];
                [self.sharedBarItem setTitle:title forState:UIControlStateNormal];
                self.sharedBarItem.selected = (_selectedIndex==i);
                
                totalWidth += [self.sharedBarItem fitSize].width;
            }
            totalWidth += _contentInsets.right;
            totalWidth += _itemSpace*(_barItemTitles.count-1);
            autoAdjustItemWidth = (totalWidth>[UIScreen portraitWidth])?NO:YES;
            if(autoAdjustItemWidth){
                itemWidth = ([UIScreen portraitWidth]-_contentInsets.right-_contentInsets.left)/_barItemTitles.count;
                adjustedItemSpace = 0;
            }
        }
        
        // Change the layout of each item.
        for(NSInteger i=0;i<_buttonItems.count;i++){
            
            XIPagerBarItem *btn = _buttonItems[i];
            
            if(_selectedIndex == i){
                selectedBarItem = btn;
                
                if(!btn.selected){
                    btn.selected = YES;
                }
            }
            
            if(self.isItemWidthFixed){
                itemWidth = _fixedItemWidthAtIndex?_fixedItemWidthAtIndex(i):defaultItemWidth;
            }
            else{
                if(!autoAdjustItemWidth){
                    itemWidth = [btn fitSize].width;
                }
            }
            
            if(lastView){
                btn.frame = CGRectMake(CGRectGetMaxX(lastView.frame)+adjustedItemSpace, 0, itemWidth, self.frame.size.height);
            }
            else{
                btn.frame = CGRectMake(_contentInsets.left, 0, itemWidth, self.frame.size.height);
            }
            lastView = btn;
        }
        
        [_contentView setContentSize:CGSizeMake(CGRectGetMaxX(lastView.frame)+_contentInsets.right, self.frame.size.height)];
        
        [self _indicatorMovesTo:selectedBarItem];
    }
}

- (void)_barItemSelect:(id)sender
{
    XIPagerBarItem *btn = (XIPagerBarItem *)sender;
    NSUInteger willSelectedIndex = btn.tag-_bar_item_tag_base;
    
    if(willSelectedIndex==_selectedIndex){
        return;
    }
    if(_didSelectItemAtIndex){
        _didSelectItemAtIndex(self, willSelectedIndex);
    }
}

- (void)_indicatorMovesTo:(XIPagerBarItem *)barItem
{
    CGRect r = self.indicatorView.frame;
    if(_adjustIndicatorWidthAsTitle){
        r.size.width = barItem.fitSize.width;
    }
    else{
        r.size.width = CGRectGetWidth(barItem.frame);
    }
    r.size.height = defaultIndicatorHeight;
    r.origin.y = CGRectGetMaxY(barItem.frame) - r.size.height;
    self.indicatorView.frame = r;
    
    CGPoint c = self.indicatorView.center;
    c.x = barItem.center.x;
    [UIView animateWithDuration:0.15 animations:^{
        self.indicatorView.center = c;
    }];
}

- (void)setSelectedIndex:(NSUInteger)index
{
    XIPagerBarItem *lastBtn = (XIPagerBarItem *)[_contentView viewWithTag:(_selectedIndex+_bar_item_tag_base)];
    lastBtn.selected = NO;
    
    _selectedIndex = index;
    
    XIPagerBarItem *selectedBtn = (XIPagerBarItem *)[_contentView viewWithTag:(index+_bar_item_tag_base)];
    selectedBtn.selected = YES;
    
    // As the width of the item selected has changed, so the width of each item should be calculated again.
    [self layoutSubviewsNeeded];
    
    // Make the selected item visible
    CGRect visibleFrame = selectedBtn.frame;
    visibleFrame.origin.x -= CGRectGetWidth(self.frame)/2-CGRectGetWidth(selectedBtn.frame)/2;
    visibleFrame.size.width = CGRectGetWidth(_contentView.frame);
    [_contentView scrollRectToVisible:visibleFrame animated:YES];
}

#pragma mark-- Setters

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    if(self.superview){
        [self layoutSubviewsNeeded];
    }
}

- (void)setAutoAdjustItemWidthIfNeeded:(BOOL)autoAdjustItemWidthIfNeeded
{
    _autoAdjustItemWidthIfNeeded = autoAdjustItemWidthIfNeeded;
    if(self.superview){
        [self layoutSubviewsNeeded];
    }
}

- (void)setItemWidthFixed:(BOOL)itemWidthFixed
{
    _itemWidthFixed = itemWidthFixed;
    if(self.superview){
        [self layoutSubviewsNeeded];
    }
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    if(self.superview){
        [self layoutSubviewsNeeded];
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    self.indicatorView.backgroundColor = indicatorColor;
}

- (void)setItemTitleColorForNormal:(UIColor *)itemTitleColorForNormal
{
    _itemTitleColorForNormal = itemTitleColorForNormal;
    
    for(XIPagerBarItem *elem in _buttonItems){
        elem.titleColorForNormalState = _itemTitleColorForNormal;
    }
}

- (void)setItemTitleColorForSelected:(UIColor *)itemTitleColorForSelected
{
    _itemTitleColorForSelected = itemTitleColorForSelected;
    for(XIPagerBarItem *elem in _buttonItems){
        elem.titleColorForSelectedState = _itemTitleColorForSelected;
    }
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    if(self.superview){
        [self layoutSubviewsNeeded];
    }
}

#pragma mark- XICustomBarConfigurations

- (void)pageViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat pageWidth = [UIScreen portraitWidth];
    lastIndex = scrollView.contentOffset.x/pageWidth;
    theNextIndex = -1;
}

- (void)pageViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = [UIScreen portraitWidth];
    CGFloat pageMaxChangeRange = pageWidth;
    
    NSInteger theNearestPageIndex = scrollView.contentOffset.x/pageWidth;
//    NSLog(@"theNearestPageIndex :%lu", theNearestPageIndex);
    if(theNearestPageIndex!=theNextIndex){
        if(theNextIndex>=0){
            lastIndex = theNextIndex;
        }
        theNextIndex = theNearestPageIndex;
//        NSLog(@"lastIndex :%@, theNextIndex: %@", @(lastIndex), @(theNextIndex));
    }
    
    if(scrollView.contentOffset.x>lastIndex*pageWidth){
//        NSLog(@"<<<<slide from left to right");
        NSInteger theCurrent = theNextIndex;
        
        if(theCurrent+1 < _buttonItems.count ){
            XIPagerBarItem *curr = _buttonItems[theCurrent];
            XIPagerBarItem *next = _buttonItems[theCurrent+1];
            
            CGFloat changeRange = scrollView.contentOffset.x - theCurrent*[UIScreen portraitWidth];
            float changeRatio = changeRange/pageMaxChangeRange;
            
            if(_titleColorTransitionSupported && changeRatio-1<0.0001){
                UIColor *_colorForNormal = curr.titleColorForNormalState;
                UIColor *_colorForSelected = curr.titleColorForSelectedState;
                
                CGFloat tmpR = _colorForSelected.rValue + (_colorForNormal.rValue-_colorForSelected.rValue)*changeRatio;
                CGFloat tmpG = _colorForSelected.gValue + (_colorForNormal.gValue-_colorForSelected.gValue)*changeRatio;
                CGFloat tmpB = _colorForSelected.bValue + (_colorForNormal.bValue-_colorForSelected.bValue)*changeRatio;
                CGFloat tmpA = _colorForSelected.aValue;
                [curr setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateNormal];
                [curr setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateSelected];
                
                tmpR = _colorForNormal.rValue + (_colorForSelected.rValue-_colorForNormal.rValue)*changeRatio;
                tmpG = _colorForNormal.gValue + (_colorForSelected.gValue-_colorForNormal.gValue)*changeRatio;
                tmpB = _colorForNormal.bValue + (_colorForSelected.bValue-_colorForNormal.bValue)*changeRatio;
                tmpA = _colorForNormal.aValue;
                [next setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateNormal];
                [next setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateSelected];
            }
            
            CGPoint c = self.indicatorView.center;
            c.x = curr.center.x + (next.center.x - curr.center.x)*changeRatio;
            self.indicatorView.center = c;
            
            if(!self.isItemWidthFixed){
                
                CGRect r = self.indicatorView.frame;
                if(self.adjustIndicatorWidthAsTitle && curr.fitSize.width != next.fitSize.width){
                    r.size.width = curr.fitSize.width + (next.fitSize.width-curr.fitSize.width)*changeRatio;
                }
                else if(!self.adjustIndicatorWidthAsTitle && CGRectGetWidth(next.frame) != CGRectGetWidth(curr.frame)){
                    r.size.width = CGRectGetWidth(curr.frame) + (CGRectGetWidth(next.frame)-CGRectGetWidth(curr.frame))*changeRatio;
                }
                
                self.indicatorView.frame = r;
            }
        }
    }
    else if(scrollView.contentOffset.x<lastIndex*pageWidth){
//        NSLog(@"<<<<slide from right to left");
        NSInteger theCurrent = lastIndex;

        if(theCurrent >= 1){
            XIPagerBarItem *curr = _buttonItems[theCurrent];
            XIPagerBarItem *prev = _buttonItems[theCurrent-1];
            
            CGFloat changeRange = theCurrent*[UIScreen portraitWidth] - scrollView.contentOffset.x;
            float changeRatio = changeRange/pageMaxChangeRange;
            
            if(_titleColorTransitionSupported && changeRatio-1<0.0001){
                UIColor *_colorForNormal = curr.titleColorForNormalState;
                UIColor *_colorForSelected = curr.titleColorForSelectedState;
                
                CGFloat tmpR = _colorForSelected.rValue + (_colorForNormal.rValue-_colorForSelected.rValue)*changeRatio;
                CGFloat tmpG = _colorForSelected.gValue + (_colorForNormal.gValue-_colorForSelected.gValue)*changeRatio;
                CGFloat tmpB = _colorForSelected.bValue + (_colorForNormal.bValue-_colorForSelected.bValue)*changeRatio;
                CGFloat tmpA = _colorForSelected.aValue;
                [curr setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateNormal];
                [curr setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateSelected];
                
                tmpR = _colorForNormal.rValue + (_colorForSelected.rValue-_colorForNormal.rValue)*changeRatio;
                tmpG = _colorForNormal.gValue + (_colorForSelected.gValue-_colorForNormal.gValue)*changeRatio;
                tmpB = _colorForNormal.bValue + (_colorForSelected.bValue-_colorForNormal.bValue)*changeRatio;
                tmpA = _colorForNormal.aValue;
                [prev setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateNormal];
                [prev setTitleColor:[UIColor colorWithRed:tmpR green:tmpG blue:tmpB alpha:tmpA] forState:UIControlStateSelected];
            }
            
            CGPoint c = self.indicatorView.center;
            c.x = curr.center.x - (curr.center.x - prev.center.x)*changeRatio;
            self.indicatorView.center = c;
            
            if(!self.isItemWidthFixed){
                
                CGRect r = self.indicatorView.frame;
                if(self.adjustIndicatorWidthAsTitle && curr.fitSize.width != prev.fitSize.width){
                    r.size.width = curr.fitSize.width + (prev.fitSize.width-curr.fitSize.width)*changeRatio;
                }
                else if(!self.adjustIndicatorWidthAsTitle && CGRectGetWidth(prev.frame) != CGRectGetWidth(curr.frame)){
                    r.size.width = CGRectGetWidth(curr.frame) + (CGRectGetWidth(prev.frame)-CGRectGetWidth(curr.frame))*changeRatio;
                }
                self.indicatorView.frame = r;
            }
        }
    }
}

@end

@implementation XIPagerBarItem
{
    CGSize cachedSize;
    BOOL titleChanged;
    
    UIFont *_originalFont;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    titleChanged = YES;
}

- (void)setTitleColorForNormalState:(UIColor *)titleColorForNormalState
{
    if(_titleColorForNormalState){
        [_titleColorForNormalState resetRGBValues];
    }
    _titleColorForNormalState = titleColorForNormalState;
    [self setTitleColor:_titleColorForNormalState forState:UIControlStateNormal];
}

- (void)setTitleColorForSelectedState:(UIColor *)titleColorForSelectedState
{
    if(_titleColorForSelectedState){
        [_titleColorForSelectedState resetRGBValues];
    }
    _titleColorForSelectedState = titleColorForSelectedState;
    [self setTitleColor:_titleColorForSelectedState forState:UIControlStateSelected];
}

- (void)setTitleLabelFont:(UIFont *)font
{
    _originalFont = font;
    self.titleLabel.font = font;
    
    titleChanged = YES;
}

- (void)setTitleLabelFontAsStateChanged:(UIFont *)font
{
    self.titleLabel.font = font;
    
    titleChanged = YES;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self fitSize];
}

- (CGSize)fitSize
{
    if(CGSizeEqualToSize(cachedSize, CGSizeZero) || titleChanged){
        
        NSString *_title = [self titleForState:UIControlStateNormal];
        if(_title&&_title.length>0){
            CGFloat itemMaxWidth = [UIScreen portraitWidth]/2;
            CGSize strSize = [_title boundingRectWithSize:CGSizeMake(itemMaxWidth, 60)
                                                  options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[self fontForState:self.selected?UIControlStateSelected:UIControlStateNormal]}
                                                  context:nil].size;
            CGFloat frameWidth = strSize.width+self.contentEdgeInsets.left+self.contentEdgeInsets.right;
            cachedSize.width = frameWidth;
            cachedSize.height = CGRectGetHeight(self.frame);
            
            titleChanged = NO;
        }
    }
    
    return cachedSize;
}

- (UIFont *)fontForState:(UIControlState)state
{
    // 是否支持选中状态的加粗效果
//    if(state==UIControlStateSelected){
//        return [UIFont boldSystemFontOfSize:_originalFont.pointSize];
//    }
    return _originalFont;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [UIView transitionWithView:self duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if(selected){
            [self setTitleLabelFontAsStateChanged:[self fontForState:UIControlStateSelected]];
            [self setTitleColor:self.titleColorForSelectedState forState:UIControlStateSelected];
        }
        else{
            [self setTitleLabelFontAsStateChanged:[self fontForState:UIControlStateNormal]];
            [self setTitleColor:self.titleColorForNormalState forState:UIControlStateNormal];
        }
    } completion:nil];
}

@end
