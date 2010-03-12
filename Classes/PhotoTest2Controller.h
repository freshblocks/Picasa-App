#import <Three20/Three20.h>
#import "GDataFeedPhotoAlbum.h"
#import "GData.h"
#import "GDataServiceGooglePhotos.h"
#import "GDataServiceBase.h"
#import "PhotoViewController.h"

@interface PhotoTest2Controller : TTThumbsViewController 
	<UIAlertViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> 
{
	GDataFeedPhotoAlbum *albumFeed;
	GDataServiceTicket *mPhotosFetchTicket;
	NSError *mPhotosFetchError;
	NSString *mPhotoImageURLString;
	GDataEntryPhotoAlbum *albumEntry;
	NSMutableArray *pictures;
	NSArray *photos;
	NSNumber *selectedAlbumID;
	GDataServiceGooglePhotos *googlePhotosService;
	NSArray *albums;
	UIToolbar *toolbar; // for sharing album and viewing album info
}

@property (retain, nonatomic) GDataFeedPhotoAlbum *albumFeed;
@property (retain, nonatomic) GDataEntryPhotoAlbum *albumEntry;
@property (retain, nonatomic) NSArray *photos;
@property (retain, nonatomic) NSMutableArray *pictures;
@property (nonatomic, retain) NSNumber *selectedAlbumID;
@property (nonatomic, retain) GDataServiceGooglePhotos *googlePhotosService;
@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, retain) UIToolbar *toolbar;

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (GDataServiceGooglePhotos *)googlePhotosService;
- (PhotoViewController*)createPhotoViewController;
- (void)updateUI;
- (void)fetchSelectedAlbum:(GDataEntryPhotoAlbum *) PhotoAlbumEntry;
//- (void)thumbsViewController:(PhotoTest2Controller*)controller didSelectPhoto:(id<TTPhoto>)photo;
@end