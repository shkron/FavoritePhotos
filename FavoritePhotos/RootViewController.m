//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Alex on 11/6/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "RootViewController.h"
#import "CustomCollectionViewCell.h"
#import "Photos.h"

@interface RootViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *collectionViewArray;
@property NSMutableArray *favoritesArray;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //load favoritesArray in order to add favorite pictures there
    [self load];

//    self.collectionViewArray = [NSMutableArray array];


}

//MARK: delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewArray.count;
}


- (CustomCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                               forIndexPath:indexPath];
    Photos *photosObj = self.collectionViewArray[indexPath.row];
    cell.imageView.image = nil;

    [photosObj retrieveImageDataWithComplete:^(NSData *data, NSError *error)
    {
        if (error)
        {
            [self networkAlertWindow:error.localizedDescription];
        }
        else
        {
            cell.imageView.image = [UIImage imageWithData:data];
            [self.collectionViewArray[indexPath.row] setImgData:data];
        }
    }];

    //when that imageData method finishes, we take the data that it gives us
    // and do this
    //
    //UIImage* image = [UIImage imageWithData:returnedData];
    //cell.imageView.image = image;


    return cell;
}



- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.searchTextField])
    {
        NSString *charactersString = @" `~!@#$%^&*()-_=+[]\{}|;':\",./<>?";
        for (int i=0; i<charactersString.length; i++)
        {
            char c = [charactersString characterAtIndex:i];
            NSString *charString = [NSString stringWithFormat:@"%c", c];
            if ([string isEqual:charString])
            {
                return NO;
            }
        }
    }
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photos *photo = self.collectionViewArray[indexPath.item];
    [self remove:photo];

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photos *photo = self.collectionViewArray[indexPath.item];
    [self save:photo];
    
}



//MARK: JSON Data pull method

//MAKE A Photos CLASS METHOD OUT OF IT

-(void)dataWithURLString:(NSString *)urlString
{

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           if (connectionError)
                                           {
                                               [self networkAlertWindow:connectionError.localizedDescription];
                                           }
                                           else
                                           {
                                               NSDictionary *rawJSONDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                               NSDictionary *metaData = [rawJSONDict objectForKey:@"meta"];
                                               NSNumber *warningCode = [metaData objectForKey:@"code"];
                                               NSString *errorMessage = [metaData objectForKey:@"error_message"];

                                               if ([warningCode isEqual:@200])
                                               {
                                                   NSArray *rawJSONArray = [rawJSONDict objectForKey:@"data"];
                                                   if (rawJSONArray.count != 0)
                                                   {
                                                       for (NSDictionary *dict in rawJSONArray)
                                                       {
                                                           Photos *photoObj = [[Photos alloc] initWithJSONDictionary:dict];
                                                           [self.collectionViewArray addObject:photoObj];
                                                       }
                                                       [self.collectionView reloadData];
                                                   }else
                                                   {[self networkAlertWindow:@"No pictures to display for this tag"];}
                                               }
                                               else
                                               {
                                                   [self networkAlertWindow:errorMessage];
                                               }

                                           }

                                       }];
}



//MARK: custom methods
- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender
{

    if (![self.searchTextField.text isEqualToString:@""])
    {
        self.collectionViewArray = [NSMutableArray array];

        NSString *searchString = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=26245f17601d4c4b96cc640a23892064", self.searchTextField.text];

        [self dataWithURLString:searchString];
        [self.searchTextField resignFirstResponder];
    }

}


-(void)save:(Photos *)photoObj
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    //checking the ID for the selected photo for the duplicate in documentsDirectory
    for (Photos *photoFav in self.favoritesArray)
    {
        if (![photoFav.imageID isEqualToString:photoObj.imageID])
        {
            [self.favoritesArray addObject:photoObj];
            NSLog(@"%lu", (unsigned long)self.favoritesArray.count);
            NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"fovorites.plist"];
            [self.favoritesArray writeToURL:plistURL atomically:YES];
        }
    //    [userDefaults setObject:[NSDate date] forKey:kNSUserDefaultsLastSavedKey];
    //    [userDefaults synchronize];
    }
}

-(void)load
{
    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"favorites.plist"];
    self.favoritesArray = [NSMutableArray arrayWithContentsOfURL:plistURL];
    if (self.favoritesArray == nil)
    {
        self.favoritesArray = [NSMutableArray array];
    }
}

-(void)remove:(Photos *)photoObj
{
    for (int i=0; i < self.favoritesArray.count; i++)
    {
        Photos *photo = self.favoritesArray[i];
        if ([photo.imageID isEqualToString:photoObj.imageID])
        {
            [self.favoritesArray removeObjectAtIndex:i];
            NSLog(@"%lu", (unsigned long)self.favoritesArray.count);
            NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"fovorites.plist"];
            [self.favoritesArray writeToURL:plistURL atomically:YES];
        }
        //    [userDefaults setObject:[NSDate date] forKey:kNSUserDefaultsLastSavedKey];
        //    [userDefaults synchronize];
    }


}

-(NSURL *)documentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}




-(void)networkAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ahtung!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"😭 Mkay..." style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
