//
//  Photographer.h
//  Top Regions
//
//  Created by Ruben Ernst on 22-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPicturesObject:(NSManagedObject *)value;
- (void)removePicturesObject:(NSManagedObject *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
