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

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Picture *region = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = region.title;

    return cell;
}

@end
