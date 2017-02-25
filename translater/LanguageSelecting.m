//
//  LanguageSelecting.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/25/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "LanguageSelecting.h"

@interface LanguageSelecting () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray<NSString *> *languageList;

@end

@implementation LanguageSelecting

static NSString *selectingCellIdentifier = @"LanguageSelectingCell";

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Public Methods

- (void)selectLanguageFromList:(NSArray<NSString *> *)languageList {
    self.languageList = languageList;
    
}

#pragma mark - Users Action

- (IBAction)selectingCancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedLanguage = [self.languageList objectAtIndex:indexPath.row];
    [self.delegate receiveSelectedLanguage:selectedLanguage];
    [self selectingCancelAction:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectingCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectingCellIdentifier];
    }
    
    cell.textLabel.text = [self.languageList objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageList.count;
}


@end
