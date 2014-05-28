//
//  Place.h
//  Top Regions
//
//  Created by Ruben Ernst on 28-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Picture, Region;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * flickrId;
@property (nonatomic, retain) Region *isIn;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
