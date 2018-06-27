//
//  NestedContainerViewController.m
//  Demo
//
//  Created by YXLONG on 2018/6/26.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "NestedContainerViewController.h"
#import "ImageBgHeaderView.h"
#import "NestedContainerViewController+Utility.h"
#import "Masonry.h"
#import "NestedContainerItemViewController.h"

#define kPageBarHeaderViewHeight 44

@interface NestedContainerViewController ()<UITableViewDelegate, UITableViewDataSource, PagerBarHeaderViewDelegate, PageContainerCellDelegate>
{
    NSArray *barTitles;
    
    UITableView *mainTable;
    PagerBarHeaderView *_pagerBarHeaderView;
}
- (XIPageContainerView *)pageContainerView;
@end

@implementation NestedContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.canScroll = YES;
    
    mainTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.estimatedRowHeight = 0;
    mainTable.estimatedSectionHeaderHeight = 0;
    mainTable.estimatedSectionFooterHeight = 0;
    mainTable.showsVerticalScrollIndicator = NO;
    mainTable.decelerationRate = UIScrollViewDecelerationRateFast;
    mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:mainTable atIndex:0];
    [self.view addSubview:mainTable];
    [mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    mainTable.tableHeaderView = [[ImageBgHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 164)];
    
    barTitles = @[@"One",@"Two",@"Three", @"Four", @"Five"];
    [self scrollViewDidScroll:mainTable];
}

- (PagerBarHeaderView *)pagerBarHeaderView
{
    if(!_pagerBarHeaderView){
        _pagerBarHeaderView = [[PagerBarHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kPageBarHeaderViewHeight) itemsTitles:barTitles];
        _pagerBarHeaderView.delegate = self;
    }
    return _pagerBarHeaderView;
}

#pragma mark-- PagerBarHeaderViewDelegate method

- (void)pageBarViewDidChange:(NSInteger)newSelectedIndex
{
    self.pageContainerView.selectedIndex = newSelectedIndex;
}

#pragma mark-- UITableViewDelegate&UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return kPageBarHeaderViewHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.pagerBarHeaderView.barSelectedIndex = 0;
    return self.pagerBarHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight(self.view.bounds)-kPageBarHeaderViewHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ReusedCell";
    PageContainerCell *cell = (PageContainerCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){
        cell = [[PageContainerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID viewController:self];
        cell.delegate = self;
    }
    if(self.pagerBarHeaderView){
        cell.pageContainerView.customTabBar = self.pagerBarHeaderView.pageBarView;
    }
    else{
        NSLog(@"self.pageBarHeaderView.pageBarView==nil");
    }
    return cell;
}

#pragma mark-- PageContainerCellDelegate methods

- (NSInteger)numberOfPages
{
    return barTitles.count;
}

- (UIViewController *)pageControllerAtIndex:(NSInteger)index
{
    NestedContainerItemViewController *vc = [[NestedContainerItemViewController alloc] init];
    vc.containerVC = self;
    return vc;
}

- (XIPageContainerView *)pageContainerView
{
    UITableViewCell *visibleCell = [mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(visibleCell && [visibleCell isKindOfClass:[PageContainerCell class]]){
        PageContainerCell *cCell = (PageContainerCell *)visibleCell;
        return cCell.pageContainerView;
    }
    return nil;
}

- (void)setCanScroll:(BOOL)canScroll
{
    _canScroll = canScroll;
    mainTable.scrollsToTop = _canScroll;
    
    if(self.pageContainerView){
        for(NSInteger i=0;i<barTitles.count;i++){
            UIViewController *vc = [self.pageContainerView getPageAtIndex:i];
            if([vc isKindOfClass:[NestedContainerItemViewController class]]){
                ((NestedContainerItemViewController *)vc).canScroll = !canScroll;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat pageContainerOffsetY = [mainTable rectForSection:0].origin.y;
    //    DebugLog(@"%f, %f", offsetY, pageContainerOffsetY);
    
    if (offsetY < 0) {
        
        ImageBgHeaderView *hView = (ImageBgHeaderView *)mainTable.tableHeaderView;
        if(hView){
            CGFloat offsetX;
            offsetX = offsetY*CGRectGetWidth(hView.bgView.frame)/CGRectGetHeight(hView.bgView.frame);
            
            CGRect bgRect = CGRectMake(offsetX/2,
                                       offsetY,
                                       CGRectGetWidth([UIScreen mainScreen].bounds) - offsetX,
                                       mainTable.tableHeaderView.bounds.size.height - offsetY);
            hView.bgView.frame = bgRect;
        }
    }
    
    if(offsetY>=pageContainerOffsetY){
        scrollView.contentOffset = CGPointMake(0, pageContainerOffsetY);
        if(self.canScroll){
            self.canScroll = NO;
        }
    }
    else{
        if (!self.canScroll){
            scrollView.contentOffset = CGPointMake(0, pageContainerOffsetY);
        }
    }
}

@end
