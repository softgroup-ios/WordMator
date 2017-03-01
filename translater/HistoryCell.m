//
//  HistoryCell.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/27/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "Translator.h"
#import "HistoryCell.h"

@interface HistoryCell ()
@property (weak, nonatomic) IBOutlet UILabel *langFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *langOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@end

@implementation HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showHistory:(TranslateEntity*)translateEntity {
    
    Translator *translator = [Translator sharedInstance];
    
    self.langFromLabel.text = [[translator.allLangsDictionary objectForKey:translateEntity.langFrom] uppercaseString];
    self.langOnLabel.text = [[translator.allLangsDictionary objectForKey:translateEntity.langOn] uppercaseString];
    self.inputLabel.text = translateEntity.inputText;
    self.outputLabel.text = translateEntity.outputText;
}

@end
