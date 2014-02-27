#import "MBXMapKit.h"
#import "FakeNSURLSession.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MBXMapKitSpec)

describe(@"MBXMapKit", ^{
    
    describe(@"MBXMapView", ^{
        __block MBXMapView *mapView;
        __block FakeNSURLSession *fakeSession;
        
        beforeEach(^{
            fakeSession = [[FakeNSURLSession alloc] init];
            spy_on(fakeSession);
            
            spy_on([NSURLSession class]);
            [NSURLSession class] stub_method(@selector(sessionWithConfiguration:)).and_return(fakeSession);
            
            mapView = [[MBXMapView alloc] initWithFrame:CGRectZero mapID:@"amapid"];
        });
        
        it(@"should make a request for tile JSON", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://a.tiles.mapbox.com/v3/amapid.json"];
            fakeSession should have_received(@selector(dataTaskWithURL:completionHandler:)).with(url, Arguments::anything);
        });
    });
});

SPEC_END
