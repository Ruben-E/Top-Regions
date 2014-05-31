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
        for (NSDictionary *pictureDicionary in pictures) {
            NSString *flickrId = pictureDicionary[FLICKR_PHOTO_ID];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
            request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];

            if ([matches count] == 0) {
                //[self pictureWithFlickrInfo:picture inManagedObjectContext:context];
                NSURL *urlPlace = [FlickrFetcher URLforInformationAboutPlace:[pictureDicionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID]];
                NSData *jsonResults = [NSData dataWithContentsOfURL:urlPlace];
                NSDictionary *placeInformation = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                 options:0
                                                                                   error:NULL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
                    request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];

                    NSError *error;
                    NSArray *matches = [context executeFetchRequest:request error:&error];

                    if (matches && !error && [matches count] == 0) {
                        Picture *picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
                        picture.flickrId = flickrId;
                        picture.title = [pictureDicionary valueForKeyPath:FLICKR_PHOTO_TITLE];
                        picture.subtitle = [pictureDicionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
//                    picture.subtitle = @"";
                        picture.url = [[FlickrFetcher URLforPhoto:pictureDicionary format:FlickrPhotoFormatLarge] absoluteString];

                        NSString *photographerName = [pictureDicionary valueForKeyPath:FLICKR_PHOTO_OWNER];
                        NSString *photographerId = [pictureDicionary valueForKeyPath:FLICKR_PHOTO_OWNER_ID];

                        NSString *placeName = [FlickrFetcher extractNameOfPlace:[pictureDicionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID] fromPlaceInformation:pictureDicionary];
                        NSString *placeId = [pictureDicionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];

                        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInformation];
                        NSString *regionId = [FlickrFetcher extractRegionIdFromPlaceInformation:placeInformation];

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

                        place.isIn = region;

                        picture.takenIn = place;
                        picture.whoTook = photographer;
                    }
                });
            }
        }
    });
}

@end
