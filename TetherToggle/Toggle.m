#define CHAppName "TetherToggle"

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKit2.h>
#import <Preferences/Preferences.h>
#import <CaptainHook/CaptainHook.h>

CHDeclareClass(WirelessModemController);
CHDeclareClass(WirelessModemBundleController);
CHDeclareClass(UIAlertView);

@interface WirelessModemController : PSListController {
}
- (id)internetTethering:(PSSpecifier *)specifier;
- (void)setInternetTethering:(id)value specifier:(PSSpecifier *)specifier;
@end

static WirelessModemController *controller;
static PSSpecifier *specifier;
static BOOL insideToggle;

CHMethod0(void, UIAlertView, show)
{
	if (insideToggle) {
		// Make sure we're suppressing the right alert view
		if ([[self buttons] count] == 2) {
			id<UIAlertViewDelegate> delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
				[delegate alertView:self clickedButtonAtIndex:0];
				return;
			}
		}
	}
	CHSuper0(UIAlertView, show);
}

static void Prepare()
{
	// Create root controller
	PSRootController *rootController = [[PSRootController alloc] initWithTitle:@"Preferences" identifier:@"com.apple.Preferences"];
	// Create controller
	CHLoadLateClass(WirelessModemController);
	controller = [CHAlloc(WirelessModemController) initForContentSize:CGSizeZero];
	[controller setRootController:rootController];
	[controller setParentController:rootController];
	// Create Specifier
	specifier = [[PSSpecifier preferenceSpecifierNamed:@"Tethering" target:controller set:@selector(setInternetTethering:specifier:) get:@selector(internetTethering:) detail:Nil cell:PSSwitchCell edit:Nil] retain];
	// Hook UIAlertView
	CHLoadClass(UIAlertView);
	CHHook0(UIAlertView, show);
}

#define Prepare() do { if (!CHClass(UIAlertView)) Prepare(); } while(0)

BOOL isCapable()
{
	CHLoadLateClass(WirelessModemBundleController);
	WirelessModemBundleController *bundleController = [CHAlloc(WirelessModemBundleController) initWithParentListController:nil];
	BOOL result = [[bundleController specifiersWithSpecifier:nil] count] != 0;
	[bundleController release];
	return result;
}

BOOL isEnabled()
{
	Prepare();
	return [[controller internetTethering:specifier] boolValue];
}

BOOL getStateFast()
{
	// Same as isEnabled
	return isEnabled();
}

void setState(BOOL enable)
{	
	Prepare();
	insideToggle = YES;
	[controller setInternetTethering:[NSNumber numberWithBool:enable] specifier:specifier];
	insideToggle = NO;
}

float getDelayTime()
{
	return 0.0f;
}

CHConstructor
{
	// Load WirelessModemSettings
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/System/Library/PreferenceBundles/WirelessModemSettings.bundle"), kCFURLPOSIXPathStyle, true);
	CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, url);
	CFRelease(url);
	CFBundleLoadExecutable(bundle);
}