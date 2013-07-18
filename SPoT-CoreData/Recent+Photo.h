//
//  Recent+Photo.h
//  SPoT-CoreData
//
//  Created by Martin Mandl on 17.07.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "Recent.h"
#import "Photo.h"

@interface Recent (Photo)

+ (Recent *)recentPhoto:(Photo *)photo;

@end
