//
//  FlickrPhotoTVC.h
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Tag.h"

@interface FlickrPhotoTVC : CoreDataTableViewController

@property (nonatomic, strong) Tag *tag;

@end
