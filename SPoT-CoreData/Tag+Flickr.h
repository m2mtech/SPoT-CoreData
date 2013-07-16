//
//  Tag+Flickr.h
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "Tag.h"

@interface Tag (Flickr)

+ (NSSet *)tagsFromFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
