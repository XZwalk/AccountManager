//
//  Account.m
//  AccountManager
//
//  Created by 张祥 on 16/5/13.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "Account.h"

@implementation Account


//提供自定义的初始化方法
- (instancetype)initWithAccID:(NSInteger)accID mark:(NSString *)mark accountName:(NSString *)accountName userName:(NSString *)userName password:(NSString *)password bindingPhoneNumber:(NSString *)bindingPhoneNumber {
    self = [super init];
    if (self) {
        self.accId = accID;
        self.mark = mark;
        self.accountName = accountName;
        self.userName = userName;
        self.password = password;
        self.bindingPhoneNumber = bindingPhoneNumber;
    }
    return self;
}
//便利构造器
+ (instancetype)accountWithAccID:(NSInteger)accID mark:(NSString *)mark accountName:(NSString *)accountName userName:(NSString *)userName password:(NSString *)password bindingPhoneNumber:(NSString *)bindingPhoneNumber {
    return [[Account alloc] initWithAccID:accID mark:mark accountName:accountName userName:userName password:password bindingPhoneNumber:bindingPhoneNumber];
}

@end
