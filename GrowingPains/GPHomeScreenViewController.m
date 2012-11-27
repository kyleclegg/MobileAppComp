//
//  GPHomeScreenViewController.m
//  GrowingPains
//
//  Created by Taylor McGann on 11/14/12.
//  Copyright (c) 2012 Kyle Clegg. All rights reserved.
//

#import "GPHomeScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GPHelpers.h"
#import "GPModels.h"
#import "GPUserSingleton.h"
#import "GPJournalTabBarController.h"

@interface GPHomeScreenViewController ()

@end

@implementation GPHomeScreenViewController

@synthesize _tableView;

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.tableView setRowHeight:134];

  // Load journals
  NSLog(@"\n\nGETTING JOURNALS\n\n");
  NSString *getJournalsURL = [NSString stringWithFormat:@"/users/%i/journals.json", [GPUserSingleton sharedGPUserSingleton].userId];
  [[RKObjectManager sharedManager] loadObjectsAtResourcePath:getJournalsURL delegate:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"Open Journal"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    GPJournalTabBarController *journalController = segue.destinationViewController;
    GPJournal *currentJournal = [[GPUserSingleton sharedGPUserSingleton].journals objectAtIndex:indexPath.row];
    journalController.currentJournalId = currentJournal.journalId;
  }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSString *cellType = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
  
  NSLog(@"selected %@", cellType);
  
  if ([cellType isEqualToString:@"JournalCell"]) {
    [self performSegueWithIdentifier:@"Open Journal" sender:self];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  // If there is no sharedUser or no journals for the given user, return 0 and set a loading/add journals message
  if ([GPUserSingleton sharedGPUserSingleton] == nil || [GPUserSingleton sharedGPUserSingleton].journals == nil) {
    return 0;
  }
  else {
    return [GPUserSingleton sharedGPUserSingleton].journals.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
	static NSString *CellIdentifier = @"JournalCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    [self tableViewCellWithReuseIdentifier:CellIdentifier];
  }
  // Configure the cell...
  [self configureCell:cell forIndexPath:indexPath];

	return cell;
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
  
  // If there is no sharedUser or no journals for the given user, return
  if ([GPUserSingleton sharedGPUserSingleton] == nil || [GPUserSingleton sharedGPUserSingleton].journals == nil) {
    return;
  }

  GPJournal *currentJournal = [[GPUserSingleton sharedGPUserSingleton].journals objectAtIndex:indexPath.row];
  
  UILabel *journalNameLabel = (UILabel *)[cell viewWithTag:6];
  journalNameLabel.text = currentJournal.name;
//  UILabel *ageLabel = (UILabel *)[cell viewWithTag:7];
//  ageLabel.text = [NSDate date] - currentJournal.birthDate;
    
  // Add custom psuedo accessory detail
  UIImageView *arrowImageView = (UIImageView *)[cell viewWithTag:5];
  UIImage *arrowImage = [UIImage imageNamed:@"arrowImage.png"];
  [arrowImageView setImage:arrowImage];
  
  // Loop through journal images and display them
  for (int tag = 1; tag <= 4; tag++) {
    
    UIImageView *previewImageView = (UIImageView *)[cell viewWithTag:tag];
    UIImage *previewImage = [UIImage imageNamed:@"cutebaby.jpeg"];   // Dynamically load most recent images from db
    [previewImageView setImage:previewImage];
    
    // Make image circular
    previewImageView.layer.cornerRadius = 30.0;
    previewImageView.layer.masksToBounds = YES;
    
    // Add a thin border
//    previewImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    previewImageView.layer.borderWidth = 0.5;
  }
}

#pragma mark - RestKit Calls

// Sent when a request has finished loading
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
  if ([request isGET]) {
    
    if ([response isOK]) {
      
      if ([response isOK]) {
        
        NSString* responseString = [response bodyAsString];
        NSLog(@"Response is OK:\n\n%@", responseString);
        
      }
    }
  }
  else if ([request isPOST]) {
    
    NSLog(@"POST finished with status code: %i", [response statusCode]);
		
  }
  else if ([request isDELETE]) {
    
    if ([response isNotFound]) {
      NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
    }
	}
}

// Sent when a request has failed due to an error
- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
  
	int test = [error code];
	if (test == RKRequestBaseURLOfflineError) {
    [GPHelpers showAlertWithMessage:NSLocalizedString(@"RK_CONNECTION_ERROR", nil) andHeading:NSLocalizedString(@"RK_CONNECTION_ERROR_HEADING", nil)];
		return;
	}
}

// Sent to the delegate when a request has timed out
- (void)requestDidTimeout:(RKRequest*)request {
  
  [GPHelpers showAlertWithMessage:NSLocalizedString(@"RK_REQUEST_TIMEOUT", nil) andHeading:NSLocalizedString(@"RK_OPERATION_FAILED", nil)];
}


#pragma mark - RestKit objectLoader
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
  
  NSLog(@"here");
  
  if ([[objects objectAtIndex:0] isKindOfClass:[GPJournals class]]) {
    
    GPJournals *userJournals = [objects objectAtIndex:0];
    NSLog(@"User has %i journals", userJournals.journal.count);
    
    // Save Singleton Object
    GPUserSingleton *sharedUser = [GPUserSingleton sharedGPUserSingleton];
    [sharedUser setUserJournals:userJournals.journal];
  }
  
  // Force the tableview to reload, now with new journal information
  [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
  
  NSLog(@"objectLoader failed with error: %@", error);
}


@end
