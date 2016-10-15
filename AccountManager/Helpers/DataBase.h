//
//  DataBase.h
//  lessonSqlite
//
//  Created by lanouhn on 15-2-3.
//  Copyright (c) 2015年 XZH. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  DataBase 是数据库管理类，只提供两个管理功能 打开数据库和关闭数据库。
    要操作数据库，需要导入libsqlite3.0.dylib 动态链接库
 */
#import <sqlite3.h>
@interface DataBase : NSObject

+ (sqlite3 *)openDataBase;//打开数据库
+ (void)closeDataBase;//关闭数据库
@end
