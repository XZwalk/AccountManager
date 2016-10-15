//
//  Tools.m
//  Class1002
//
//  Created by 张祥 on 16/3/27.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "Tools.h"

static NSString *account;

@implementation Tools

+ (NSString *)getTimestampStr {
    NSDate *dateNow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]];
    DLog(@"%@", timeSp);
    
    return timeSp;
}

+ (void)restoreAccount:(NSString *)accountInfo {
    account = accountInfo;
}

+ (NSString *)getAccount {
    return account;
}
@end
