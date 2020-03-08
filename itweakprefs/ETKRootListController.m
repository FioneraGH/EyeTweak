#include "ETKRootListController.h"

@implementation ETKRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (void)respring:(id)sender {
	// pid_t pid;
    // const char* args[] = {"/usr/bin/killall", "-9", "backboardd", NULL};
    // posix_spawn(&pid, args[0], NULL, NULL, (char* const*)args, NULL);
	
	[NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"-9", @"backboardd"]];
}

- (void)ldrestart:(id)sender {
	// pid_t pid;
	// const char* args[] = {"/usr/bin/ldrestart", NULL};
    // posix_spawn(&pid, args[0], NULL, NULL, (char* const*)args, NULL);

	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"LDRestart" message:@"LDRestart is used to restart daemons.\n(Use ldRun to acheive it)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
	UIAlertAction *ldrestartAction = [UIAlertAction actionWithTitle:@"LDRestart" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[NSTask launchedTaskWithLaunchPath:@"/usr/bin/ldRun" arguments:@[]];
	}];
	[alertController addAction:ldrestartAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
