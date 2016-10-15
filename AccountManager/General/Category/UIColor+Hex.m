//
//  UIColor+Hex.m
//  FUCK
//
//  Created by 曾明剑 on 14-3-12.
//  Copyright (c) 2014年 zmj. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)


+ (UIColor *)colorWithHex:(long)hexColor {
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end
