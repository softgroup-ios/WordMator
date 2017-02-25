//
//  Translater.m
//  translater
//
//  Created by Tony Hrabovskyi on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "Translator.h"

@interface TranslateEntity ()

@end

@implementation TranslateEntity

- (instancetype)initWithLangFrom:(NSString*)langFrom
                       andLangOn:(NSString*)langOn
                        andInput:(NSString*)inputText {
    
    if (self = [super init]) {
        _langFrom = langFrom;
        _langOn = langOn;
        _inputText = inputText;
//        _outputText = @"";
        _isFavorite = FALSE;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_langFrom forKey:@"langFrom"];
    [aCoder encodeObject:_langOn forKey:@"langOn"];
    [aCoder encodeObject:_inputText forKey:@"inputText"];
    [aCoder encodeObject:_outputText forKey:@"outputText"];
    [aCoder encodeBool:_isFavorite forKey:@"isFavorite"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _langFrom = [aDecoder decodeObjectForKey:@"langFrom"];
        _langOn = [aDecoder decodeObjectForKey:@"langOn"];
        _inputText = [aDecoder decodeObjectForKey:@"inputText"];
        _outputText = [aDecoder decodeObjectForKey:@"outputText"];
        _isFavorite = [aDecoder decodeBoolForKey:@"isFavorite"];
        
    }
    return self;
}

@end


@interface Translator ()
@property (weak, nonatomic) id<TranslatorDelegate> delegate;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*> *allLangsDictionary;

@end

@implementation Translator

static NSString *keyAPI = @"trnsl.1.1.20161231T110214Z.7b76d42f642da155.22591cff56e8452581acae08780cdd5e8da4ec10";
static NSString *translateURL = @"https://translate.yandex.net/api/v1.5/tr.json/translate";
static NSString *allLangsURL = @"https://translate.yandex.net/api/v1.5/tr.json/getLangs";
static NSString *allLangsKey = @"AllSavedLanguages";
static NSString *historyKey = @"allHistory";

#pragma mark - public methods

- (instancetype)initWithDelegate:(id<TranslatorDelegate>)delegate {
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self loadAllLanguages];
        [self loadHistory];
        [[NSNotificationCenter defaultCenter]   addObserver:self
                                                   selector:@selector(appWillTerminate:)
                                                       name:UIApplicationWillResignActiveNotification
                                                     object:[UIApplication sharedApplication]];

    }
    return self;
}

- (void)translate:(TranslateEntity *)translateEntity {
    
    NSString *langFrom = [_allLangsDictionary objectForKey:translateEntity.langFrom];
    NSString *langOn = [_allLangsDictionary objectForKey:translateEntity.langOn];
    
    if (langFrom == nil || langOn == nil) {
        NSError *tranlateError = [NSError errorWithDomain:@"translate.yandex" code:200 userInfo:@{NSLocalizedDescriptionKey:@"Language is not found"}];
        [self.delegate receiveTranslate:nil withError:tranlateError];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:translateURL]];
    
    NSString *postDataString = [NSString stringWithFormat:@"key=%@&text=%@&lang=%@-%@", keyAPI, translateEntity.inputText, langFrom, langOn];
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSMutableString *outputText = [NSMutableString string];
        NSArray *textArray;
        
        if (!error) {
            
            NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"%@", answer);
            NSInteger statusCode = [[answer valueForKey:@"code"] integerValue];
            
            if (statusCode == 200) {
                
                textArray = [answer valueForKey:@"text"];
                for (NSString *sentence in textArray) {
                    [outputText appendString:sentence];
                }
                // NSLog(@"Answer: \n%@", [[answer valueForKey:@"text"] firstObject]);
                
            } else {
                error = [NSError errorWithDomain:@"translate.yandex" code:200 userInfo:@{NSLocalizedDescriptionKey:@"Translate error"}];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            translateEntity.outputText = [NSString stringWithString:outputText];
            [self.delegate receiveTranslate:translateEntity withError:error];
        }); }] resume];
}



#pragma mark - System notification and Life Time

- (void)appWillTerminate:(NSNotification *)note {
    [self saveHistory];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - History Management

- (void)addTranslateHistory:(TranslateEntity *)historyEntity {
    [_history addObject:historyEntity];
}

- (void)clearHistory {
    _history = [NSMutableArray array];
}

- (void)loadHistory {
    
    NSData *historyData = [[NSUserDefaults standardUserDefaults] objectForKey:historyKey];
    
    if (historyData)
        _history = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:historyData]];
    else
        _history = [NSMutableArray array];
}


- (void)saveHistory {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:_history]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:historyKey];
    
}

#pragma mark - Languages Loading

- (void)loadAllLanguages {
    
    _allLangsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:allLangsKey];
    if (_allLangsDictionary) {
        
        NSArray *allLanguages = [_allLangsDictionary allKeys];
        [_delegate receiveLanguagesList:allLanguages withError:nil];
        
    } else {
        
        [self downloadAllLanguages];
    }
}

- (void)downloadAllLanguages {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:allLangsURL]];
    
    NSString *postDataString = [NSString stringWithFormat:@"key=%@&ui=en", keyAPI];
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *loadingError;
        NSArray *allLanguages;
        
        if (error) {
            loadingError = error;
        } else {
            
            NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger statusCode = [[answer valueForKey:@"code"] integerValue];
            
            if (statusCode == 401) {
                //error
                loadingError = [NSError errorWithDomain:@"translate.yandex" code:200 userInfo:@{NSLocalizedDescriptionKey:@"Translate went wrong"}];
            } else {
                
                NSArray *keys = [[answer objectForKey:@"langs"] allKeys];
                allLanguages = [[answer objectForKey:@"langs"] allValues];
                
                _allLangsDictionary = [NSDictionary dictionaryWithObjects:keys
                                                                  forKeys:allLanguages];
                // save all languages in user defaults
                [[NSUserDefaults standardUserDefaults] setObject:_allLangsDictionary forKey:allLangsKey];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate receiveLanguagesList:allLanguages withError:loadingError];
        });
    }] resume];

}

@end
