//
//  PermissionViewController.m
//  AccountManager
//
//  Created by 张祥 on 16/5/14.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "PermissionViewController.h"
#import "ProgressHUD.h"
#import "PositionAdjustorAccordingKeyBoard.h"

@interface PermissionViewController ()

@property (strong, nonatomic) IBOutlet UITextField *checDigitTextField;
@property (strong, nonatomic) UIImageView *navBarHairlineImageView;

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    _navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

//处理导航栏设置为白色时底部出现一条黑线的问题
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _navBarHairlineImageView.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:50 / 255.0 green:170 / 255.0 blue:119 / 255.0 alpha:1.0];

}

-(void) viewWillAppear:(BOOL)animated
{
    self.enableAdjustPositionAccordingKeyBoard = YES;
    [super viewWillAppear:animated];
    _navBarHairlineImageView.hidden = YES;

}

#pragma event response

- (IBAction)nextAction:(UIButton *)sender {
    [Tools restoreAccount:self.checDigitTextField.text];
    [self performSegueWithIdentifier:@"toHomePage" sender:nil];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
