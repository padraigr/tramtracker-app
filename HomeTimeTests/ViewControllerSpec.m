#import <Kiwi/Kiwi.h>
#import "ViewController.h"

@interface ViewController (Spec)
@property (strong, nonatomic) IBOutlet UITableView *tramTimesTable;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSArray *northTrams;
@property (strong, nonatomic) NSArray *southTrams;
- (void)loadTramData;
@end

SPEC_BEGIN(ViewControllerSpec)
  describe(@"ViewController", ^{
    __block ViewController *viewController;
    beforeEach(^{
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      viewController = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];

      [viewController view];
      viewController.token = @"theToken";
    });

    it(@"should have sections for north and south", ^{
      NSInteger sections = [viewController.tramTimesTable numberOfSections];
      [[theValue(sections) should] equal:@2];
    });

    it(@"should initialize no tram data", ^{
      UITableView *tramsTable = viewController.tramTimesTable;

      NSInteger north = [tramsTable numberOfRowsInSection:0];
      [[theValue(north) should] equal:@1];

      UITableViewCell *placeholderCell = [tramsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
      NSString *placeholder = placeholderCell.textLabel.text;
      [[theValue([placeholder containsString:@"No upcoming trams"]) should] beTrue];

      NSInteger south = [tramsTable numberOfRowsInSection:1];
      [[theValue(south) should] equal:@1];

    });

    it(@"should display arriveDateTime on table after load api response", ^{
      [viewController stub:@selector(loadTramApiResponseFromUrl:completion:) withBlock:^id(NSArray *params) {
        void (^completion)(NSArray *responseData, NSError *error) = params[1];
        completion(@[@{@"PredictedArrivalDateTime": @"/Date(1426821588000+1100)/"}],nil);
        return nil;
      }];
      [viewController loadTramData];

      UITableViewCell *northTramCell = [viewController.tramTimesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
      [[northTramCell.textLabel.text should] equal:@"14:19"];

      UITableViewCell *southTramCell = [viewController.tramTimesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
      [[southTramCell.textLabel.text should] equal:@"14:19"];
    });

  });
SPEC_END