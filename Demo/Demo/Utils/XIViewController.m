//
//  XIViewController.m
//  Demo
//
//  Created by YXLONG on 16/6/30.
//  Copyright © 2016年 XIPageBar. All rights reserved.
//

#import "XIViewController.h"

@implementation XIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-close"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(close)];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
