//
//  ViewController.m
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "ViewController.h"
#import "SharedDocumentHandler.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SharedDocumentHandler *sh = [SharedDocumentHandler sharedDocumentHandler];
    [sh useDocumentWithOperation:NULL];

    dispatch_queue_t queue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(queue, ^{
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        //NSLog(@"%@", photos);
        [sh.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo
                    inManagedObjectContext:sh.managedObjectContext];
            }
        }];
    });    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
