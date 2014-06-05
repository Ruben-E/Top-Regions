//
//  Region.h
//  Top Regions
//
//  Created by Ruben Ernst on 05-06-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Picture, Place;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * flickrId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * photographersCount;
@property (nonatomic, retain) NSNumber * picturesCount;
@property (nonatomic, retain) NSNumber * placesCount;
@property (nonatomic, retain) NSSet *photographers;
@property (nonatomic, retain) NSSet *pictures;
@property (nonatomic, retain) NSSet *places;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotographersObject:(Photographer *)value;
- (void)removePhotographersObject:(Photographer *)value;
- (void)addPhotographers:(NSSet *)values;
- (void)removePhotographers:(NSSet *)values;

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
