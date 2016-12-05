//
//  Translater.m
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Translater.h"
#import "ViewController.h"

static NSString* keyAPI = @"trnsl.1.1.20161130T081948Z.66e342e6aa29a74b.af57acd9946d4a68647632d115c0c67a4acf71c4";
static NSString* baseRequest = @"https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20161130T081948Z.66e342e6aa29a74b.af57acd9946d4a68647632d115c0c67a4acf71c4";
static ViewController* viewController;

@implementation Translater

+ (void) setUpTranslate:(ViewController*)ourViewController {
    
    viewController = ourViewController;
}

+ (NSString*) translate:(NSString *)text and:(NSString*)lang {
    

    
    NSString* request = [NSString stringWithFormat:@"%@&text=%@&lang=%@", baseRequest, text, lang];
    __block NSURL *url = [NSURL URLWithString:request];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSData *data = [NSData dataWithContentsOfURL:url];
//        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"response String = %@", ret);
        
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        NSString* answer;
        if (!error) {
            
            answer = [jsonDict objectForKey:@"text"][0];
        } else {
            
            answer = @"Error";
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [viewController takeAnswer:answer];
        });
    });
    
    
    return @"test";
}
@end
