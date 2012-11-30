//
//  GPEntryViewController.m
//  GrowingPains
//
//  Created by Kyle Clegg on 11/28/12.
//  Copyright (c) 2012 Kyle Clegg. All rights reserved.
//

#import "GPEntryViewController.h"
#import "GPHelpers.h"
#import <QuartzCore/QuartzCore.h>

@interface GPEntryViewController ()

@end

@implementation GPEntryViewController

@synthesize currentEntry = _currentEntry;
@synthesize entryPicture = _entryPicture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  // Set custom font for title
  [GPHelpers setCustomFontsForTitle:NSLocalizedString(@"ENTRY", nil) forViewController:self];
  
  // Load the picture
//  UIImageView *pictureImageView = (UIImageView *)[cell viewWithTag:1];
  GPPicture *picture = self.currentEntry.picture;
  NSString *baseUrl = [[RKClient sharedClient] baseURL].absoluteString;
  NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, picture.pictureUrl]];
  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
  UIImage *image = [UIImage imageWithData:imageData];
  self.entryPicture.image = image;
  
  if (picture.pictureUrl == nil) {
    UIImage *stockImage = [UIImage imageNamed:@"TakePhoto.png"];
    self.entryPicture.image = stockImage;
  }
  
  // Make picture circular
  self.entryPicture.layer.cornerRadius = 5.0;
  self.entryPicture.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
