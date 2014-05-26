//
//  DatabaseHelper.m
//  Top Regions
//
//  Created by Ruben Ernst on 26-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper

+ (UIManagedDocument *)managedDocument {
    static UIManagedDocument *_managedDocument = nil;
    
    if (!_managedDocument) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *baseDir=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _managedDocument = [[UIManagedDocument alloc] initWithFileURL:[baseDir URLByAppendingPathComponent:@"TopRegions"]];
    }
    
    return _managedDocument;
}

@end
