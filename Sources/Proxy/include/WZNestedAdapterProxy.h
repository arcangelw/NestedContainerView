//
//  WZNestedAdapterProxy.h
//  
//
//  Created by 吴哲 on 2024/1/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(NestedAdapterProxy)
@interface WZNestedAdapterProxy : NSObject<UITableViewDelegate, UIScrollViewDelegate>

- (nullable instancetype)initWithScrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget
                                 interceptor:(id)interceptor;
/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
