//
//  DataBaseHelper.m
//  lessonSqlite
//
//  Created by lanouhn on 15-2-3.
//  Copyright (c) 2015年 XZH. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DataBaseHelper.h"
#import "DataBase.h"
#import "RSA.h"


#define PublicKey   @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxUsSGn5bl1bqWYKvk0+EQDq/t5CpNFYY3LYRsvjv5FlU7GXb1LrsYX+QCCqv1tUNnpWnoJWb1rPs5skqq0neQSruqra1ysm2r1IdKzMa4rytJBbMSs2UGH198RAzOigDkAEFr3IFJg2wV6lYOKrP+zM4IDEhGc8NWtLuZUsz/xQIDAQAB-----END PUBLIC KEY-----"




#define kDataFinishNSNotification  @"dataFinish"

@interface DataBaseHelper ()

@property (nonatomic, retain) NSMutableDictionary *accountDic;
@property (nonatomic, retain) NSMutableArray *orderedKeys;//存储排好序的key
@end



@implementation DataBaseHelper
//Lazy loading
- (NSMutableDictionary *)accountDic {
    if (!_accountDic) {
        self.accountDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _accountDic;
}

//存储唯一ID
+ (NSInteger)uniqueID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //从沙盒中获取唯一的ID
    NSInteger index = [[userDefaults objectForKey:@"conID"] integerValue];
    //将之前的ID + 1 之后的值存储到沙盒中，方便下次获取和当前不同的ID
    [userDefaults setObject:@(index + 1) forKey:@"conID"];
    //立即同步
    [userDefaults synchronize];
    return index;
}

static DataBaseHelper *helper = nil;
//提供创建单例对象的方法+创建表
+ (DataBaseHelper *)sharedHelper {
    @synchronized(self) {
        if (!helper) {
            helper = [[DataBaseHelper alloc] init];
//            [self createTableInDataBase];//创建表
//            [helper readDataFromDataBase];
        }
    }
    return helper;
}
//在数据库中创建表
+ (void)createTableInDataBase {
    sqlite3_stmt *stmt = [self createTableStatement];
    if (sqlite3_step(stmt)) {
        NSLog(@"创建表成功");
    }
    sqlite3_finalize(stmt);
    [DataBase closeDataBase];
}
//从数据库中读取数据
+ (void)readDataFromDataBase {
    //5.获取指令集
    sqlite3_stmt *stmt = [self createSelectStatement];
    
    
    
    NSMutableDictionary *accountDic = [DataBaseHelper sharedHelper].accountDic;
    
    [accountDic removeAllObjects];
    
    //6.绑定SQL语句中的参数，对应？
    //7.执行SQL语句，对数据库操作。
    //对于查询操作，会有多条数据，通过while循环一条一条取出
    //一旦为SQLITE_ROW就代表还有一条数据还未读出，当把所有的数据读取完毕后，sqlite3_step结果自动变成SQLITE_DONE
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //获取表中的一条数据,0代表表中的索引
        NSInteger iD = sqlite3_column_int(stmt, 0);
        char *accountName = (char *)sqlite3_column_text(stmt, 1);
        char *userName = (char *)sqlite3_column_text(stmt, 2);
        char *password = (char *)sqlite3_column_text(stmt, 3);
        char *bingingPhoneNumber = (char *)sqlite3_column_text(stmt, 4);
        char *mark = (char *)sqlite3_column_text(stmt, 5);

        //将C语言字符串转为OC字符串对象
        NSString *accountNameStr = [NSString stringWithUTF8String:accountName];
        NSString *userNameStr = [NSString stringWithUTF8String:userName];
        NSString *passwordStr = [NSString stringWithUTF8String:password];
        NSString *bingingPhoneNumberStr = [NSString stringWithUTF8String:bingingPhoneNumber];
        NSString *markStr = [NSString stringWithUTF8String:mark];

        Account *account = [Account accountWithAccID:iD mark:markStr accountName:accountNameStr userName:userNameStr password:passwordStr bindingPhoneNumber:bingingPhoneNumberStr];
        
        //获取分组名称
        NSString *key = account.mark;
        //根据key从字典中取出对应的数组
        NSMutableArray *groupArr = accountDic[key];
        //如果groupArr为空说明之前字典中没有对应的分组，则创建
        if (!groupArr) {
            //创建数组
            groupArr = [NSMutableArray arrayWithCapacity:1];
            //将元素添加到字典中
            [accountDic setObject:groupArr forKey:key];
        }
        //将contact对象放进数组中
        [groupArr addObject:account];
        
    }
    
     ;

    //获取到排好序的key值
    [DataBaseHelper sharedHelper].orderedKeys = [[[accountDic allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    //8.释放操作数据库时的系统资源
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataFinishNSNotification object:nil];
    
    sqlite3_finalize(stmt);
    //9.关闭shujuk
    [DataBase closeDataBase];
}
//提供返回分区个数的接口
+ (NSInteger)numberOfSections {
    NSMutableArray *orderedKeys = [DataBaseHelper sharedHelper].orderedKeys;
    return orderedKeys.count;
}
//提供返回分区对应行数的接口
+ (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *orderedKeys = [DataBaseHelper sharedHelper].orderedKeys;
    NSMutableDictionary *addressDic = [DataBaseHelper sharedHelper].accountDic;
    NSString *key = orderedKeys[section];
    
    return [addressDic[key] count];
}
//提供返回分区对应的title的方法
+ (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSMutableArray *orderedKeys = [DataBaseHelper sharedHelper].orderedKeys;
    NSString *key = orderedKeys[section];

    return key;
}
//提供tableView分区所以的方法
+ (NSArray *)sectionIndexTitles {
    NSMutableArray *orderedKeys = [DataBaseHelper sharedHelper].orderedKeys;

    return orderedKeys;
}
//提供返回数据对象的接口
+ (Account *)accountIndextPath:(NSIndexPath *)indexPath {
    NSMutableArray *orderedKeys = [DataBaseHelper sharedHelper].orderedKeys;
    NSMutableDictionary *addressDic = [DataBaseHelper sharedHelper].accountDic;
    NSString *key = orderedKeys[indexPath.section];
    NSArray *sectionArray = addressDic[key];
    if (sectionArray.count > indexPath.row) {
        Account *account = sectionArray[indexPath.row];
        return account;
    }
    return nil;
}
//返回是否需要删除分区
+ (BOOL)isNeedToDeleteSection:(NSInteger)section {
    return [helper.accountDic[helper.orderedKeys[section]] count] == 1 ? YES : NO;
}
//删除分区的接口
+ (void)deleteSection:(NSInteger)section {
//1.对数据进行修改  -- 删除数据库中的一条数据
    NSString *key = helper.orderedKeys[section];
    NSMutableArray *groupArr = helper.accountDic[key];
    //获取数组中的元素
    Account *acc = [groupArr lastObject];
    [self deleteRowInDataBaseByConID:acc.accId];
    
//2.对内存做修改  --
    //从字典中移除对应的元素
    [helper.accountDic removeObjectForKey:helper.orderedKeys[section]];
    //从排好序的key值中移除对应的key
    [helper.orderedKeys removeObjectAtIndex:section];
    
}
//删除一行的接口
+ (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    Account *acc = [self accountIndextPath:indexPath];
//1.对数据库修改，删除数据库中对应的一条数据
    [self deleteRowInDataBaseByConID:acc.accId];
    
//2.对内存做修改 -- 移除数组中对应的元素
    [helper.accountDic[helper.orderedKeys[indexPath.section]] removeObjectAtIndex:indexPath.row];
}
//添加联系人接口
//+ (BOOL)addcontactPerson:(Contact *)contact {
//    //安全处理  --- 姓名 和 联系方式 不能为空
//    //1.contact.con_name为空没有指向contact.con_name = nil，2.指向的空间没有数据@""。
//    if (![contact.con_name length] || ![contact.con_phone length]) {
//        return NO;//添加失败
//    }
////一.对数据库修改 --- 往数据库中插入一条数据
//    [self insertIntoDataBaseWithContact:contact];
////二.对内存进行修改
//    //1.获取姓名首字母
//    NSString *key = [contact.con_name firstElement];
//    //2.根据key从字典中取出对应的数组
//    NSMutableArray *groupArr = helper.addressDic[key];
//    //3.判断字典中是否存在对应的分组
//    if (!groupArr) {
//        //4.创建分组
//        groupArr = [NSMutableArray arrayWithCapacity:1];
//        //添加到字典中
//        [helper.addressDic setObject:groupArr forKey:key];
//        //5.重新获取字典中的key,并且升序排序.
//        [helper.orderedKeys addObject:key];
//        [helper.orderedKeys sortUsingSelector:@selector(compare:)];
//    }
//    //6.将元素添加到数组中
//    [groupArr addObject:contact];
//    return YES;
//}
//删除数据库中的一条数据
+ (void)deleteRowInDataBaseByConID:(NSInteger)conID {

    //5.获取删除指令集
    sqlite3_stmt *stmt = [self createDeleteStatement];
    //6.绑定参数
    sqlite3_bind_int(stmt, 1, (int)conID);
    //7.执行SQL语句对数据库进行操作。
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        NSLog(@"删除数据成功");
    }
    //8.释放数据库操作时使用的系统资源
    sqlite3_finalize(stmt);
    //9.关闭数据库
    [DataBase closeDataBase];
}
//往数据库中插入一条数据
//+ (void)insertIntoDataBaseWithContact:(Contact *)contact {
//    //5.获取插入指令集
//    sqlite3_stmt *stmt = [self createInsertStatement];
//    //6.绑定参数
//    sqlite3_bind_int(stmt, 1, (int)contact.con_id);
//    sqlite3_bind_text(stmt, 2, [contact.con_name UTF8String], -1, nil);
//    sqlite3_bind_text(stmt, 3, [contact.con_gendar UTF8String], -1, nil);
//    sqlite3_bind_text(stmt, 4, [contact.con_age UTF8String], -1, nil);
//    sqlite3_bind_text(stmt, 5, [contact.con_phone UTF8String], -1, nil);
//    sqlite3_bind_text(stmt, 6, [contact.con_motto UTF8String], -1, nil);
//    
//    //将UIImage对象转成NSDate
//    NSData *data = UIImagePNGRepresentation(contact.con_image);
//    sqlite3_bind_blob(stmt, 7, data.bytes, (int)data.length, nil);
//    
//    //7.执行SQL语句，对数据库操作
//    if (sqlite3_step(stmt) == SQLITE_DONE) {
//        NSLog(@"插入成功");
//    }
//    //8.释放资源
//    sqlite3_finalize(stmt);
//    //9.关闭数据库
//    [DataBase closeDataBase];
//}
//更新数据库中的数据
+ (void)updateDataBaseWithAccount:(Account *)account {
    sqlite3_stmt *stmt = [self createUpdateStatement];
    //这里的1,2,3,4是问号的索引, 索引从1开始, 必须与[self createUpdateStatement]方法中创建的sqlite语句中的问号一一对应, 不然肯定会更新失败.
    
    
    NSString *userName = [RSA encryptString:account.userName publicKey:PublicKey];
    NSString *password = [RSA encryptString:account.password publicKey:PublicKey];
    NSString *phoneNumber = [RSA encryptString:account.bindingPhoneNumber publicKey:PublicKey];
    
    sqlite3_bind_text(stmt, 1, [userName UTF8String], -1, nil);
    sqlite3_bind_text(stmt, 2, [password UTF8String], -1, nil);
    sqlite3_bind_text(stmt, 3, [phoneNumber UTF8String], -1, nil);
    sqlite3_bind_int(stmt, 4, (int)account.accId);

    if (sqlite3_step(stmt) == SQLITE_DONE) {
        NSLog(@"更新数据库");
    }
    sqlite3_finalize(stmt);

    [DataBase closeDataBase];
}
//能够统计所有联系人个数
+ (NSInteger)totalNumberOfContacts {
    NSInteger totalCount = 0;//存储总的联系人数
    //对字典进行遍历获取到key
    for (NSString *key in helper.accountDic) {
        totalCount += [helper.accountDic[key] count];
    }
    return totalCount;
}

////更新联系人
//+ (void)updateContact:(Account *)account withSourceName:(NSString *)sourceName {
//    //1.判断是否需要移动分区
//    NSString *sourceKey = [sourceName firstElement];
//    NSString *desKey = [contact.con_name firstElement];
//    if ([sourceKey isEqualToString:desKey]) {
//        //更新数据库，不需要移动分区
//        [self updateDataBaseWithContact:contact];
//    } else {
//        //从原来分组中移除
//        //获取原来key对应的分组
//        NSMutableArray *sourceGroup = helper.addressDic[sourceKey];
//        //获取contact对象原来的位置
//        //(1)获取分区索引（根据sourceKey在orderedKey数组中的位置）
//        NSInteger section = [helper.orderedKeys indexOfObject:sourceKey];
//        //(2)获取行索引（根据对象获取在对应的数组中的索引）
//        NSInteger row = [sourceGroup indexOfObject:contact];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//        
//        if (sourceGroup.count == 1) {
//            [self deleteSection:section];//删除分区
//        } else {
//            [self deleteRowAtIndexPath:indexPath];//删除一行
//        }
//        //添加联系人
//        [self addcontactPerson:contact];
//    }
//
//}

@end








@implementation DataBaseHelper (CreateStatement)
//创建表的指令集
+ (sqlite3_stmt *)createTableStatement {
    //1.打开数据库
    sqlite3 *db = [DataBase openDataBase];
    //2.创建数据库指令集
    sqlite3_stmt *stmt = nil;
    //3.创建SQL语句
    NSString *createTableSQL = @"create table if not exists Contact(con_id integer primary key autoincrement, con_name text, con_gendar text, con_age text,  con_phone text, con_motto text, con_image blob)";
    //blob二进制流
    //4.语法检查（检查sql语句是否正确，检查数据库是否成功打开）
    //(1)bd -- 数据库地址 (2)sql语句 (3)aql语句的长度，-1不限制长度 (4)指令集 (5)预留参数
    int flag = sqlite3_prepare_v2(db, [createTableSQL UTF8String], -1, &stmt, nil);
    if (SQLITE_OK == flag) {
        NSLog(@"创建表语法检查正确");
        return stmt;
    }
    return nil;
}
//表的查询指令集
+ (sqlite3_stmt *)createSelectStatement {
    sqlite3 *db = [DataBase openDataBase];
    sqlite3_stmt *stmt = nil;
    //创建SQL语句
    NSString *selectSQL = @"select *from importance";
    //语法检查
    int flag = sqlite3_prepare_v2(db, [selectSQL UTF8String], -1, &stmt, nil);
    if (SQLITE_OK == flag) {
        return stmt;
    }
    return nil;
}
//修改指令集
+ (sqlite3_stmt *)createUpdateStatement {
    sqlite3 *db = [DataBase openDataBase];
    sqlite3_stmt *stmt = nil;
    NSString *createUpdateSQL = @"update importance set userName = ?, password = ?, bindingPhoneNumber = ? where id = ?";
    int flag = sqlite3_prepare_v2(db, [createUpdateSQL UTF8String], -1, &stmt, nil);
    if (SQLITE_OK == flag) {
        return stmt;
    }
    return nil;
}

//插入指令集
+ (sqlite3_stmt *)createInsertStatement {
    sqlite3 *db = [DataBase openDataBase];
    sqlite3_stmt *stmt = nil;
    NSString *createInsertSQL = @"insert into Contact(con_id, con_name, con_gendar, con_age,  con_phone, con_motto, con_image) values(?, ?, ?, ?, ?, ?,?)";
    int flag = sqlite3_prepare_v2(db, [createInsertSQL UTF8String], -1, &stmt, nil);
    if (SQLITE_OK == flag) {
        return stmt;
    }
    return nil;

}
//表的删除指令集
+ (sqlite3_stmt *)createDeleteStatement {
    sqlite3 *db = [DataBase openDataBase];
    sqlite3_stmt *stmt = nil;
    NSString *createDeleteSQL = @"delete from Contact where con_id = ?";
    int flag = sqlite3_prepare_v2(db, [createDeleteSQL UTF8String], -1, &stmt, nil);
    if (SQLITE_OK == flag) {
        return stmt;
    }
    return nil;
}


@end

