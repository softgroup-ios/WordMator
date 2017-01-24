//
//  Translater.h
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TranslaterProtocol <NSObject>

- (void)receiveData:(NSArray*)data;

@end

@interface Translater : NSObject

- (instancetype)initWithDelegate:(id<TranslaterProtocol>)delegate;
- (void)translate:(NSString*)text and:(NSString*)lang;
@end
