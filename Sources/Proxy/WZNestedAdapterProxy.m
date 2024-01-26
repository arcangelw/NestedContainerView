//
//  WZNestedAdapterProxy.m
//  
//
//  Created by 吴哲 on 2024/1/31.
//

#import "WZNestedAdapterProxy.h"

@implementation WZNestedAdapterProxy {
    __weak id<UIScrollViewDelegate> _scrollViewTarget;
    __weak id _interceptor;
}

- (instancetype)initWithScrollViewTarget:(id<UIScrollViewDelegate>)scrollViewTarget interceptor:(id)interceptor
{
    if (!scrollViewTarget) {
        return nil;
    }
    self = [super init];
    if (self) {
        _scrollViewTarget = scrollViewTarget;
        _interceptor = interceptor;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self isInterceptedSelector:aSelector]) {
        return YES;
    }
    if ([_interceptor respondsToSelector:aSelector]) {
        return YES;
    }
    return [_scrollViewTarget respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self isInterceptedSelector:aSelector]) return _interceptor;
    id interceptor = _interceptor;
    if ([interceptor respondsToSelector:aSelector]) return interceptor;
    return _scrollViewTarget;
}

// handling unimplemented methods and nil target/interceptor
// https://github.com/Flipboard/FLAnimatedImage/blob/76a31aefc645cc09463a62d42c02954a30434d7d/FLAnimatedImage/FLAnimatedImage.m#L786-L807
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    void *nullPointer = NULL;
    [anInvocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)isProxy {
    return YES;
}

- (BOOL)isInterceptedSelector:(SEL)aSelector
{
    return (
            // UIScrollViewDelegate
            aSelector == @selector(scrollViewDidScroll:) ||
            aSelector == @selector(scrollViewWillBeginDragging:) ||
            aSelector == @selector(scrollViewDidEndDragging:willDecelerate:) ||
            aSelector == @selector(scrollViewDidEndDecelerating:) ||
            aSelector == @selector(scrollViewShouldScrollToTop:) ||
            aSelector == @selector(scrollViewDidScrollToTop:) ||
            aSelector == @selector(scrollViewDidEndScrollingAnimation:)
            // UITableViewDelegate
//            aSelector == @selector(tableView:viewForHeaderInSection:) ||
//            aSelector == @selector(tableView:heightForHeaderInSection:) ||
//            aSelector == @selector(tableView:heightForRowAtIndexPath:) ||
//            aSelector == @selector(tableView:viewForFooterInSection:) ||
//            aSelector == @selector(tableView:heightForFooterInSection:) ||
//            aSelector == @selector(tableView:willDisplayHeaderView:forSection:) ||
//            aSelector == @selector(tableView:didEndDisplayingHeaderView:forSection:) ||
//            aSelector == @selector(tableView:willDisplayCell:forRowAtIndexPath:) ||
//            aSelector == @selector(tableView:didEndDisplayingCell:forRowAtIndexPath:) ||
//            aSelector == @selector(tableView:willDisplayFooterView:forSection:) ||
//            aSelector == @selector(tableView:didEndDisplayingFooterView:forSection:)
            );
}
@end
