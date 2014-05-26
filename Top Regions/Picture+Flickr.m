//
//  Picture+Flickr.m
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Picture+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

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
        picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
        picture.flickrId = flickrId;
        picture.title = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        picture.subtitle = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        picture.url = [[FlickrFetcher URLforPhoto:pictureDictionary format:FlickrPhotoFormatLarge] absoluteString];
        
        NSString *photographerName = [pictureDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        picture.whoTook = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    }
    
    return picture;
}

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures intoManagedObjectContext:(NSManagedObjectContext *)context {
    
}

@end
