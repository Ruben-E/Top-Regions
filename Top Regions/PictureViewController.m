//
//  PhotoViewController.m
//  Top Places
//
//  Created by Ruben Ernst on 29-04-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "PictureViewController.h"
#import "FlickrFetcher.h"

@interface PictureViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.pictureTitle;
    
    [self.scrollView addSubview:self.imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib {
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Top Places";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Setters / Getters

- (void)setPictureURL:(NSURL *)pictureURL {
    _pictureURL = pictureURL;
    
    [self startDownloadingImage];
}

- (void)startDownloadingImage {
    self.image = nil;
    
    if (self.pictureURL) {
        [self.activityIndicator startAnimating];
        
        //NSURL *url = [FlickrFetcher URLforPhoto:self.picture.raw format:FlickrPhotoFormatLarge];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.pictureURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:self.pictureURL]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = image;
                    });
                }
            }
        }];
        
        [task resume];
    }
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    
    [self.imageView sizeToFit];
    
    if (image) {
        self.scrollView.zoomScale = 1;
        
        //TODO: Als de vorige afbeelding kleiner is dan de breedte van het scherm wordt de volgende afbeelding te groot geladen.
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.imageView.transform = transform;
        
        self.scrollView.contentSize = self.imageView.image.size;
        
        self.imageView.frame = CGRectMake(0,0, image.size.width, image.size.height);
        
        int scrollViewWidth = self.scrollView.bounds.size.width;
        int imageViewWidth = self.imageView.frame.size.width;
        NSLog(@"ScrollViewWidth: %d", scrollViewWidth);
        NSLog(@"ImageViewWidth: %d", imageViewWidth);
        
        float zoomScale = (float) scrollViewWidth / (float) imageViewWidth;
        
        [self.scrollView setZoomScale:zoomScale];
        [self.scrollView setMinimumZoomScale:zoomScale];
        [self.scrollView setMaximumZoomScale:2.5];
        
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, zoomScale, zoomScale)
                                    animated:NO];
        
        self.title = self.pictureTitle;
        
        [self.activityIndicator stopAnimating];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    
    return _imageView;
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
    _scrollView.minimumZoomScale = 0.1;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.clipsToBounds = YES;
    
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight);
}
@end
