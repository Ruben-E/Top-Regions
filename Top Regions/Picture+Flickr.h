//
//  Picture+Create.h
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "Picture.h"

static const int MAX_REGIONS = 50;

@interface Picture (Flickr)

+ (void)loadPicturesFromFlickrArray:(NSArray *)pictures
           intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
