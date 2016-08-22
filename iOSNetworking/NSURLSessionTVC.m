//
//  NSURLSessionTVC.m
//  iOSNetworking
//
//  Created by Cotter on 8/21/16.
//  Copyright © 2016 Cotter. All rights reserved.
//


/*
 
  1: Construct the URL
 
  2: NSURLRequest:
        This creates a URL Request with the default cache policy (NSURLRequestUseProtocolCachePolicy)
        and timeout value (60 seconds).
 
 
  3: NSURLSessionConfiguration:
        Defines the behavior and policies to use when uploading and
        downloading data using an NSURLSession object. You use this object to
        configure the timeout values, caching policies, connection requirements,
        and other types of information that you intend to use with your NSURLSession object.
        
        NOTE: In some cases, the policies defined in this configuration may be overridden by
        policies specified by an NSURLRequest object provided for a task. Any policy specified
        on the request object is respected unless the session’s policy is more restrictive.

 4: NSURLSession:
        This actually creates the session for the network call. When you use the default
        configuration (like this in demo) then it let you obtain data incrementally using a delegate.
 
 5: NSURLSessionDataTask:
        This creates a task that retrieves the contents of a URL based on the specified
        URL request object, and calls a handler upon completion.
 
 6: Cast the response object in the completion handler, which is of type NSURLResponse to
    a NSHTTPURLResponse because NSHTTPURLResponse has a property called statusCode,
    which we can check to see if we get a good respone back from our network call.
 
 7: If the status code is 200, which means good response then...
 
 8: We serialize the JSON response we receive from the network call.
    The response we get is in NSData.
 
    NOTE: Most of the time JSON is returned as a large Dictionary or array.
    BUT in the case that it isn't we can call NSJSONReadingAllowFragments,
    which specifies that the parser should allow top-level objects that are not
    an instance of NSArray or NSDictionary.
 
 9: We are looking for the venues returned. We turned the JSON object into a dictionary.
    The dictionary has a key called "venues", which is an array of venues. So we make an array called
    venuesArray and call 'valueForKeyPath' on our dictionary to get the array of venues. In this example
    we say @"response.venues" because venues is location inside of the key 'response'.
 
 10: We loop through the venuesArray and parse the venues into something we can use.
 
 11: RESUME:
        ***MAKE SURE THIS IS DONE*** otherwise your network call won't happen.
        This means to start the network call. So we call it on our NSURLSessionDataTask.

 */

#import "NSURLSessionTVC.h"

@interface NSURLSessionTVC ()

@property(nonatomic, strong) NSMutableArray *barArray;

@end

@implementation NSURLSessionTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _barArray = [[NSMutableArray alloc]init];
    [self foursquareDetroitBars];

}

-(void)foursquareDetroitBars{
    
    //1
    NSString *categoryID = @"4bf58dd8d48988d116941735";
    NSString *foursquareAPIClientID = @"CFITOPDZUHBDVUIVCHOC5XUCVZ5OVHE40RIIUZA2AZXLSMUZ";
    NSString *foursquareAPIClientSecret = @"E4EG5TBFZDLGUSJDEOGMFRNAQCDU03W3JQDBD0T31G5HH35J";
    NSString *URLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=42.3314,-83.0457&categoryId=%@&v=20130815&client_id=%@&client_secret=%@", categoryID, foursquareAPIClientID, foursquareAPIClientSecret];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //2
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //3
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 4
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    //5
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //6
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        //7
        if (httpResponse.statusCode == 200) {
            
            NSError *JSONError;
            
            //8
            NSMutableDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error: &JSONError];
            
            //9
            NSArray *venuesArray = [JSONDict valueForKeyPath:@"response.venues"];
            
            //10
            for (NSDictionary *venue in venuesArray) {
                
                [_barArray addObject:[venue valueForKey:@"name"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });

        } else {
            NSLog(@"ERROR: %@", error);
        }
        
        //11
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
