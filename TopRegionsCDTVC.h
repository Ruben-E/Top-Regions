//
//  TopRegionsCDTVC.h
//  Top Regions
//
//  Created by Ruben Ernst on 26-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Region;

@interface TopRegionsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
