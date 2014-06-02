//
//  Picture.h
//  Top Regions
//
//  Created by Ruben Ernst on 02-06-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Place, Region;

@interface Picture : NSManagedObject

@property (nonatomic, retain) NSString * flickrId;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uploadedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) Place *takenIn;
@property (nonatomic, retain) Photographer *whoTook;

@end
