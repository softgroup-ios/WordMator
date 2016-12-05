//
//  ViewController.m
//  translater
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ViewController.h"
#import "Translater.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fromLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLangLabel;

@property (weak, nonatomic) IBOutlet UITextView *outPutLabel;
@property (weak, nonatomic) IBOutlet UITextView *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndocator;
@property (weak, nonatomic) IBOutlet UIButton *translateButtton;

@end

static NSString* lang = @"en-uk";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Translater setUpTranslate:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) takeAnswer:(NSString*)text {
    
    [self.translateButtton setHidden:NO];
    [self.loadingIndocator stopAnimating];
    self.outPutLabel.text = text;
}

- (IBAction)reverseLanguage:(id)sender {
    
    
    if ([lang isEqualToString:@"en-uk"]) {
        
        lang = @"uk-en";
        self.fromLangLabel.text = @"Ukrainian";
        self.toLangLabel.text = @"English";
        
    } else {
        
        lang = @"en-uk";
        self.fromLangLabel.text = @"English";
        self.toLangLabel.text = @"Ukrainian";
    }
}

- (IBAction)translate:(id)sender {
    
    NSString *encodedtext = [self.inputTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.translateButtton setHidden:YES];
    [self.loadingIndocator startAnimating];
    
    [Translater translate:encodedtext and:lang];
}

@end









