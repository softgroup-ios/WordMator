//
//  Translater.h
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TranslatorDelegate <NSObject>

- (void)receiveText:(NSArray *)textsList withError:(NSError*)error; // just receive answer after translateTextOnLang
- (void)allLanguagesWasLoadedWithError:(NSError*)error; // will called when translator property allLanguages was loaded via API
@end

@interface Translator : NSObject

@property (strong, nonatomic, readonly) NSArray<NSString*> *allLanguages; // dictionary with all languages, readonly

- (instancetype)init NS_UNAVAILABLE; // close standard init like private
- (instancetype)initWithDelegate:(id<TranslatorDelegate>)delegate; // delegate for receive translator answers

// translate text from language on language (full language name), answer will send on delegate
- (void)translateText:(NSString*)text fromLang:(NSString*)fromLang onLang:(NSString*)toLang;

@end
