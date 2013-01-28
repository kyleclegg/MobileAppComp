//
//  GPHomeScreenViewController.m
//  GrowingPains
//
//  Created by Taylor McGann on 11/14/12.
//  Copyright (c) 2012 Kyle Clegg. All rights reserved.
//

#import "GPHomeScreenController.h"
#import <QuartzCore/QuartzCore.h>
#import "GPHelpers.h"
#import "GPModels.h"
#import "GPUserSingleton.h"
#import "GPJournalTabBarController.h"
#import "UIViewController+NavBarSetup.h"

@interface GPHomeScreenController ()

@property (strong, nonatomic) NSString *jsonJournals;

@end

@implementation GPHomeScreenController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Setup back button
  [self setupBackButton:self.navigationItem];
  
  // Set the settings button to an admin cog
  UIBarButtonItem *cogItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                              style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(openSettings)];
  [cogItem setImage:[UIImage imageNamed:@"cog.png"]];
  [self.navigationItem setLeftBarButtonItem:cogItem];

  // Set custom font for title
  [GPHelpers setCustomFontsForTitle:NSLocalizedString(@"APP_NAME", nil) forViewController:self];
  
  [self.tableView setRowHeight:130];
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  [self loadJournalsFromServer];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  // Send selected journal forward to next view controller
  if ([segue.identifier isEqualToString:@"View Journal"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    GPJournalTabBarController *journalController = segue.destinationViewController;
    GPJournal *currentJournal = [[GPUserSingleton sharedGPUserSingleton].journals objectAtIndex:indexPath.row];
    journalController.currentJournalId = currentJournal.journalId;
    DLog(@"currentJournalId: %i", currentJournal.journalId);
  }
  
  // Set the delegate on the next view controller
  if ([segue.identifier isEqualToString:@"Add Journal"]) {
    GPCreateJournalController *createJournalController = segue.destinationViewController;
    createJournalController.delegate = self;
  }
}

- (void)openSettings {
  [self performSegueWithIdentifier:@"Open Settings" sender:self];
}

- (void)loadJournalsFromServer {
  // Load journals
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSLog(@"\n\nGETTING JOURNALS\n\n");
  NSString *getJournalsURL = [NSString stringWithFormat:@"/users/%i/journals.json", [GPUserSingleton sharedGPUserSingleton].userId];
  [[RKObjectManager sharedManager] loadObjectsAtResourcePath:getJournalsURL delegate:self];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  NSString *cellIdentifier = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
  DLog(@"selected %@", cellIdentifier);
  
  if ([cellIdentifier isEqualToString:@"JournalCell"]) {
    [self performSegueWithIdentifier:@"View Journal" sender:self];
  }
  
  // Must do this last so that prepareForSegue:sender: can access indexPath
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
  // If there is no sharedUser or no journals for the given user, return 0 and set a loading/add journals message
  if ([GPUserSingleton sharedGPUserSingleton] == nil || [GPUserSingleton sharedGPUserSingleton].journals == nil) {
    return 0;
  }
  else {
    return [GPUserSingleton sharedGPUserSingleton].journals.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
	static NSString *CellIdentifier = @"JournalCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    [self tableViewCellWithReuseIdentifier:CellIdentifier];
  }
  
  // Configure the cell...
  [self configureCell:cell forIndexPath:indexPath];

	return cell;
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier
{
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
  
  // Setup our colors
  CGFloat nRed=207.0/255.0;
  CGFloat nBlue=209.0/255.0;
  CGFloat nGreen=88.0/255.0;
  UIColor *greenColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
  
  nRed=252.0/255.0;
  nBlue=200./255.0;
  nGreen=96.0/255.0;
  UIColor *orangeColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
  
  nRed=227.0/255.0;
  nBlue=84.0/255.0;
  nGreen=68.0/255.0;
  UIColor *redColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
  
  
  // If there is no sharedUser or no journals for the given user, return
  if ([GPUserSingleton sharedGPUserSingleton] == nil || [GPUserSingleton sharedGPUserSingleton].journals == nil) {
    return;
  }

  GPJournal *currentJournal = [[GPUserSingleton sharedGPUserSingleton].journals objectAtIndex:indexPath.row];
  
  UILabel *journalNameLabel = (UILabel *)[cell viewWithTag:6];
  journalNameLabel.text = currentJournal.name;
  journalNameLabel.font = [UIFont fontWithName:@"Sanchez-Regular" size:journalNameLabel.font.pointSize];
  journalNameLabel.textColor = [UIColor lightGrayColor];
  
  UILabel *agePromptLable = (UILabel *)[cell viewWithTag:7];
  agePromptLable.font = [UIFont fontWithName:@"Sanchez-Regular" size:agePromptLable.font.pointSize];
  agePromptLable.textColor = [UIColor lightGrayColor];
  
  UILabel *ageLabel = (UILabel *)[cell viewWithTag:8];  
  ageLabel.text = [GPHelpers formattedAge:currentJournal.birthDate];
  ageLabel.font = [UIFont fontWithName:@"Sanchez-Regular" size:ageLabel.font.pointSize];
  
  // Loop through journal images and display them
  for (int tag = 1; tag <= 4; tag++) {
  
    // Check for saved image urls
    NSDictionary *thumbnailsDict = [[[GPUserSingleton sharedGPUserSingleton] latestImageUrlsForJournal:currentJournal.journalId] copy];

    // Obtain reference to imageview
    UIImageView *pictureImageView = (UIImageView *)[cell viewWithTag:tag];
    
    // Setup preview image to use as placeholder
    UIImage *pictureImage = [UIImage imageNamed:@"StockTakePhoto.png"];
    
    // If thumbnailsDict isn't nil, load thumbnails from URLs
    if (thumbnailsDict != nil) {
      // Load images from URL
      if (tag == 1 && [thumbnailsDict objectForKey:@"thumbnailUrl1"] != nil) {
          [GPHelpers loadImageAsynchronously:pictureImageView fromUrlString:[thumbnailsDict objectForKey:@"thumbnailUrl1"]];
      }
      else if (tag == 2 && [thumbnailsDict objectForKey:@"thumbnailUrl2"] != nil) {
        [GPHelpers loadImageAsynchronously:pictureImageView fromUrlString:[thumbnailsDict objectForKey:@"thumbnailUrl2"]];
      }
      else if (tag == 3 && [thumbnailsDict objectForKey:@"thumbnailUrl3"] != nil) {
        [GPHelpers loadImageAsynchronously:pictureImageView fromUrlString:[thumbnailsDict objectForKey:@"thumbnailUrl3"]];
      }
      else if (tag == 4 && [thumbnailsDict objectForKey:@"thumbnailUrl4"] != nil) {
        [GPHelpers loadImageAsynchronously:pictureImageView fromUrlString:[thumbnailsDict objectForKey:@"thumbnailUrl4"]];
      }
      else {
        pictureImageView.image = pictureImage;
      }
    }
    else {
      // Load from stored images
      // Change to dynamically load most recent images from db
      if (tag == 1) {
        pictureImage = [UIImage imageNamed:@"cutebaby.jpeg"];
      }
      else if (tag == 2) {
        pictureImage = [UIImage imageNamed:@"baby-girl.jpeg"];
      }
      else if (tag == 3) {
        pictureImage = [UIImage imageNamed:@"babyonphone.jpeg"];
      }
      pictureImageView.image = pictureImage;
    }
    
    // Make image circular
    pictureImageView.layer.cornerRadius = 30.0;
    pictureImageView.layer.masksToBounds = YES;
    
    // Add a thin border
    if (indexPath.row % 3 == 0) {
      pictureImageView.layer.borderColor = greenColor.CGColor;
      ageLabel.textColor = greenColor;
    }
    else if (indexPath.row % 3 == 1) {
      pictureImageView.layer.borderColor = orangeColor.CGColor;
      ageLabel.textColor = orangeColor;
    }
    else {
      pictureImageView.layer.borderColor = redColor.CGColor;
      ageLabel.textColor = redColor;
    }
    pictureImageView.layer.borderWidth = 2.0;
  }
  
  // Round the corners on the white background
  UIView *whiteBackground = (UIView *)[cell viewWithTag:9];
  whiteBackground.layer.cornerRadius = 5.0;
  whiteBackground.layer.masksToBounds = YES;
  
}

#pragma mark - RestKit Calls

// Sent when a request has finished loading
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  if ([request isGET]) {
    
    if ([response isOK]) {
      
      if ([response isOK]) {

        
        NSString* responseString = [response bodyAsString];
        DLog(@"Response string: \n\n%@", responseString);
        
        if ([responseString hasPrefix:@"{\"journals"]) {
          self.jsonJournals = responseString;
        }
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
- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	int test = [error code];
	if (test == RKRequestBaseURLOfflineError) {
    [GPHelpers showAlertWithMessage:NSLocalizedString(@"RK_CONNECTION_ERROR", nil) andHeading:NSLocalizedString(@"RK_CONNECTION_ERROR_HEADING", nil)];
		return;
	}
}

// Sent to the delegate when a request has timed out
- (void)requestDidTimeout:(RKRequest*)request
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [GPHelpers showAlertWithMessage:NSLocalizedString(@"RK_REQUEST_TIMEOUT", nil) andHeading:NSLocalizedString(@"RK_OPERATION_FAILED", nil)];
}


#pragma mark - RestKit objectLoader
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  if ([[objects objectAtIndex:0] isKindOfClass:[GPJournals class]]) {
    
    GPJournals *userJournals = [objects objectAtIndex:0];
    DLog(@"User has %i journals", userJournals.journal.count);
    
    // Save Singleton Object
    GPUserSingleton *sharedUser = [GPUserSingleton sharedGPUserSingleton];
    [sharedUser setUserJournals:userJournals.journal withString:self.jsonJournals];
  }
  
  // Force the tableview to reload, now with new journal information
  [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  NSLog(@"objectLoader failed with error: %@", error);
}

#pragma mark - Create Journal delegate method
- (void)reloadJournals:(BOOL)reloadStatus {
  
  NSLog(@"delegate fired");
  
  if (reloadStatus) {
    [self loadJournalsFromServer];
  }
}

@end
