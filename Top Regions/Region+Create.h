//
// Created by Ruben Ernst on 28-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Region.h"

@interface Region (Create)
+ (Region *)RegionByRegion:(Region *)regionInput inManagedObjectContext:(NSManagedObjectContext *)context;
@end