//
//  Photo+Flickr.m
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Flickr.h"
#import "Recent.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",
                         [photoDictionary[FLICKR_PHOTO_ID] description]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];    
    if (!matches || ([matches count] > 1) || error) {
        NSLog(@"Error in photoWithFlickrInfo: %@ %@", matches, error);
    } else if (![matches count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.firstLetter = [photo.title substringToIndex:1];
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary
                                              format:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? FlickrPhotoFormatOriginal : FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary
                                                  format:FlickrPhotoFormatSquare] absoluteString];

        photo.tags = [Tag tagsFromFlickrInfo:photoDictionary
                      inManagedObjectContext:context];
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}

- (void)delete
{
    for (Tag *tag in self.tags) {
        if ([tag.photos count] == 1) [self.managedObjectContext deleteObject:tag];
    }
    self.tags = nil;
    if (self.recent) [self.managedObjectContext deleteObject:self.recent];
}

@end
