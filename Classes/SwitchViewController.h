//
//  SwitchViewController.h
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GDataServiceGooglePhotos.h"
#import "GDataEntryPhoto.h"
#import "GDataEntryPhotoAlbum.h"
#import "GDataFeedPhoto.h"
#import "GDataFeedPhotoUser.h"
@class AlbumViewController;
@class LogonViewController;

@interface SwitchViewController : UIViewController {
	AlbumViewController *albumViewController;
	LogonViewController *logonViewController;
	IBOutlet UITabBarController *rootController;

}

@property (retain, nonatomic) AlbumViewController *albumViewController;
@property (retain, nonatomic) LogonViewController *logonViewController;
@property (retain, nonatomic) UITabBarController *rootController;
-(IBAction) switchViews:(id) sender;
- (GDataServiceGooglePhotos *)googlePhotosService;
- (void)alertError;
- (void)fetchAllAlbums;
@end
