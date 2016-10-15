//
//  DataBaseHelper.h
//  lessonSqlite
//
//  Created by lanouhn on 15-2-3.
//  Copyright (c) 2015年 XZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Account.h"

@class Contact;
/**
 *  DataBaseHelper数据库操作类。实现对数据库的增删改查。
 
 */
@interface DataBaseHelper : NSObject
//提供创建单例对象的方法
+ (DataBaseHelper *)sharedHelper;
//提供返回分区个数的接口
+ (NSInteger)numberOfSections;
//提供返回分区对应行数的接口
+ (NSInteger)numberOfRowsInSection:(NSInteger)section;
//提供返回分区对应的title的方法
+ (NSString *)titleForHeaderInSection:(NSInteger)section;
//提供tableView分区索引的方法
+ (NSArray *)sectionIndexTitles;
//提供返回数据对象的接口
+ (Account *)accountIndextPath:(NSIndexPath *)indexPath;
//返回是否需要删除分区
+ (BOOL)isNeedToDeleteSection:(NSInteger)section;
//删除分区的接口
+ (void)deleteSection:(NSInteger)section;
//删除一行的接口
+ (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;
//添加联系人接口
+ (BOOL)addcontactPerson:(Contact *)contact;
//更新数据库中的数据
+ (void)updateDataBaseWithAccount:(Account *)account;
//能够统计所有联系人个数
+ (NSInteger)totalNumberOfContacts;
//存储唯一ID
+ (NSInteger)uniqueID;

//更新联系人,contact -- 修改之后的联系人对象  sourceName -- 修改之前的联系人姓名
+ (void)updateContact:(Contact *)contact withSourceName:(NSString *)sourceName;


+ (void)readDataFromDataBase;

+ (void)createTableInDataBase;

@end




//为数据操作类，添加分类，分类中创建指令集
@interface DataBaseHelper (CreateStatement)
+ (sqlite3_stmt *)createTableStatement;//创建表的指令集
+ (sqlite3_stmt *)createSelectStatement;//表的查询指令集
+ (sqlite3_stmt *)createUpdateStatement;
+ (sqlite3_stmt *)createInsertStatement;//插入指令集
+ (sqlite3_stmt *)createDeleteStatement;//表的删除指令集

@end