//
//  ViewController.m
//  编辑文章
//
//  Created by 赵群涛 on 16/5/2.
//  Copyright © 2016年 愚非愚余. All rights reserved.
//

#import "ViewController.h"
#import "PublickViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.671 green:1.000 blue:0.584 alpha:1.000];
    

}
- (IBAction)btn:(id)sender {
    PublickViewController *pushlickVC = [[PublickViewController alloc]init];
    [self.navigationController pushViewController:pushlickVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
