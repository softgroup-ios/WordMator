//
//  Translater.m
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Translator.h"

@interface Translator ()
@property (weak, nonatomic) id<TranslatorDelegate> delegate;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*> *allLangsDictionary;

@end

@implementation Translator

static NSString *keyAPI = @"trnsl.1.1.20161231T110214Z.7b76d42f642da155.22591cff56e8452581acae08780cdd5e8da4ec10";
static NSString *translateURL = @"https://translate.yandex.net/api/v1.5/tr.json/translate";
static NSString *allLangsURL = @"https://translate.yandex.net/api/v1.5/tr.json/getLangs";

#pragma mark - public methods

- (instancetype)initWithDelegate:(id<TranslatorDelegate>)delegate {
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self loadAllLanguages];
    }
    return self;
}

- (void)translateText:(NSString*)text fromLang:(NSString*)fromLang onLang:(NSString*)toLang {
    
    fromLang = [_allLangsDictionary objectForKey:fromLang];
    toLang = [_allLangsDictionary objectForKey:toLang];
    
    if (fromLang == nil || toLang == nil) {
        NSError *tranlateError = [NSError errorWithDomain:@"translate.yandex" code:200 userInfo:@{NSLocalizedDescriptionKey:@"Language is not found"}];
        [self.delegate receiveText:nil withError:tranlateError];
        
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:translateURL]];
    
    NSString *postDataString = [NSString stringWithFormat:@"key=%@&text=%@&lang=%@-%@", keyAPI, text, fromLang, toLang];
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSArray *answerList;
        
        if (error) {
            NSLog(@"Error: \n%@", error);
            
        } else {
            
            NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", answer);
            NSInteger statusCode = [[answer valueForKey:@"code"] integerValue];
            
            if (statusCode == 200) {
                
                answerList = [answer valueForKey:@"text"];
                NSLog(@"Answer: \n%@", [[answer valueForKey:@"text"] firstObject]);
                
            } else {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate receiveText:answerList withError:error];
        });
        
    }] resume];
    
    
}


#pragma mark - private methods

- (void)loadAllLanguages {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:allLangsURL]];
    
    NSString *postDataString = [NSString stringWithFormat:@"key=%@&ui=en", keyAPI];
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *loadingError;
        
        if (error) {
            loadingError = error;
        } else {
            
            NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger statusCode = [[answer valueForKey:@"code"] integerValue];
            
            if (statusCode == 401) {
                //error
                loadingError = [NSError errorWithDomain:@"translate.yandex" code:200 userInfo:@{NSLocalizedDescriptionKey:@"Translate went wrong"}];
            } else {
                
                NSArray * keys = [[answer objectForKey:@"langs"] allKeys];
                _allLanguages = [[answer objectForKey:@"langs"] allValues];
                
                _allLangsDictionary = [NSDictionary dictionaryWithObjects:keys
                                                                  forKeys:_allLanguages];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate allLanguagesWasLoadedWithError:loadingError];
        });
    }] resume];
    
}

@end
