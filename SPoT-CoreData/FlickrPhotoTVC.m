//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Recent+Photo.h"
#import "Tag+Flickr.h"
#import "SharedDocumentHandler.h"

@interface FlickrPhotoTVC () <UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation FlickrPhotoTVC

- (UIBarButtonItem *)searchButton
{
    if (!_searchButton) {
        _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                      target:self
                                                                      action:@selector(searchButtonPressed:)];
        
    }
    return _searchButton;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]
                      initWithFrame:self.navigationController.navigationBar.frame];
        self.searchBar.delegate = self;
    }
    return _searchBar;
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

- (void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSString *sectionNameKeyPath = @"firstLetter";        
        if ([self.tag.name isEqualToString:ALL_TAGS_STRING]) {
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tagsString"
                                                                      ascending:YES],
                                        [request.sortDescriptors lastObject]];
            sectionNameKeyPath = @"tagsString";
        }
        request.predicate = [NSPredicate predicateWithFormat:@"%@ in tags", self.tag];
        if (self.searchPredicate) {
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[request.predicate, self.searchPredicate]];
        }
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
                                                                              sectionNameKeyPath:sectionNameKeyPath
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    if ([tag.name isEqualToString:ALL_TAGS_STRING]) {
        self.title = @"All";
    } else {
        self.title = [tag.name capitalizedString];
    }
    [self setupFetchedResultsController];
}

- (void)sendDataforIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [Recent recentPhoto:photo];
        [[SharedDocumentHandler sharedDocumentHandler] saveDocument];
        [vc performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
        [vc performSelector:@selector(setTitle:) withObject:photo.title];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                [self sendDataforIndexPath:indexPath
                          toViewController:segue.destinationViewController];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.searchButton;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;    
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    
    if (!cell.imageView.image) {
        dispatch_queue_t q = dispatch_queue_create("Thumbnail Flickr Photo", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [photo.managedObjectContext performBlock:^{
                photo.thumbnail = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsLayout];
                });
            }];
        });
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendDataforIndexPath:indexPath
              toViewController:[self.splitViewController.viewControllers lastObject]];
}

-  (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [photo.managedObjectContext performBlock:^{
            [photo delete];
            [[SharedDocumentHandler sharedDocumentHandler] saveDocument];
        }];
    }
}

#pragma mark - Search delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        self.searchPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
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
