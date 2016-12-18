//
//  Copyright (c) 2015 REA. All rights reserved.
//

#import "ViewController.h"
#import "HomeTime-Swift.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tramTimesTable;
@property (strong, nonatomic) NSArray *northTrams;
@property (strong, nonatomic) NSArray *southTrams;
@property (assign, nonatomic) BOOL loadingNorth;
@property (assign, nonatomic) BOOL loadingSouth;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation ViewController

- (void)awakeFromNib
{
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  self.session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self clearTramData];
}

#pragma mark - Actions

- (IBAction)clearButtonTapped:(UIBarButtonItem *)sender
{
  [self clearTramData];
}

- (void)clearTramData
{
  self.northTrams = nil;
  self.southTrams = nil;
  self.loadingNorth = NO;
  self.loadingSouth = NO;
  
  [self.tramTimesTable reloadData];
}

- (IBAction)loadButtonTapped:(UIBarButtonItem *)sender
{
  [self clearTramData];
  [self loadTramData];
}

- (void)loadTramData
{
  self.loadingNorth = YES;
  self.loadingSouth = YES;
  
  if (self.token != nil)
  {
    NSLog(@"Token: %@", self.token);
    [self loadTramDataUsingToken:self.token];
  }
  else
  {
    [self fetchApiToken:^(NSString *token, NSError *error) {
      if (error != nil)
      {
        self.loadingNorth = NO;
        self.loadingSouth = NO;
        NSLog(@"Error retrieving token: %@", error);
      }
      else
      {
        self.token = token;
        NSLog(@"Token: %@", self.token);
        [self loadTramDataUsingToken:token];
      }
    }];
  }
}

- (void)fetchApiToken:(void (^)(NSString *token, NSError *error))completion
{
  NSString *tokenUrl = @"http://ws3.tramtracker.com.au/TramTracker/RestService/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS";
  
  [self loadTramApiResponseFromUrl:tokenUrl
                        completion:^(NSArray *response, NSError *error) {
                          NSDictionary *tokenObject = response.firstObject;
                          NSString *token = tokenObject[@"DeviceToken"];
                          completion(token, error);
                        }];
}

- (void)loadTramDataUsingToken:(NSString *)token
{
  NSString *northStopId = @"4055";
  NSString *northTramsUrl = [self urlForStop:northStopId token:token];
  [self loadTramApiResponseFromUrl:northTramsUrl
                        completion:^(NSArray *trams, NSError *error) {
                          self.loadingNorth = NO;
                          if (error != nil)
                          {
                            NSLog(@"Error retrieving trams: %@", error);
                          }
                          else
                          {
                            self.northTrams = trams;
                            [self.tramTimesTable reloadData];
                          }
                        }];
  
  NSString *southStopId = @"4155";
  NSString *southTramsUrl = [self urlForStop:southStopId token:token];
  [self loadTramApiResponseFromUrl:southTramsUrl
                        completion:^(NSArray *trams, NSError *error) {
                          self.loadingSouth = NO;
                          if (error != nil)
                          {
                            NSLog(@"Error retrieving trams: %@", error);
                          }
                          else
                          {
                            self.southTrams = trams;
                            [self.tramTimesTable reloadData];
                          }
                        }];
}

- (NSString *)urlForStop:(NSString *)stopId token:(NSString *)token
{
  NSString *urlTemplate = @"http://ws3.tramtracker.com.au/TramTracker/RestService/GetNextPredictedRoutesCollection/{STOP_ID}/78/false/?aid=TTIOSJSON&cid=2&tkn={TOKEN}";
  return [[urlTemplate stringByReplacingOccurrencesOfString:@"{STOP_ID}" withString:stopId] stringByReplacingOccurrencesOfString:@"{TOKEN}" withString:token];
}

- (void)loadTramApiResponseFromUrl:(NSString *)tramsUrl completion:(void (^)(NSArray *responseData, NSError *error))completion
{
  NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:tramsUrl]
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
                                             if (requestError != nil)
                                             {
                                               completion(nil, requestError);
                                             }
                                             else
                                             {
                                               NSError *jsonError = nil;
                                               NSDictionary *jsonRespsone = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&jsonError];
                                               
                                               if (jsonRespsone == nil)
                                               {
                                                 completion(nil, jsonError);
                                               }
                                               else
                                               {
                                                 completion(jsonRespsone[@"responseObject"], nil);
                                               }
                                             }
  }];
  [task resume];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return (section == 0) ? @"North" : @"South";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
  {
    return (self.northTrams != nil) ? self.northTrams.count : 1;
  }
  else
  {
    return (self.southTrams != nil) ? self.southTrams.count : 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TramCellIdentifier" forIndexPath:indexPath];
  
  NSArray *trams = [self tramsForSection:indexPath.section];
  if (trams != nil)
  {
    NSDictionary *tram = trams[indexPath.row];
    NSString *arrivalDateString = tram[@"PredictedArrivalDateTime"];
    DotNetDateConverter *dateConverter = [[DotNetDateConverter alloc] init];
    cell.textLabel.text = [dateConverter formattedDateFromString:arrivalDateString];
  }
  else if([self isLoadingSection:indexPath.section])
  {
    cell.textLabel.text = @"Loading upcoming trams...";
  }
  else
  {
    cell.textLabel.text = @"No upcoming trams. Tap load to fetch";
  }
  
  return cell;
}

- (NSArray *)tramsForSection:(NSInteger)section
{
  return (section == 0) ? self.northTrams : self.southTrams;
}

- (BOOL)isLoadingSection:(NSInteger)section
{
  return (section == 0) ? self.loadingNorth : self.loadingSouth;
}

#pragma mark - UITableViewDelegate


@end
