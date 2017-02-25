//
//  Translate.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/25/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "LanguageSelecting.h"
#import "Translator.h"
#import "Translate.h"

typedef enum : NSUInteger {
    SelectionStatusNone,
    SelectionStatusLangFrom,
    SelectionStatusLangOn,
} SelectionStatus;

@interface Translate () <TranslatorDelegate, LanguageSelectingDelegate, UITextViewDelegate>

// view
@property (weak, nonatomic) IBOutlet UIButton *langFromButton;
@property (weak, nonatomic) IBOutlet UIButton *langOnButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseLangsButton;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;

// controls
@property (strong, nonatomic) NSString *selectedLangFrom;
@property (strong, nonatomic) NSString *selectedLangOn;
@property (strong, nonatomic) NSArray<NSString *> *allLanguages;
@property (assign, nonatomic) SelectionStatus selectionStatus;

// models
@property (strong, nonatomic) TranslateEntity *translatingEntity;
@property (strong, nonatomic) Translator *translator;

@end

@implementation Translate

static NSString *langSelectingSegueIdentifier = @"SelectLanguage";

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeErrorOutput];
    self.inputTextView.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self deactivateInputView];
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 50);
    
    self.translator = [[Translator alloc] initWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - Users Actions

- (IBAction)langFromAction:(id)sender {
    self.selectionStatus = SelectionStatusLangFrom;
    [self performSegueWithIdentifier:langSelectingSegueIdentifier sender:nil];
}

- (IBAction)langOnAction:(id)sender {
    self.selectionStatus = SelectionStatusLangOn;
    [self performSegueWithIdentifier:langSelectingSegueIdentifier sender:nil];
}

- (IBAction)reverseLangsAction:(id)sender {
    NSString *holder = _selectedLangFrom;
    self.selectedLangFrom = _selectedLangOn;
    self.selectedLangOn = holder;
}

- (IBAction)clearInputAction:(id)sender {
    self.inputTextView.text = @"";
}

- (void)dismissKeyboard {
    [self.inputTextView resignFirstResponder];
    [self deactivateInputView];
    [self refreshTranslate];
}

#pragma mark - UI changing

- (void)deactivateInputView {
    self.inputTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.inputTextView.layer.borderWidth = 1.0;
}

- (void)activateInputView {
    self.inputTextView.layer.borderColor = [UIColor redColor].CGColor;
    self.inputTextView.layer.borderWidth = 2.0;
}

- (void)makeErrorOutput {
    self.outputTextView.textColor = [UIColor redColor];
    self.outputTextView.textAlignment = NSTextAlignmentCenter;
    
}

#pragma mark - TranslateControls

- (void)refreshTranslate {
    
    //TODO
    NSString *inputText = _inputTextView.text;
    
    if (inputText.length == 0) {
        
        return;
    }
    
    self.translatingEntity = [[TranslateEntity alloc] initWithLangFrom:_selectedLangFrom andLangOn:_selectedLangOn andInput:inputText];
    [self.translator translate:self.translatingEntity];
}

#pragma mark - Selected Languages Setters

- (void)setSelectedLangOn:(NSString *)selectedLangOn {
    _selectedLangOn = selectedLangOn;
    selectedLangOn = [selectedLangOn uppercaseString];
    [self.langOnButton setTitle:selectedLangOn forState:UIControlStateNormal];
}

- (void)setSelectedLangFrom:(NSString *)selectedLangFrom {
    _selectedLangFrom = selectedLangFrom;
    selectedLangFrom = [selectedLangFrom uppercaseString];
    [self.langFromButton setTitle:selectedLangFrom forState:UIControlStateNormal];
}

#pragma mark - LanguageSelectingDelegate

- (void)receiveSelectedLanguage:(NSString *)language {
    
    if (_selectionStatus == SelectionStatusLangOn) {
        self.selectedLangOn = language;
        
    } else if (_selectionStatus == SelectionStatusLangFrom) {
        self.selectedLangFrom = language;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self activateInputView];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self dismissKeyboard];
        return NO;
    }
    
    return YES;
}

#pragma mark - TranslatorDelegate

- (void)receiveLanguagesList:(NSArray<NSString *> *)allLanguages withError:(NSError *)error {
    
    if (error) {
        
    } else {
        self.allLanguages = allLanguages;
    }
}

- (void)receiveTranslate:(TranslateEntity *)translate withError:(NSError *)error {
    
    if (error) {
        
    } else {
        
        if (self.translatingEntity == translate) { // link comparing
            self.outputTextView.text = translate.outputText;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:langSelectingSegueIdentifier]) {
        
        LanguageSelecting *langSelecting = (LanguageSelecting*)[segue destinationViewController];
        langSelecting.delegate = self;
        [langSelecting selectLanguageFromList:self.allLanguages];
    }
}


@end





