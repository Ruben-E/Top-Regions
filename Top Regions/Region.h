//
//  Region.h
//  Top Regions
//
//  Created by Ruben Ernst on 01-06-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Picture, Place;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * flickrId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * picturesCount;
@property (nonatomic, retain) NSNumber * placesCount;
@property (nonatomic, retain) NSSet *places;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
