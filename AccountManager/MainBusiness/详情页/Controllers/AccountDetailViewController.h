//
//  AccountDetailViewController.h
//  AccountManager
//
//  Created by 张祥 on 16/5/14.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

typedef void(^EditDone)();


@interface AccountDetailViewController : UIViewController
@property (strong, nonatomic)Account *account;
@property (strong, nonatomic)UIImage *accountImage;


- (void)editSuccess:(EditDone)editDone;

@end
