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
    cell.detailTextLabel.text = picture.description;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:picture.thumbnail]];

    return cell;
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