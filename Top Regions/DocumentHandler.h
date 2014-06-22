//
// Created by Ruben Ernst on 27-05-14.
// Source: http://themainthread.com/blog/2012/03/core-data-with-a-single-shared-uimanageddocument.html
//

#import <Foundation/Foundation.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface DocumentHandler : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

+ (DocumentHandler *)sharedDocumentHandler;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end