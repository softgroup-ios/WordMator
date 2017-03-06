//
//  LanguageSelecting.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/25/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "LanguageCell.h"
#import "HeaderCell.h"
#import "LanguageSelecting.h"

@interface LanguageSelecting () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *issueMessageLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray<NSString *> *languageList;
@property (strong, nonatomic) NSArray<NSString *> *searchResult;
@property (strong, nonatomic) NSMutableArray<NSString *> *favoriteLanguages;
@property (strong, nonatomic) NSArray<NSString *> *searchedFavoriteLanguages;

@end

@implementation LanguageSelecting

static NSUInteger maxFavoriteLanguages = 5;
static NSString *selectingCellIdentifier = @"LanguageSelectingCell";
static NSString *favoritesLanguagesKey = @"FavoritesLanguagesArray";
static NSString *errorLoadingMessage = @"Languages loading went wrong,\n please re-select language.";
static NSString *emptySearchResultMessage = @"Nothing found.";
static NSString *languageCellIdentifier = @"LanguageCell";
static NSString *headerCellIdentifier = @"HeaderCell";

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favoriteLanguages = [self getFavoriteLanguages];
    self.searchedFavoriteLanguages = self.favoriteLanguages;
    self.issueMessageLabel.text = (self.languageList.count > 0) ? emptySearchResultMessage : errorLoadingMessage;
}

#pragma mark - Public Methods

- (void)selectLanguageFromList:(NSArray<NSString *> *)languageList {
    self.languageList = languageList;
    self.searchResult = languageList;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearch:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


#pragma mark - SearchController

- (void)filterContentForSearch:(NSString *)searchText {
    if ([searchText rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound) {
        NSPredicate *searchPredicete = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", searchText];
        self.searchResult = [self.languageList filteredArrayUsingPredicate:searchPredicete];
        self.searchedFavoriteLanguages = [self.favoriteLanguages filteredArrayUsingPredicate:searchPredicete];
    } else {
        self.searchResult = self.languageList;
        self.searchedFavoriteLanguages = self.favoriteLanguages;
    }

    [self.tableView reloadData];
}

#pragma mark - Users Action

- (IBAction)selectingCancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Saving Favorite Languages

- (NSMutableArray<NSString*> *)getFavoriteLanguages {
    NSMutableArray<NSString *> *favoriteLanguage;
    NSArray *savedFavoritesLanguages = [[NSUserDefaults standardUserDefaults] arrayForKey:favoritesLanguagesKey];
    
    if (savedFavoritesLanguages) {
        favoriteLanguage = [NSMutableArray arrayWithArray:savedFavoritesLanguages];
    } else {
        favoriteLanguage = [NSMutableArray array];
    }
    return favoriteLanguage;
}

- (void)overwriteFavoriteLanguages:(NSMutableArray<NSString *> *)favoriteLanguages {
    NSArray *favoriteLanguageArray = [NSArray arrayWithArray:favoriteLanguages];
    [[NSUserDefaults standardUserDefaults] setObject:favoriteLanguageArray forKey:favoritesLanguagesKey];
}

- (void)addFavoriteLanguage:(NSString*)language {
    
    for (int i = 0; i < self.favoriteLanguages.count; i++) {
        
        NSString *lang = [self.favoriteLanguages objectAtIndex:i];
        if ([lang isEqualToString:language]) {
            [self.favoriteLanguages removeObjectAtIndex:i];
        }
    }
    [self.favoriteLanguages insertObject:language atIndex:0];
    
    if (self.favoriteLanguages.count > maxFavoriteLanguages) {
        [self.favoriteLanguages removeLastObject];
    }
    [self overwriteFavoriteLanguages:self.favoriteLanguages];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *selectedLanguage;
    if (indexPath.section == 0) {
        selectedLanguage = [self.searchedFavoriteLanguages objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        selectedLanguage = [self.searchResult objectAtIndex:indexPath.row];
    }
    
    [self addFavoriteLanguage:selectedLanguage];
    [self.delegate receiveSelectedLanguage:selectedLanguage];
    [self.searchBar resignFirstResponder];
    [self selectingCancelAction:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.searchedFavoriteLanguages.count > 0) {
        return 30.0F;
    } else if (section == 1 && self.searchResult.count > 0) {
        return 30.0F;
    }
    return 0.0F;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    HeaderCell *header = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier];
    
    if (section == 0) {
        header.languageTypeLabel.text = @"Favorite Languages:";
    } else if (section == 1) {
        header.languageTypeLabel.text = @"All Languages:";
    }
    
    return header.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:languageCellIdentifier];
    
    if (indexPath.section == 0) {
        cell.languageLabel.text = [self.searchedFavoriteLanguages objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.languageLabel.text = [self.searchResult objectAtIndex:indexPath.row];
    }
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rowNumber = 0;
    
    if (section == 0) {
        rowNumber = self.searchedFavoriteLanguages.count;
    } else if (section == 1) {
        rowNumber = self.searchResult.count;
        [self.issueMessageLabel setHidden:(rowNumber > 0)];
    }
    return rowNumber;
}


@end
