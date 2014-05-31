//
// Created by Ruben Ernst on 28-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Region+Create.h"


@implementation Region (Create)
+ (Region *)RegionByRegion:(Region *)regionInput inManagedObjectContext:(NSManagedObjectContext *)context {
    Region *region = nil;

    if (regionInput.flickrId) {
        NSString *flickrId = regionInput.flickrId;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];

        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
            region.name = regionInput.name;
            region.flickrId = regionInput.flickrId;
        } else {
            region = [matches lastObject];
            if ([region.name isEqualToString:regionInput.name]) {
                region.name = regionInput.name;
            }
        }
    }

    return region;
}
@end