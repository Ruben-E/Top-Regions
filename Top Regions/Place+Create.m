//
// Created by Ruben Ernst on 28-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)
+ (Place *)PlaceByPlace:(Place *)placeInput inManagedObjectContext:(NSManagedObjectContext *)context {
    Place *place = nil;

    if (placeInput.flickrId) {
        NSString *flickrId = placeInput.flickrId;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];

        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
            place.name = placeInput.name;
            place.flickrId = placeInput.flickrId;
        } else {
            place = [matches lastObject];
            if (![place.name isEqualToString:placeInput.name]) {
                place.name = placeInput.name;
            }
        }
    }

    return place;
}
@end