//
//  PhotoViewController.h
//  Top Places
//
//  Created by Ruben Ernst on 29-04-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface PictureViewController : UIViewController

@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSString *pictureTitle;

@end
