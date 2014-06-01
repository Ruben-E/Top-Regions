//
//  Picture+Create.m
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Picture+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Place.h"
#import "Region.h"
#import "Place+Create.h"
#import "Region+Create.h"

@implementation Picture (Flickr)

+ (void)pictureWithFlickrInfo:(NSDictionary *)pictureDictionary inManagedObjectContext:(NSManagedObjectContext *)context {

}

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures intoManagedObjectContext:(NSManagedObjectContext *)context {
    dispatch_queue_t placeQ =dispatch_queue_create("place fetcher", NULL);
    dispatch_async(placeQ, ^{
        NSManagedObjectContext *context2 = [[NSManagedObjectContext alloc] init];
        [context2 setPersistentStoreCoordinator:[context persistentStoreCoordinator]];

        NSMutableDictionary *places = [[NSMutableDictionary alloc] init];

        for (NSDictionary *pictureDictionary in pictures) {
            NSString *flickrId = pictureDictionary[FLICKR_PHOTO_ID];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
            request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

            NSError *error;
            NSArray *matches = [context2 executeFetchRequest:request error:&error];

            if ([matches count] == 0) {
                NSString *picturePlaceId = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
                NSDictionary *placeInformation = [[NSDictionary alloc] init];

                if (![places objectForKey:picturePlaceId]) {
                    NSURL *urlPlace = [FlickrFetcher URLforInformationAboutPlace:picturePlaceId];
                    NSData *jsonResults = [NSData dataWithContentsOfURL:urlPlace];
                    placeInformation = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];

                    [places setObject:placeInformation forKey:picturePlaceId];
                } else {
                    placeInformation = [places objectForKey:picturePlaceId];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
                    request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

                    NSError *error;
                    NSArray *matches = [context executeFetchRequest:request error:&error];

                    if (matches && !error && [matches count] == 0) {
                        Picture *picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
                        picture.flickrId = flickrId;
                        picture.title = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
                        picture.subtitle = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
                        picture.url = [[FlickrFetcher URLforPhoto:pictureDictionary format:FlickrPhotoFormatLarge] absoluteString];

                        NSString *photographerName = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
                        NSString *photographerId = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_OWNER_ID];

                        NSString *placeName = [FlickrFetcher extractNameOfPlace:[pictureDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID] fromPlaceInformation:pictureDictionary];
                        NSString *placeId = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];

                        NSString *regionId = [FlickrFetcher extractRegionIdFromPlaceInformation:placeInformation];
                        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInformation];

                        NSEntityDescription *photographerEntity = [NSEntityDescription entityForName:@"Photographer" inManagedObjectContext:context];
                        NSEntityDescription *placeEntity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
                        NSEntityDescription *regionEntity = [NSEntityDescription entityForName:@"Region" inManagedObjectContext:context];

                        Photographer *photographerDomain = [[NSManagedObject alloc] initWithEntity:photographerEntity insertIntoManagedObjectContext:nil];
                        photographerDomain.flickrId = photographerId;
                        photographerDomain.name = photographerName;

                        Place *placeDomain = [[NSManagedObject alloc] initWithEntity:placeEntity insertIntoManagedObjectContext:nil];
                        placeDomain.flickrId = placeId;
                        placeDomain.name = placeName;

                        Region *regionDomain = [[NSManagedObject alloc] initWithEntity:regionEntity insertIntoManagedObjectContext:nil];
                        regionDomain.flickrId = regionId;
                        regionDomain.name = regionName;

                        Place *place = [Place PlaceByPlace:placeDomain inManagedObjectContext:context];
                        Region *region = [Region RegionByRegion:regionDomain inManagedObjectContext:context];
                        Photographer *photographer = [Photographer photographerByPhotographer:photographerDomain inManagedObjectContext:context];

                        if (place.isIn && [place.isIn isKindOfClass:[Region class]]) {
                            if (![place.isIn.flickrId isEqualToString:regionDomain.flickrId]) {
                                place.isIn = region;
                            }
                        }

                        [region addPicturesObject:picture];

                        picture.takenIn = place;
                        picture.whoTook = photographer;


                    }
                });
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self recountCountersInManagedObjectContext:context];
        });
    });
}

+ (void)recountCountersInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *regionRequest = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    NSFetchRequest *photographerRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];

    NSArray *regions = [context executeFetchRequest:regionRequest error:nil];
    NSArray *places = [context executeFetchRequest:placeRequest error:nil];
    NSArray *photographers = [context executeFetchRequest:photographerRequest error:nil];

    for (Region *region in regions) {
        NSLog(@"Region: number of pictures: %d", [region.pictures count]);
        NSLog(@"Region: number of places: %d", [region.places count]);
        region.picturesCount = [NSNumber numberWithInt:[region.pictures count]];
        region.placesCount = [NSNumber numberWithInt:[region.places count]];
    }

    for (Place *place in places) {
        place.picturesCount = [NSNumber numberWithInt:[place.pictures count]];
    }

    for (Photographer *photographer in photographers) {
        photographer.picturesCount = [NSNumber numberWithInt:[photographer.pictures count]];
    }
}

@end
