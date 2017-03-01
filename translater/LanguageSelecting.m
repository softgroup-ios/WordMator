//
//  LanguageSelecting.m
//  translater
//
//  Created by Tony Hrabovskyi on 2/25/17.
//  Copyright © 2017 admin. All rights reserved.
//

#import "LanguageSelecting.h"

@interface LanguageSelecting () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray<NSString *> *languageList;
@property (strong, nonatomic) NSArray<NSString *> *searchResult;
@property (strong, nonatomic) NSMutableArray<NSString *> *favoriteLanguages;

@end

@implementation LanguageSelecting

static NSString *selectingCellIdentifier = @"LanguageSelectingCell";
static NSString *favoritesLanguagesKey = @"FavoritesLanguagesArray";
static NSUInteger maxFavoriteLanguages = 5;

#pragma mark - Life Time

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favoriteLanguages = [self getFavoriteLanguages];
}

#pragma mark - Public Methods

- (void)selectLanguageFromList:(NSArray<NSString *> *)languageList {
    self.languageList = languageList;
    self.searchResult = languageList;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {   // called when text changes (including clear)
    [self filterContentForSearch:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { // called when keyboard search button pressed
    //[self filterContentForSearch:searchBar.text];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar { // called when cancel button pressed
    [self.searchBar resignFirstResponder];
}

#pragma mark - SearchController

- (void)filterContentForSearch:(NSString *)searchText {
    if ([searchText rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound) {
        NSPredicate *searchPredicete = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", searchText];
        self.searchResult = [self.languageList filteredArrayUsingPredicate:searchPredicete];
    } else {
        self.searchResult = self.languageList;
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
        selectedLanguage = [self.favoriteLanguages objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        selectedLanguage = [self.searchResult objectAtIndex:indexPath.row];
        [self addFavoriteLanguage:selectedLanguage];
    }
    
    [self.delegate receiveSelectedLanguage:selectedLanguage];
    [self selectingCancelAction:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0F;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Favorite Languages:";
    } else if (section == 1) {
        return @"All Languages:";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectingCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectingCellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.favoriteLanguages objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.searchResult objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.favoriteLanguages.count;
    } else if (section == 1) {
        return self.searchResult.count;
    }
    return 0;
}


@end
