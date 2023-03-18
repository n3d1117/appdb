#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * UADSSessionId handles generating a shared user sessionId to be used across Unity services.
 * Use this id to tie data from the same session together.
 */
@interface UADSSessionId : NSObject

/**
 * Static method to return a singleton instance of UADSSessionId.
 *
 * @return UADSSessionId
 */
+ (instancetype)shared;

/**
 * Method to get the string session UUID.
 *
 * @return NSString
 */
- (NSString *)sessionId;

@end

NS_ASSUME_NONNULL_END
