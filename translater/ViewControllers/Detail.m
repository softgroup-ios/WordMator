//
//  Detail.m
//  translater
//
//  Created by Tony Hrabovskyi on 3/2/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "Detail.h"
#import "Translator.h"

@interface Detail ()

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UILabel *langFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *langOnLabel;

@property (strong, nonatomic) TranslateEntity *translateEntity;

@end

@implementation Detail

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTextView.text = self.translateEntity.inputText;
    self.outputTextView.text = self.translateEntity.outputText;
    self.langFromLabel.text = self.translateEntity.langFrom;
    self.langOnLabel.text = self.translateEntity.langOn;
}

#pragma mark - Public Methods

- (void)showTranslateDetail:(TranslateEntity *)translateEntity {
    self.translateEntity = translateEntity;
}

#pragma mark - Gestures

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - User Actions

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)removeAction:(id)sender {
    self.translateEntity.isFavorite = FALSE;
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
