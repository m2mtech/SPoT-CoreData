//
//  Recent.h
//  SPoT-CoreData
//
//  Created by Martin Mandl on 11.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) Photo *photo;

@end
