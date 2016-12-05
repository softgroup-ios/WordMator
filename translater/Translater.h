//
//  Translater.h
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewController;

@interface Translater : NSObject

+ (void) setUpTranslate:(ViewController*)ourViewController;
+ (NSString*)translate:(NSString*)text and:(NSString*)lang;
@end
