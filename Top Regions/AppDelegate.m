//
//  AppDelegate.m
//  Top Regions
//
//  Created by Ruben Ernst on 20-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Picture+Flickr.h"
#import "DocumentHandler.h"
#import "PicturesDatabaseAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property(copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property(strong, nonatomic) NSURLSession *flickrDownloadSession;
@property(strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

#define FLICKR_FETCH @"Flickr just uploaded fetch"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self startFlickrFetch];
    return YES;
}

- (void)startFlickrFetch {
    [[DocumentHandler sharedDocumentHandler] performWithDocument:^(UIManagedDocument *document) {
        self.managedObjectContext = [document managedObjectContext];
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
                NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:url];
                task.taskDescription = FLICKR_FETCH;
                [task resume];
            } else {
                for (NSURLSessionDownloadTask *task in downloadTasks) {
                    [task resume];
                }
            }
        }];
    }];
}

- (void)startFlickrFetch:(NSTimer *)timer {
    [self startFlickrFetch];
}

- (NSURLSession *)flickrDownloadSession {
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }

    return _flickrDownloadSession;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url {
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void (^)())whenDone {
    if (context) {
        NSArray *pictures = [self flickrPhotosAtURL:localFile];
        NSLog(@"Number of pictures: %d", [pictures count]);
        [context performBlock:^{
            [Picture loadPicturesFromFlickrArray:pictures intoManagedObjectContext:context andThenExecuteBlock:^{
                [context save:NULL];
                if (whenDone) whenDone();
            }];
        }];
    } else {
        if (whenDone) whenDone();
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (self.managedObjectContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                        completionHandler(UIBackgroundFetchResultNoData);
                    } else {
                        NSLog(@"Background fetch succesful");
                        [self loadFlickrPhotosFromLocalURL:localFile
                                               intoContext:self.managedObjectContext
                                       andThenExecuteBlock:^{
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                        ];
                    }
                }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }

}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile {
//    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
//        [self loadFlickrPhotosFromLocalURL:localFile
//                               intoContext:[DatabaseHelper context]
//                       andThenExecuteBlock:^{
//                           [self flickrDownloadTasksMightBeComplete];
//                       }
//         ];
//    }
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        NSArray *pictures = [self flickrPhotosAtURL:localFile];
        if (self.managedObjectContext) {
            [self.managedObjectContext performBlock:^{
                [Picture loadPicturesFromFlickrArray:pictures intoManagedObjectContext:self.managedObjectContext andThenExecuteBlock:NULL];
                [self.managedObjectContext save:NULL];
            }];
        } else {
            [self flickrDownloadTasksMightBeComplete];
        }
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
}

- (void)flickrDownloadTasksMightBeComplete {
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;

    [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL target:self selector:@selector(startFlickrFetch:) userInfo:nil repeats:YES];

    if (managedObjectContext) {
        NSDictionary *userInfo = @{PicturesDatabaseAvailabilityContext : managedObjectContext};
        [[NSNotificationCenter defaultCenter] postNotificationName:PicturesDatabaseAvailabilityNotification object:self userInfo:userInfo];
    }
}

@end
