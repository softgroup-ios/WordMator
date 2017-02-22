//
//  ViewController.m
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TranslateVC.h"
#import "Translator.h"

typedef enum : NSUInteger {
    SelectionStatusNone,
    SelectionStatusFromLang,
    SelectionStatusToLang,
} SelectionStatus;

@interface TranslateVC () <TranslatorDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *fromLangButton;
@property (weak, nonatomic) IBOutlet UIButton *toLangButton;

@property (weak, nonatomic) IBOutlet UITextView *outPutLabel;
@property (weak, nonatomic) IBOutlet UITextView *inputTextField;

@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndocator;
@property (weak, nonatomic) IBOutlet UIButton *translateButtton;
@property (weak, nonatomic) IBOutlet UITableView *langTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectLangDoneButton;
@property (weak, nonatomic) IBOutlet UISearchBar *langSearchBar;

@property (strong, nonatomic) Translator* translator;
@property (strong, nonatomic) NSString *selectedFromLang;
@property (strong, nonatomic) NSString *selectedToLang;

@property (assign, nonatomic) SelectionStatus selectionStatus;
@property (assign, nonatomic) NSUInteger selectedLangRow;
@end

@implementation TranslateVC

static NSString *fromLangSavedKey = @"fromLangSelected";
static NSString *toLangSavedKey = @"toLangSelected";

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectionStatus = SelectionStatusNone;
    [self toggleSelectBar:FALSE];
    
    self.translator = [[Translator alloc] initWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reloadSelecterButtons {
    
    _selectedFromLang = [[NSUserDefaults standardUserDefaults] stringForKey:fromLangSavedKey];
    if (_selectedFromLang == nil) {
        _selectedFromLang = [_translator.allLanguages objectAtIndex:0];
    }
    
    _selectedToLang = [[NSUserDefaults standardUserDefaults] stringForKey:toLangSavedKey];
    if (_selectedToLang == nil) {
        _selectedToLang = [_translator.allLanguages objectAtIndex:0];
    }
    
    [_fromLangButton setTitle:_selectedFromLang forState:UIControlStateNormal];
    [_toLangButton setTitle:_selectedToLang forState:UIControlStateNormal];
}

- (void)toggleSelectBar:(BOOL)toggle {
    toggle = !toggle;
    [_langTableView setHidden:toggle];
    [_langSearchBar setHidden:toggle];
    [_selectLangDoneButton setHidden:toggle];
    
}
#pragma mark - TranslatorDelegate

- (void)receiveText:(NSArray *)textsList withError:(NSError*)error {
    
    [self.translateButtton setHidden:NO];
    [self.loadingIndocator stopAnimating];
    
    NSMutableString *translatedText = [NSMutableString string];
    
    for (NSString *sentence in textsList ) {
        [translatedText appendString:sentence];
    }
    self.outPutLabel.text = translatedText;
}

- (void)allLanguagesWasLoadedWithError:(NSError*)error {
    [_langTableView reloadData];
    [self reloadSelecterButtons];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _translator.allLanguages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LangCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LangCell"];
    }
    
    cell.textLabel.text = [_translator.allLanguages objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedLangRow = indexPath.row;
    return indexPath;
}


#pragma mark - Actions

- (IBAction)selectLangAction:(id)sender {
    
    if (_selectionStatus == SelectionStatusToLang) {
        _selectedToLang = [_translator.allLanguages objectAtIndex:_selectedLangRow];
        [_toLangButton setTitle:_selectedToLang forState:UIControlStateNormal];
    } else if (_selectionStatus == SelectionStatusFromLang) {
        _selectedFromLang = [_translator.allLanguages objectAtIndex:_selectedLangRow];
        [_fromLangButton setTitle:_selectedFromLang forState:UIControlStateNormal];
    }
    
    _selectionStatus = SelectionStatusNone;
    [self toggleSelectBar:NO];
    
    
}

- (IBAction)fromLangAction:(id)sender {
    if (_selectionStatus == SelectionStatusNone) {
        _selectionStatus = SelectionStatusFromLang;
        
        [self toggleSelectBar:YES];
    }
}

- (IBAction)toLangAction:(id)sender {
    if (_selectionStatus == SelectionStatusNone) {
        _selectionStatus = SelectionStatusToLang;
        
        [self toggleSelectBar:YES];
    }
}


- (IBAction)reverseLanguage:(id)sender {
    
    
//    if ([lang isEqualToString:@"en-uk"]) {
//        
//        lang = @"uk-en";
//        self.fromLangButton.titleLabel.text = @"Ukrainian";
//        self.toLangButton.titleLabel.text = @"English";
//        
//    } else {
//        
//        lang = @"en-uk";
//          self.fromLangLabel.text = @"English";
//          self.toLangLabel.text = @"Ukrainian";
//    }
}

- (IBAction)translateAction:(id)sender {
    
    //NSString *encodedtext = [self.inputTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.translateButtton setHidden:YES];
    [self.loadingIndocator startAnimating];
    
    NSString *text = _inputTextField.text;
    
    [self.translator translateText:text fromLang:_selectedFromLang onLang:_selectedToLang];
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:@"LanguageChoose"]) {
//        
//        SelectorVC *langSelector = [segue destinationViewController];
//        [langSelector receiveArrayForShowing:_translator.allLanguages];
//    }
}
*/
@end









