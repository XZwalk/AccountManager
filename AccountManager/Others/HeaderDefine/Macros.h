//
//  Macros.h
//  Class1002
//
//  Created by 张祥 on 16/3/26.
//  Copyright © 2016年 张祥. All rights reserved.
//

#ifndef Macros_h
#define Macros_h


#if defined(DEBUG) || defined(_DEBUG) || defined(__DEBUG)
#define TC_IOS_DEBUG
#endif

#ifdef TC_IOS_DEBUG

#define DLog(fmt, ...) \
NSLog(@"%@(%d)\n%s: " fmt, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
__PRETTY_FUNCTION__,## __VA_ARGS__)

#else

#define DLog(...);

#endif


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

typedef void(^RequestSuccess)(id resultObject);
typedef void(^RequestFaild)(id resultObject);

#define kSpaceName                 @"accountmanage"
#define kDataFinishNSNotification  @"dataFinish"


#endif /* Macros_h */
