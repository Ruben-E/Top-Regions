//
//  Picture+Create.h
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Picture.h"

@interface Picture (Flickr)

+ (Picture *)pictureWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures
           intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
