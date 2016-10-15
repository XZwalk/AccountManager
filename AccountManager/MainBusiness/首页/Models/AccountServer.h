//
//  AccountServer.h
//  AccountManager
//
//  Created by 张祥 on 16/5/13.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountServer : NSObject

- (void)requestAccountListData:(RequestSuccess)requestSuccess fail:(RequestFaild)requestFaild;

@end
