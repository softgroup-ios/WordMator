//
//  Translater.h
//  translater
//
//  Created by Tony Hrabovskyi on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TranslateEntity : NSObject <NSCoding>

@property (strong, nonatomic) NSString *outputText;
@property (strong, nonatomic) NSString *inputText;

@property (strong, nonatomic, readonly) NSString *langFrom;
@property (strong, nonatomic, readonly) NSString *langOn;

@property (assign, nonatomic, setter=setFavorite:) BOOL isFavorite;

- (instancetype)initWithLangFrom:(NSString*)langFrom
                       andLangOn:(NSString*)langOn
                        andInput:(NSString*)inputText;
@end



@protocol TranslatorDelegate <NSObject>

- (void)receiveTranslate:(TranslateEntity*)translate withError:(NSError*)error; // just receive translated entity after translateTextOnLang
- (void)receiveLanguagesList:(NSArray<NSString *> *)allLanguages withError:(NSError*)error; // will called when translator property allLanguages was loaded via API
@end

@interface Translator : NSObject

@property (strong, nonatomic) NSMutableArray<TranslateEntity *> *history; // history of translation
@property (strong, nonatomic, readonly) NSDictionary<NSString*, NSString*> *allLangsDictionary; // all languages code from full name

+ (Translator*)sharedInstance;

- (instancetype)init NS_UNAVAILABLE; // close standard init like private
- (instancetype)initWithDelegate:(id<TranslatorDelegate>)delegate; // delegate for receive translator answers

- (void)addTranslateHistory:(TranslateEntity*)historyEntity; // add history entity
- (void)clearHistory; // clear all history

- (void)translate:(TranslateEntity*)translateEntity; // translate entity, answer will send on delegate

@end
