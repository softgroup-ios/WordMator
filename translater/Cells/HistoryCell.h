//
//  HistoryCell.h
//  translater
//
//  Created by Tony Hrabovskyi on 2/27/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TranslateEntity;

@interface HistoryCell : UITableViewCell

- (void)showHistory:(TranslateEntity*)translateEntity;

@end
