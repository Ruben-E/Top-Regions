//
// Created by Ruben Ernst on 28-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)
+ (Place *)placeWithPlaceId:(NSString *)placeId inManagedObjectContext:(NSManagedObjectContext *)context {
    Place *place = nil;

    if ([placeId length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"placeId = %@", placeId];

        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];

        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name = name;
        } else {
            place = [matches lastObject];
        }
    }

    return place;
}
@end