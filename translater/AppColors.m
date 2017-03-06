//
//  AppColors.m
//  translater
//
//  Created by Tony Hrabovskyi on 3/6/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import <UIKit/UIColor.h>
#import "AppColors.h"

#define UIColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0]

@implementation AppColors

+ (UIColor *)firstColor {
    static UIColor *firstColor;
    if (firstColor == nil) {
        firstColor = UIColorFromRGB(0xFF95A5);
    }
    return firstColor;
}

+ (UIColor *)secondColor {
    static UIColor *secondColor;
    if (secondColor == nil) {
        secondColor = UIColorFromRGB(0x335370);
    }
    return secondColor;
}

+ (UIColor *)seperatorColor {
    static UIColor *seperatorColor;
    if (seperatorColor == nil) {
        seperatorColor = UIColorFromRGB(0xBBBBBB);
    }
    return seperatorColor;
}

+ (UIColor *)backgroundColor {
    static UIColor *backgroundColor;
    if (backgroundColor == nil) {
        backgroundColor = UIColorFromRGB(0xFFF5FF);
    }
    return backgroundColor;
}

@end
