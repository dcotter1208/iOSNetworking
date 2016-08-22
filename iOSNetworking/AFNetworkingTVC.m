//
//  AFNetworkingTVC.m
//  iOSNetworking
//
//  Created by Cotter on 8/21/16.
//  Copyright © 2016 Cotter. All rights reserved.
//

#import "AFNetworkingTVC.h"
#import "AFNetworking.h"

@interface AFNetworkingTVC ()

@property(nonatomic, strong) NSMutableArray *barArray;

@end

@implementation AFNetworkingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _barArray = [[NSMutableArray alloc]init];
    [self foursquareDetroitCoffeeShops];
}

-(void)foursquareDetroitCoffeeShops {
    
    NSString *categoryID = @"4bf58dd8d48988d116941735";
    NSString *foursquareAPIClientID = @"CFITOPDZUHBDVUIVCHOC5XUCVZ5OVHE40RIIUZA2AZXLSMUZ";
    NSString *foursquareAPIClientSecret = @"E4EG5TBFZDLGUSJDEOGMFRNAQCDU03W3JQDBD0T31G5HH35J";
    
    NSString *URLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=42.3314,-83.0457&categoryId=%@&v=20130815&client_id=%@&client_secret=%@", categoryID, foursquareAPIClientID, foursquareAPIClientSecret];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSArray *venueArray = [responseObject valueForKeyPath:@"response.venues"];
            
            for (NSDictionary *venue in venueArray) {
                [_barArray addObject:[venue valueForKey:@"name"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [dataTask resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_barArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%li) %@", indexPath.row + 1,_barArray[indexPath.row]];
    
    return cell;
}


@end
