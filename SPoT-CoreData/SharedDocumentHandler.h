//
//  SharedDocumentHandler.h
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedDocumentHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (SharedDocumentHandler *)sharedDocumentHandler;

- (void)useDocumentWithOperation:(void (^)(BOOL success))block;
- (void)saveDocument;

@end
