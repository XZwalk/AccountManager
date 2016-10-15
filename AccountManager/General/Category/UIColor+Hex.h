//
//  UIColor+Hex.h
//  FUCK
//
//  Created by 曾明剑 on 14-3-12.
//  Copyright (c) 2014年 zmj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

@end
