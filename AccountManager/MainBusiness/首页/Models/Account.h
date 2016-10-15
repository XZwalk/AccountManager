//
//  Account.h
//  AccountManager
//
//  Created by 张祥 on 16/5/13.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, assign) NSInteger accId;//存储唯一标识
@property (nonatomic, assign) NSString *mark;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *bindingPhoneNumber;

//提供自定义的初始化方法
- (instancetype)initWithAccID:(NSInteger)accID mark:(NSString *)mark accountName:(NSString *)accountName userName:(NSString *)userName password:(NSString *)password bindingPhoneNumber:(NSString *)bindingPhoneNumber;
//便利构造器
+ (instancetype)accountWithAccID:(NSInteger)accID mark:(NSString *)mark accountName:(NSString *)accountName userName:(NSString *)userName password:(NSString *)password bindingPhoneNumber:(NSString *)bindingPhoneNumber;


@end
