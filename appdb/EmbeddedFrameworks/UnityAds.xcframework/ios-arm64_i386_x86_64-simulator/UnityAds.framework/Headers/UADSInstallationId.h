#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * UADSInstallationId handles generating or retrieving an installation id across Unity services.
 */
@interface UADSInstallationId : NSObject

/**
 * Static method to return a singleton instance of UADSInstallationId.
 *
 * @return UADSInstallationId
 */
+ (instancetype)shared;

/**
 * Method to get the string installation id.
 *
 * @return NSString
 */
- (NSString *)installationId;

@end

NS_ASSUME_NONNULL_END
