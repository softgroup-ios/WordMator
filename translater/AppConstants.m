//
//  AppConstants.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/22/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

+ (NSDictionary*)allLenguage {
    
    static NSDictionary *allLenguageDict;
    if (allLenguageDict == nil) {
        allLenguageDict = @{
                            @"Azerbaijan":@"az",
                            @"Albanian":@"sq",
                            @"Amharic":@"am",
                            @"English":@"en",
                            @"Arab":@"ar",
                            @"Armenian":@"hy",
                            @"Afrikaans":@"af",
                            @"Basque":@"eu",
                            @"Bashkir":@"ba",
                            @"Belarusian":@"be",
                            @"Bengal":@"bn",
                            @"Bulgarian":@"bg",
                            @"Bosnian":@"bs",
                            @"Welsh":@"cy",
                            @"Hungarian":@"hu",
                            @"Vietnamese":@"vi",
                            @"Haitian":@"ht",
                            
                            
                            };
    }
    return allLenguageDict;
}
@end
