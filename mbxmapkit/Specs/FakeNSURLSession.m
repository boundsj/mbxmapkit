#import "FakeNSURLSession.h"

@implementation FakeNSURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    return nil;    
}
@end
