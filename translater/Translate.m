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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *clearInputButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextView *copyrightText;

// controls
@property (strong, nonatomic) NSString *selectedLangFrom;
@property (strong, nonatomic) NSString *selectedLangOn;
@property (strong, nonatomic) NSArray<NSString *> *allLanguages;
@property (assign, nonatomic) SelectionStatus selectionStatus;
@property (assign, nonatomic) BOOL isSpaceWasType;
@property (assign, nonatomic) BOOL isErrorOutput;
@property (assign, nonatomic) BOOL isInputEditing;

// models
@property (strong, nonatomic) TranslateEntity *translatingEntity;
@property (strong, nonatomic) Translator *translator;

@end

@implementation Translate

static NSString *langSelectingSegueIdentifier = @"SelectLanguage";
static NSString *langFromKey = @"LanguageFromSavedKey";
static NSString *langOnKey = @"LanguageOnSavedKey";

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init view
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, self.clearInputButton.frame.size.width);
    [self deactivateInputView];
    [self.loadingIndicator setHidden:FALSE];
    [self.reverseLangsButton setHidden:TRUE];
    [self.langFromButton setHidden:TRUE];
    [self.langOnButton setHidden:TRUE];
    [self.saveButton setHidden:TRUE];
    
    self.selectedLangFrom = [[NSUserDefaults standardUserDefaults] objectForKey:langFromKey];
    if (!self.selectedLangFrom) self.selectedLangFrom = @"Ukrainian";
    
    self.selectedLangOn = [[NSUserDefaults standardUserDefaults] objectForKey:langOnKey];
    if (!self.selectedLangOn) self.selectedLangOn = @"English";
    
    // tap and swipe for dismiss keyboard
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:tap];
    
    // translator initialize
    self.translator = [[Translator alloc] initWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    self.saveButton.selected = self.translatingEntity.isFavorite;
}

- (void)viewDidAppear:(BOOL)animated {
    // set input active
   // [self.inputTextView becomeFirstResponder];
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
    if (![_selectedLangFrom isEqualToString:_selectedLangOn]) {
        NSString *holder = _selectedLangFrom;
        self.selectedLangFrom = _selectedLangOn;
        self.selectedLangOn = holder;
        [self fullRefreshTranslate];
    }
}

- (IBAction)clearInputAction:(id)sender {
    self.inputTextView.text = nil;
    if (!_isErrorOutput) {
        [self output:nil withError:nil];
    }
    [self.clearInputButton setHidden:!(self.isInputEditing)];
    self.translatingEntity = nil;
}

- (IBAction)saveAction:(id)sender {
    if (self.translatingEntity.isFavorite) {
        
        self.translatingEntity.isFavorite = FALSE;
        [self.translator.history removeObject:self.translatingEntity];
        self.saveButton.selected = FALSE;
    } else {
        
        self.translatingEntity.isFavorite = TRUE;
        self.saveButton.selected = TRUE;
        [self.translator addTranslateHistory:self.translatingEntity];
    }
}

- (void)dismissKeyboard {
    [self.inputTextView resignFirstResponder];
    [self deactivateInputView];
    [self updateTranslate];
}

#pragma mark - UI changing

- (void)deactivateInputView {
    self.isInputEditing = FALSE;
    self.inputTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.inputTextView.layer.borderWidth = 1.0;
    [self.clearInputButton setHidden:[_inputTextView.text isEqualToString:@""]];
}

- (void)activateInputView {
    self.isInputEditing = TRUE;
//    self.inputTextView.layer.borderColor = [UIColor redColor].CGColor;
    self.inputTextView.layer.borderWidth = 2.0;
    [self.clearInputButton setHidden:FALSE];
}

- (void)output:(NSString*)text withError:(NSError*)error {
    
    if (error) {
        _isErrorOutput = TRUE;
        [self.saveButton setHidden:TRUE];
        self.outputTextView.text = error.localizedDescription;
        self.outputTextView.textColor = [UIColor redColor];
        self.outputTextView.textAlignment = NSTextAlignmentCenter;
        
    } else if (text) {
        _isErrorOutput = FALSE;
        [self.saveButton setHidden:FALSE];
        self.outputTextView.text = text;
        self.outputTextView.textColor = [UIColor blackColor];
        self.outputTextView.textAlignment = NSTextAlignmentLeft;
        
    } else {
        [self.saveButton setHidden:TRUE];
        self.outputTextView.text = nil;
    }
}



#pragma mark - TranslateControls

- (void)fullRefreshTranslate {
    self.translatingEntity = [[TranslateEntity alloc] initWithLangFrom:_selectedLangFrom andLangOn:_selectedLangOn andInput:self.inputTextView.text];
    [self.translator translate:self.translatingEntity];
}

- (void)updateTranslate {
    if (self.translatingEntity) {
        self.translatingEntity.inputText = _inputTextView.text;
        [self.translator translate:self.translatingEntity];
    } else {
        [self fullRefreshTranslate];
    }
    
}

#pragma mark - Selected Languages Setters

- (void)setSelectedLangOn:(NSString *)selectedLangOn {
    
    if (![_selectedLangOn isEqualToString:selectedLangOn]) {
        _selectedLangOn = selectedLangOn;
        [[NSUserDefaults standardUserDefaults] setObject:selectedLangOn forKey:langOnKey];
        //selectedLangOn = [selectedLangOn uppercaseString];
        [self.langOnButton setTitle:selectedLangOn forState:UIControlStateNormal];
        [self fullRefreshTranslate];
    }
}

- (void)setSelectedLangFrom:(NSString *)selectedLangFrom {
    
    if (![_selectedLangFrom isEqualToString:selectedLangFrom]) {
        _selectedLangFrom = selectedLangFrom;
        [[NSUserDefaults standardUserDefaults] setObject:selectedLangFrom forKey:langFromKey];
       // selectedLangFrom = [selectedLangFrom uppercaseString];
        [self.langFromButton setTitle:selectedLangFrom forState:UIControlStateNormal];
        [self fullRefreshTranslate];
    }
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

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([_inputTextView.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        // didn't found any characters - clear outputtextView
        [self output:nil withError:nil];
        self.translatingEntity = nil;
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self dismissKeyboard];
        return NO;
        
    } else if ([text isEqualToString:@" "] && !self.isSpaceWasType) {
        self.isSpaceWasType = TRUE;
        [self updateTranslate];
        
    } else {
        self.isSpaceWasType = FALSE;
    }
    
    return YES;
}

#pragma mark - TranslatorDelegate

- (void)receiveLanguagesList:(NSArray<NSString *> *)allLanguages withError:(NSError *)error {
    
    if (error) {
        [self output:nil withError:error];
    } else {
        
        [self.loadingIndicator setHidden:TRUE];
        [self.reverseLangsButton setHidden:FALSE];
        [self.langFromButton setHidden:FALSE];
        [self.langOnButton setHidden:FALSE];
        
        self.allLanguages = allLanguages;
    }
}

- (void)receiveTranslate:(TranslateEntity *)translate withError:(NSError *)error {
    
    if (error) {
        [self output:nil withError:error];
    } else {
        
        if (self.translatingEntity == translate) { // link comparing
            [self output:translate.outputText withError:nil];
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





