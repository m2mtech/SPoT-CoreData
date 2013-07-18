//
//  RecentFlickrPhotoTVC.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "RecentFlickrPhotoTVC.h"
#import "SharedDocumentHandler.h"

@interface RecentFlickrPhotoTVC ()

@property (strong, nonatomic) SharedDocumentHandler *sh;

@end

@implementation RecentFlickrPhotoTVC

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
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.lastViewed"
                                                                  ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.sh.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.sh useDocumentWithOperation:^(BOOL success) {
        [self setupFetchedResultsController];
    }];
}

@end
