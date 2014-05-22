//
//  Picture+Flickr.m
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Picture+Flickr.h"
#import "Flickr

@implementation Picture (Flickr)

+ (Picture *)pictureWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Picture *picture = nil;
    
    NSString *flickrId =
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
    request.predicate = [NSPredicate predicateWithFormat:@"flickrId = %@", flickrId];
    
    return picture;
}

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures intoManagedObjectContext:(NSManagedObjectContext *)context {
    
}

@end
