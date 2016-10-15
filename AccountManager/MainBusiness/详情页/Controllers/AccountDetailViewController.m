//
//  AccountDetailViewController.m
//  AccountManager
//
//  Created by 张祥 on 16/5/14.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "DataBaseHelper.h"
#import "PositionAdjustorAccordingKeyBoard.h"
#import "RSA.h"

#define PrivateKey   @"-----BEGIN PRIVATE KEY-----MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALFSxIafluXVupZgq+TT4RAOr+3kKk0VhjcthGy+O/kWVTsZdvUuuxhf5AIKq/W1Q2elaeglZvWs+zmySqrSd5BKu6qtrXKybavUh0rMxrivK0kFsxKzZQYfX3xEDM6KAOQAQWvcgUmDbBXqVg4qs/7MzggMSEZzw1a0u5lSzP/FAgMBAAECgYBmEHfh7RXT8LNXPwlxyqrurSWCTiQy/kKkm+RvGwg2FS61t7CK63zxSLBapH3aDZ1gmQtefbjHi+uGiCMGM+JxC5C3RTwMJvE+ChTOOZZNsHPaBvp4n1KtRR3kDeDyXRq87SbPGnkFLx2QhTyColAm9OENxzyWPA2WEeCnALk5uQJBAOD0ryxPz9oE0pqyPQSk3/lHvZkY62Fqu+T/KanJjOos52FC+uWqnNxA/rHuJ7UlGGgtzZ8B8ePXKbiHstNbDSsCQQDJy056MLa1oEmZ6N5JiI7lP4MLR88cXoJCOiXCT064zvbvSyB7NwuABM3FgOqGiFzdWArrYPpIsVl+nuBr3w7PAkEAg6BIW2o72XrW7DN8ppn+f7LtioZdO/wjAyQWccWAEYnCvVNe0UGaVPomzV/nlgOlm1epp++QZNuCCvpDtY3iTwJBAKxdP0Q51ebf6d5QPYbb4QrKLDn3dV4LEAJXvqbxrRFInz4Ykr8MboNEFyuLiUeutHvQV0tkg4SSEBqKxLD/T5sCQF80JLu8BljmW+jMR4542HBz6LDf4OA9HcqkXB09X4meziotN2GfWCsA+eHigRvIoi32EaYLQM+XUnXRrEdSbH4=-----END PRIVATE KEY-----"


@interface AccountDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *accountImageView;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@property (copy, nonatomic) EditDone editDone;
@end

@implementation AccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.accountImageView.image = self.accountImage;
    self.accountImageView.layer.cornerRadius = 10;
    self.accountImageView.layer.masksToBounds = YES;
    
    
    NSString *userName = [RSA decryptString:self.account.userName privateKey:PrivateKey];
    
    NSString *password = [RSA decryptString:self.account.password privateKey:PrivateKey];
    NSString *phoneNumber = [RSA decryptString:self.account.bindingPhoneNumber privateKey:PrivateKey];
    
    
    self.userNameTextField.text = userName;
    self.passwordTextField.text = password;
    self.phoneNumberTextField.text = phoneNumber;
    
    
    
    //设置编辑按钮
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //关闭控件交互
    [self dependUserInterationEnabled:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.enableAdjustPositionAccordingKeyBoard = YES;
    [super viewWillAppear:animated];
}

#pragma private apis 
//控制控件是否可交互
- (void)dependUserInterationEnabled:(BOOL)enabled {
    self.userNameTextField.userInteractionEnabled = enabled;
    self.passwordTextField.userInteractionEnabled = enabled;
    self.phoneNumberTextField.userInteractionEnabled = enabled;
}

#pragma event response
//点击Edit按钮触发
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self dependUserInterationEnabled:editing];//控件交互
    if (editing == NO) {
        //当点击Done时，取消编辑状态，保存数据
        //修改内存数据
        self.account.userName = self.userNameTextField.text;
        self.account.password = self.passwordTextField.text;
        self.account.bindingPhoneNumber = self.phoneNumberTextField.text;
        
        //更新数据库
        [DataBaseHelper updateDataBaseWithAccount:self.account];
        
        self.editDone();
    }
}

- (void)editSuccess:(EditDone)editDone {
    self.editDone = editDone;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
