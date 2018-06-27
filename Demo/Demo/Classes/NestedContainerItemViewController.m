//
//  NestedContainerItemViewController.m
//  Demo
//
//  Created by YXLONG on 2018/6/27.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "NestedContainerItemViewController.h"
#import "ContainerTableView.h"
#import "Masonry.h"

static NSString *reusedCellId = @"reusedCellId";

@interface NestedContainerItemViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTable;
}
@end

@implementation NestedContainerItemViewController
@synthesize canScroll;
@synthesize containerVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _contentTable = [[ContainerTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTable.estimatedRowHeight = 0;
    _contentTable.estimatedSectionHeaderHeight = 0;
    _contentTable.estimatedSectionFooterHeight = 0;
    _contentTable.backgroundColor = [UIColor whiteColor];
    _contentTable.showsVerticalScrollIndicator = NO;
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    _contentTable.scrollsToTop = YES;
    [self.view addSubview:_contentTable];
    [_contentTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_contentTable registerClass:[UITableViewCell class] forCellReuseIdentifier:reusedCellId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15+arc4random_uniform(10);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell - %ld", (long)indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!self.canScroll){
        scrollView.contentOffset = CGPointZero;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY<=0){
        self.canScroll = NO;
        scrollView.contentOffset = CGPointZero;
        
        if(self.containerVC){
            self.containerVC.canScroll = YES;
        }
    }
}

@end
