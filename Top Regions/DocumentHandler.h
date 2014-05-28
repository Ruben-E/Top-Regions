//
// Created by Ruben Ernst on 27-05-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface DocumentHandler : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

+ (DocumentHandler *)sharedDocumentHandler;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end