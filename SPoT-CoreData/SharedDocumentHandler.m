//
//  SharedDocumentHandler.m
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "SharedDocumentHandler.h"

@interface SharedDocumentHandler()

@end

@implementation SharedDocumentHandler

+ (SharedDocumentHandler *)sharedDocumentHandler
{
    static dispatch_once_t pred = 0;
    __strong static SharedDocumentHandler *_sharedDocumentHandler = nil;
    dispatch_once(&pred, ^{
        _sharedDocumentHandler = [[self alloc] init];
    });
    return _sharedDocumentHandler;
}

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"SPoTDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    //NSLog(@"%@", url);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        //NSLog(@"create document");
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        //NSLog(@"open document");
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
        }];
    } else {
        //NSLog(@"use document");
        self.managedObjectContext = document.managedObjectContext;
    }
}

@end
