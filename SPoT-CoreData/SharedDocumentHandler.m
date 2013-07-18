//
//  SharedDocumentHandler.m
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "SharedDocumentHandler.h"

@interface SharedDocumentHandler()

@property (nonatomic, strong) UIManagedDocument *document;

@end

@implementation SharedDocumentHandler

- (UIManagedDocument *)document
{
    if (!_document) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"SPoTDocument"];
        _document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _document;
}

+ (SharedDocumentHandler *)sharedDocumentHandler
{
    static dispatch_once_t pred = 0;
    __strong static SharedDocumentHandler *_sharedDocumentHandler = nil;
    dispatch_once(&pred, ^{
        _sharedDocumentHandler = [[self alloc] init];
    });
    return _sharedDocumentHandler;
}

- (void)useDocumentWithOperation:(void (^)(BOOL))block
{
    UIManagedDocument *document = self.document;
    //NSLog(@"%@", url);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
        //NSLog(@"create document");
        [document saveToURL:document.fileURL
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
              block(success);
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        //NSLog(@"open document");
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
            block(success);
        }];
    } else {
        //NSLog(@"use document");
        self.managedObjectContext = document.managedObjectContext;
        BOOL success = YES;
        block(success);
    }
}

- (void)saveDocument
{
    [self.document saveToURL:self.document.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:NULL];
}

@end
