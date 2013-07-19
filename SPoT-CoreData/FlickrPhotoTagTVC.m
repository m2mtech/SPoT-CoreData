//
//  TagTVC.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrPhotoTagTVC.h"
#import "FlickrFetcher.h"
#import "NetworkActivityIndicator.h"
#import "Tag+Flickr.h"
#import "Photo+Flickr.h"
#import "SharedDocumentHandler.h"

@interface FlickrPhotoTagTVC () <UISearchBarDelegate>

@property (strong, nonatomic) SharedDocumentHandler *sh;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSPredicate *searchPredicate;

@end

@implementation FlickrPhotoTagTVC

- (UIBarButtonItem *)searchButton
{
    if (!_searchButton) {
        _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                      target:self
                                                                      action:@selector(searchButtonPressed:)];
                         
    }
    return _searchButton;
}

- (IBAction)searchButtonPressed:(id)sender
{
    if (self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.tableHeaderView = self.searchBar;
        if (self.searchPredicate) {
            self.searchPredicate = nil;
            [self setupFetchedResultsController];
        }
        [self.searchBar becomeFirstResponder];
    }
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]
                      initWithFrame:self.navigationController.navigationBar.frame];
        self.searchBar.delegate = self;
    }
    return _searchBar;
}

- (SharedDocumentHandler *)sh
{
    if (!_sh) {
        _sh = [SharedDocumentHandler sharedDocumentHandler];
    }
    return _sh;
}

- (void)setupFetchedResultsController
{
    if (self.sh.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.predicate = self.searchPredicate;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.sh.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)loadPhotosFromFlickr
{
    if (!self.sh.managedObjectContext) [self.sh useDocumentWithOperation:^(BOOL success) {
        [self setupFetchedResultsController];
    }];

    [self.refreshControl beginRefreshing];
    dispatch_queue_t queue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(queue, ^{
        [NetworkActivityIndicator start];
        //NSLog(@"%@", photos);
        //[NSThread sleepForTimeInterval: 2.0];
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [NetworkActivityIndicator stop];
        [self.sh.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo
                    inManagedObjectContext:self.sh.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.sh saveDocument];
            });
        }];
    });
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = self.searchButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.sh.managedObjectContext)
        [self.sh useDocumentWithOperation:^(BOOL success) {
        [self setupFetchedResultsController];
        if (![self.fetchedResultsController.fetchedObjects count])
            [self loadPhotosFromFlickr];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Show Photos"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
                [segue.destinationViewController performSelector:@selector(setTag:)
                                                      withObject:tag];
            }
        }        
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([tag.name isEqualToString:ALL_TAGS_STRING]) {
        cell.textLabel.text = @"All";
    } else {
        cell.textLabel.text = [tag.name capitalizedString];
    }
    
    int photoCount = [tag.photos count];    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - Table view delegate

#pragma mark - Search Display delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        self.searchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    } else {
        self.searchPredicate = nil;
    }
    [self setupFetchedResultsController];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.tableView.tableHeaderView = nil;
}

@end
