//
//  Photographer.h
//  Top Regions
//
//  Created by Ruben Ernst on 01-06-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Picture;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * flickrId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * picturesCount;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
