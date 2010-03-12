#import "SearchTestController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Three20/Three20.h"
#import "ShareMessageController.h"
#import "GData.h"

@class MockDataSource;

@interface MessageAddressbookTestController : TTViewController
	<TTMessageControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
	TTAddressBookDataSource* _dataSource;
	NSTimer* _sendTimer;
	ShareMessageController* mController;
	GDataEntryPhoto* photo;
	GDataEntryPhotoAlbum* albumEntry;
}
@property (nonatomic, retain) ShareMessageController* mController;
@property (nonatomic, retain) GDataEntryPhoto* photo;
@property (nonatomic, retain) GDataEntryPhotoAlbum* albumEntry;

@end