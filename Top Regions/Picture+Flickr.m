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

+ (Picture *)pictureWithFlickrInfo:(NSDictionary *)pictureDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Picture *picture = nil;
    
    NSString *flickrId = pictureDictionary[FLICKR_PHOTO_ID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
    request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        // Handle error
    } else if ([matches count]) {
        picture = [matches firstObject];
    } else {
        NSURL *urlPlace =[FlickrFetcher URLforInformationAboutPlace:[pictureDictionary valueForKeyPath: FLICKR_PHOTO_PLACE_ID]];
        NSData *jsonResults = [NSData dataWithContentsOfURL:urlPlace];
        NSDictionary *placeInformation =[NSJSONSerialization JSONObjectWithData:jsonResults
                                                                        options:0
                                                                          error:NULL];

        picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
        picture.flickrId = flickrId;
        picture.title = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        picture.subtitle = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        picture.url = [[FlickrFetcher URLforPhoto:pictureDictionary format:FlickrPhotoFormatLarge] absoluteString];
        
        NSString *photographerName = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        NSString *photographerId = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_OWNER_ID];

        NSString *placeName = [FlickrFetcher extractNameOfPlace:[pictureDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID] fromPlaceInformation:pictureDictionary];
        NSString *placeId = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];

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
    
    return picture;
}

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *picture in pictures) {
        [self pictureWithFlickrInfo:picture inManagedObjectContext:context];
    }
}

@end
