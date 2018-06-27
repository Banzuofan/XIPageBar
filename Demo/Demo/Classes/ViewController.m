//
//  ViewController.m
//  Demo
//
//  Created by YXLONG on 16/6/29.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "ViewController.h"
#import "XIPageBar.h"
#import "SpacingPageViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *contentTable;
    NSArray *arr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arr = @[@"ContianerViewController",
            @"SpacingPageViewController",
            @"CustomPageBarViewController",
            @"SegmentedControlViewController",
            @"NestedContainerViewController"];
    
    contentTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    contentTable.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    contentTable.delegate = self;
    contentTable.dataSource = self;
    [self.view addSubview:contentTable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedCellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class aClass = NSClassFromString(arr[indexPath.row]);
    UIViewController *vc = [[aClass alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
