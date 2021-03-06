#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import <ChatKit/CKDNDList.h>
#import <IMCore/IMHandle.h>
#import <IMCore/IMPerson.h>
#import <IMCore/IMServiceImpl.h>

@implementation HBTSContactHelper

+ (BOOL)isHandleMuted:(NSString *)handle {
	// if ignore DND is enabled and the feature is available (iOS 8.2+)
	if ([HBTSPreferences sharedInstance].ignoreDNDSenders && %c(CKDNDList)) {
		// get the unmute date, which is probably either nil (not muted) or distantFuture (muted)
		NSDate *unmuteDate = [(CKDNDList *)[%c(CKDNDList) sharedList] unmuteDateForIdentifier:handle];

		// if the date is non-nil and still in the future, the handle is muted
		return unmuteDate && [unmuteDate compare:[NSDate date]] == NSOrderedDescending;
	}

	return NO;
}

+ (NSString *)nameForHandle:(NSString *)handle useShortName:(BOOL)shortName {
	// hardcoded sample name used in the test alerts
	if ([handle isEqualToString:@"example@hbang.ws"]) {
		return @"Johnny Appleseed";
	}

	static IMServiceImpl *service;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		service = [[%c(IMServiceImpl) alloc] init];
	});

	// try and get a person object
	IMPerson *person = [service imABPeopleWithScreenName:handle].firstObject;

	// for short name, get the IMHandle and try _displayNameWithAbbreviation. if that’s nil or if we
	// want a full name, use the person name. if none of these are available, fall back to the handle
	if (shortName) {
		IMHandle *imHandle = [%c(IMHandle) imHandlesForIMPerson:person].firstObject;
		NSString *result = imHandle._displayNameWithAbbreviation;

		if (result) {
			return result;
		}
	}

	return person.name ?: handle;
}

@end
