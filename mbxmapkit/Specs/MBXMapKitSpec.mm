#import "MBXMapKit.h"
#import "FakeNSURLSession.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MBXMapViewTileOverlay ()

- (NSString *)cachePathForTilePath:(MKTileOverlayPath)path;

@end

SPEC_BEGIN(MBXMapKitSpec)

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

fdescribe(@"MBXMapViewTileOverlay", ^{
    __block MBXMapViewTileOverlay *tileOverlay;
    __block NSString *cachePathResult;
    
    beforeEach(^{
        tileOverlay = [[MBXMapViewTileOverlay alloc] initWithURLTemplate:@"https://a.tiles.mapbox.com/v3/justin.pdxcarts/{z}/{x}/{y}.png"];
    });
    
    describe(@"-cachePathForTilePath:", ^{
        subjectAction(^{
            MKTileOverlayPath path;
            path.x = 1;
            path.y = 1;
            path.z = 1;
            cachePathResult = [tileOverlay cachePathForTilePath:path];
        });
        
        it(@"should set the correct path", ^{
            cachePathResult should equal(@"blarg");
        });
    });
    
});

SPEC_END
