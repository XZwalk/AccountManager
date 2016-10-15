//
//  DataBase.m
//  lessonSqlite
//
//  Created by lanouhn on 15-2-3.
//  Copyright (c) 2015年 XZH. All rights reserved.
//
#import "DataBase.h"

@implementation DataBase
static sqlite3 *sqlite = nil;//用来存储打开的数据库的地址
//打开数据库
+ (sqlite3 *)openDataBase {
    //当对数据库进行一次操作时，为了防止重复的打开数据库。
    //一旦之前打开了数据库，此时直接将数据库地址返回即可。
    if (sqlite) {
        return sqlite;//直接返回地址
    }
    //1.获取数据库文件路径
    NSString *filePath = [self dataBasePath];
    //2.打开数据库,UTF8String将OC的字符串对象转成C语言的字符串。
    sqlite3_open([filePath UTF8String], &sqlite);
    return sqlite;
}
//关闭数据库
+ (void)closeDataBase {
    if (sqlite) {
        sqlite3_close(sqlite);
        sqlite = nil;//防止别人再来操作
    }
}

//获取数据库路径
+ (NSString *)dataBasePath {
    //1.获取document文件夹路径
    NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //2.拼接上数据库文件路径
    return [documentpath stringByAppendingPathComponent:[Tools getAccount]];
}

@end
