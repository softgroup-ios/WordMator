//
//  Translater.m
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Translater.h"


@interface Translater ()

@property(strong, nonatomic) id<TranslaterProtocol> delegate;

@end
static NSString* keyAPI = @"trnsl.1.1.20161231T110214Z.7b76d42f642da155.22591cff56e8452581acae08780cdd5e8da4ec10";
static NSString* baseRequest = @"https://translate.yandex.net/api/v1.5/tr.json/translate";


@implementation Translater

- (instancetype)initWithDelegate:(id<TranslaterProtocol>)delegate {
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        
    }
    return self;
}


- (void) translate:(NSString *)text and:(NSString*)lang {
    
    
    NSString *postDataString = [NSString stringWithFormat:@"key=%@&text=%@&lang=%@", keyAPI, text, lang];
//    NSDictionary *postDataJSON = @{ @"key":keyAPI,
//                                    @"text":text,
//                                    @"lang":lang
//                                   };
    
    NSURL *url = [NSURL URLWithString:baseRequest];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    //request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDataJSON options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPMethod = @"POST";

    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSArray *answerData;
        
        if (error) {
            NSLog(@"Error: \n%@", error);
            answerData = @[@"Error"];
        } else {
            
            NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", answer);
            NSInteger statusCode = [[answer valueForKey:@"code"] integerValue];
            
            if (statusCode == 200) {
                
                answerData = [answer valueForKey:@"text"];
                NSLog(@"Answer: \n%@", [[answer valueForKey:@"text"] firstObject]);
                
            } else {
                answerData = @[@"Error"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate receiveData:answerData];
        });
        
    }] resume];
    
    
}
@end
