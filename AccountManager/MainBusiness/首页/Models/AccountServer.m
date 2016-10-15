//
//  AccountServer.m
//  AccountManager
//
//  Created by 张祥 on 16/5/13.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "AccountServer.h"

#define kRequestSuccess   @"成功"
#define kRequestFaild     @"失败"

#define kRequestAccountUrl  @"http://7xu18j.com1.z0.glb.clouddn.com/%@?v=%@"


@implementation AccountServer

- (void)requestAccountListData:(RequestSuccess)requestSuccess fail:(RequestFaild)requestFaild {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *timeStr = [self getTimestampStr];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kRequestAccountUrl, [Tools getAccount], timeStr]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            [self writeSqliteData:data toLocalFile:[Tools getAccount] requestSuccess:requestSuccess fail:requestFaild];
            
        } else {
            
            NSString *mark = kRequestFaild;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                requestSuccess(mark);
                
            });
            
            
        }
    }];
    
    [task resume];
    
}

- (void)writeSqliteData:(NSData *)fileData toLocalFile:(NSString *)fileName requestSuccess:(RequestSuccess)requestSuccess fail:(RequestFaild)requestFaild{
    NSString * fullPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    fullPath = [fullPath stringByAppendingPathComponent:fileName];
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        if (NO == [[NSFileManager defaultManager] createFileAtPath:fullPath contents:nil attributes:nil]) {
            DLog(@"------------------file create fail------------------");
        }
    }
    
    if (NO == [fileData writeToFile:fullPath atomically:YES]) {
        
        NSString *mark = kRequestFaild;
        
        //该方法在子线程执行, 会导致block也在子线程调用, 然而在外面的block里面又执行了tableView刷新的方法, 把UI操作放在子线程就会出问题, 所以要把block的调用放在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            requestSuccess(mark);
        });
        
        
        DLog(@"------------------file write fail------------------");
    }else
    {
        NSString *mark = kRequestSuccess;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            requestSuccess(mark);
        });
        
        DLog(@"------------------file write success------------------");
    }
}


- (NSString *)getTimestampStr {
    NSDate *dateNow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]];
    DLog(@"%@", timeSp);
    
    return timeSp;
}

@end
