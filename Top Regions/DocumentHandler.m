//
// Created by Ruben Ernst on 27-05-14.
// Source: http://themainthread.com/blog/2012/03/core-data-with-a-single-shared-uimanageddocument.html
//

#import "DocumentHandler.h"
#import "PicturesDatabaseAvailability.h"
#import <CoreData/CoreData.h>


@interface DocumentHandler ()
- (void)objectsDidChange:(NSNotification *)notification;
- (void)contextDidSave:(NSNotification *)notification;
@end;

@implementation DocumentHandler

@synthesize document = _document;

static DocumentHandler *_sharedInstance;

+ (DocumentHandler *)sharedDocumentHandler
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"MyDocument.md"];

        self.document = [[UIManagedDocument alloc] initWithFileURL:url];

        // Set our document up for automatic migrations
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        self.document.persistentStoreOptions = options;

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectsDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.document.managedObjectContext];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.document.managedObjectContext];
    }
    return self;
}

- (void)performWithDocument:(OnDocumentReady)onDocumentReady
{
    void (^OnDocumentDidLoad)(BOOL) = ^(BOOL success) {
        onDocumentReady(self.document);
    };

    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        [self.document saveToURL:self.document.fileURL
                forSaveOperation:UIDocumentSaveForCreating
               completionHandler:OnDocumentDidLoad];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:OnDocumentDidLoad];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        OnDocumentDidLoad(YES);
    }
}

- (void)objectsDidChange:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"NSManagedObjects did change.");
#endif
}

- (void)contextDidSave:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"NSManagedContext did save.");
#endif
}

@end