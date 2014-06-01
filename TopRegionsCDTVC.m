//
//  TopRegionsCDTVC.m
//  Top Regions
//
//  Created by Ruben Ernst on 26-05-14.
//  Copyright (c) 2014 Ruben Ernst. All rights reserved.
//

#import "TopRegionsCDTVC.h"
#import "PicturesDatabaseAvailability.h"
#import "Region.h"
#import "Picture.h"

@interface TopRegionsCDTVC ()

@end

@implementation TopRegionsCDTVC

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:PicturesDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
       self.managedObjectContext = notification.userInfo[PicturesDatabaseAvailabilityContext];
    }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photographersCount" ascending:NO]];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [region.photographersCount intValue]];

    return cell;
}

@end
