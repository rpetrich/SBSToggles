#define CHAppName "VPNToggle"

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <CaptainHook/CaptainHook.h>

CHDeclareClass(VPNBundleController);

static VPNBundleController *controller;

static void Prepare()
{
	// Create controller
	CHLoadLateClass(VPNBundleController);
	controller = [CHAlloc(VPNBundleController) initWithParentListController:nil];
}

#define Prepare() do { if (!controller) Prepare(); } while(0)

BOOL isCapable()
{
	return YES;
}

BOOL isEnabled()
{
	Prepare();
	return [[controller vpnActiveForSpecifier:CHIvar(controller, _vpnSpecifier, PSSpecifier *)] boolValue];
}

BOOL getStateFast()
{
	// Same as isEnabled
	return isEnabled();
}

void setState(BOOL enable)
{	
	Prepare();
	[controller _setVPNActive:enable];
}

float getDelayTime()
{
	return 0.0f;
}

CHConstructor
{
	// Load VPNPreferences
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/System/Library/PreferenceBundles/VPNPreferences.bundle"), kCFURLPOSIXPathStyle, true);
	CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, url);
	CFRelease(url);
	CFBundleLoadExecutable(bundle);
}