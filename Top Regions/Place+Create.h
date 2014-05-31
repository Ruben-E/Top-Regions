//
// Created by Ruben Ernst on 28-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface Place (Create)
+ (Place *)PlaceByPlace:(Place *)placeInput inManagedObjectContext:(NSManagedObjectContext *)context;
@end