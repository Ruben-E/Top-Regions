//
// Created by Ruben Ernst on 02-06-14.
// Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "RegionCDTVC.h"
#import "Region.h"
#import "Picture.h"
#import "PictureViewController.h"


@implementation RegionCDTVC

- (void)setRegion:(Region *)region {
    _region = region;

    self.managedObjectContext = [region managedObjectContext];
}


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
    request.predicate = [NSPredicate predicateWithFormat:@"region.flickrId = %@", self.region.flickrId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Picture *picture = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = picture.title;
    cell.detailTextLabel.text = picture.subtitle;
    [cell.imageView setImage:[UIImage imageWithData:picture.thumbnail]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *) detail).viewControllers firstObject];
    }

    if ([detail isKindOfClass:[PictureViewController class]]) {
        Picture *picture = [self.fetchedResultsController objectAtIndexPath:indexPath];
        PictureViewController *pictureViewController = (PictureViewController *) detail;

        [self prepareImagePictureViewController:pictureViewController toDisplayPicture:picture];
    }
}

- (void)prepareImagePictureViewController:(PictureViewController *)pictureViewController toDisplayPicture:(Picture *)picture {
    pictureViewController.pictureURL = [NSURL URLWithString:picture.url];
    pictureViewController.pictureTitle = picture.title;
    pictureViewController.title = picture.title;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPicture"]) {
        PictureViewController *pictureViewController = (PictureViewController *)[segue destinationViewController];

        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        Picture *picture = [self.fetchedResultsController objectAtIndexPath:indexPath];

        if (picture) {
            [self prepareImagePictureViewController:pictureViewController toDisplayPicture:picture];
        }
    }
}


@end