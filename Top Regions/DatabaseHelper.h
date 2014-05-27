//
//  DatabaseHelper.h
//  Top Regions
//
//  Created by Ruben Ernst on 26-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//
//  Inspiration: http://stackoverflow.com/questions/14876988/core-data-uimanageddocument-or-appdelegate-to-setup-core-data-stack
//

#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject

//+ (UIManagedDocument *)managedDocument;


- (void)saveContext;
+ (id) sharedInstance;
+ (void)disposeInstance;
+ (NSManagedObjectContext *)context;

@end
