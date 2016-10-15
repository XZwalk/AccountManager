//
//  BaseNavigationController.m
//  AddressBook_Primary
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "BaseNavigationController.h"
@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //1.修改导航条的颜色
    self.navigationBar.barTintColor = [UIColor colorWithRed:50 / 255.0 green:170 / 255.0 blue:119 / 255.0 alpha:1.0];
    //2.修改导航条的渲染颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    //3.修改title文字的颜色
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.titleTextAttributes = dic;
    
    //开启屏幕边缘手势
    self.interactivePopGestureRecognizer.delegate = nil;
}
//设置状态条的样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
