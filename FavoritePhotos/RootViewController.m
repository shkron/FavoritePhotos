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

//    self.favoritesArray = [NSMutableArray array];
    //load favoritesArray in order to add favorite pictures there
    [self load];

//    self.collectionViewArray = [NSMutableArray array];


}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [self load];
//    [self.collectionView reloadData];
//}

//MARK: delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewArray.count;
}


- (CustomCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                               forIndexPath:indexPath];
    Photos *photosObj = self.collectionViewArray[indexPath.item];
    cell.imageView.image = nil;


    //checking if the picture has been already downloaded and re-using it along with the favorite START icon.
    if (self.favoritesArray.count == 0)
    {

        [photosObj retrieveImageDataWithComplete:^(NSData *data, NSError *error)
         {
             if (error)
             {
                 [self networkAlertWindow:error.localizedDescription];
             }
             else
             {

                 cell.imageView.image = [UIImage imageWithData:data];
                 [self.collectionViewArray[indexPath.item] setImgData:data];
             }
         }];

    }
    else
    {
        for (int i = 0; i < self.favoritesArray.count; i++)
        {
            NSString *checkID = self.favoritesArray[i][@"imageID"];
            if ([photosObj.imageID isEqualToString:checkID])
            {

                cell.imageView.image = [UIImage imageWithData:self.favoritesArray[i][@"imgData"]];
//                cell.favImgLabel.text = self.favoritesArray[i][@"favImgStar"];
                [self.collectionViewArray[indexPath.item] setImgData:self.favoritesArray[i][@"imgData"]];
                [self.collectionViewArray[indexPath.item] setFavImgStar:self.favoritesArray[i][@"favImgStar"]];
                break;
            }
            else if (self.favoritesArray.count == i+1)
            {
                [photosObj retrieveImageDataWithComplete:^(NSData *data, NSError *error)
                 {
                     if (error)
                     {
                         [self networkAlertWindow:error.localizedDescription];
                     }
                     else
                     {
                         cell.imageView.image = [UIImage imageWithData:data];
                         [self.collectionViewArray[indexPath.item] setImgData:data];
                     }
                 }];

            }
        }
    }

////MAIN BLOCK TO DOWNLOAD THE DATA FOR CELLS
//    [photosObj retrieveImageDataWithComplete:^(NSData *data, NSError *error)
//    {
//        if (error)
//        {
//            [self networkAlertWindow:error.localizedDescription];
//        }
//        else
//        {
//
//            cell.imageView.image = [UIImage imageWithData:data];
//            [self.collectionViewArray[indexPath.item] setImgData:data];
//        }
//    }];
//

    cell.favImgLabel.text = [self.collectionViewArray[indexPath.item] favImgStar];

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

//-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    Photos *photo = self.collectionViewArray[indexPath.item];
//    photo.favImgStar = @"";
//
//    NSArray *indexPathArray = @[indexPath];
//
//    [self.collectionView reloadItemsAtIndexPaths:indexPathArray];
//    [self remove:photo];
//
//}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

NSArray *indexPathArray = @[indexPath];

    Photos *photo = self.collectionViewArray[indexPath.item];

    if (![photo.favImgStar isEqualToString:@"⭐️"])
    {
    photo.favImgStar = @"⭐️";



    [self.collectionView reloadItemsAtIndexPaths:indexPathArray];

    [self save:photo];
    }
    else
    {
        photo.favImgStar = @"";
        [self remove:photo];
        [self.collectionView reloadItemsAtIndexPaths:indexPathArray];

    }
    
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
    if (self.favoritesArray.count == 0)
    {
        NSDictionary *photoDict = @{@"imageID" : photoObj.imageID, @"imgData" : photoObj.imgData, @"favImgStar" : photoObj.favImgStar}; // add more key:value from Photos if needed

        [self.favoritesArray addObject:photoDict];
        NSLog(@"Added first object to array. Arry count %lu", (unsigned long)self.favoritesArray.count);
        NSURL *plistURL = [[self documentsDirectory] URLByAppendingPathComponent:@"fovorites.plist"];
        [self.favoritesArray writeToURL:plistURL atomically:YES];
    }
    else
    {
//        NSString *imgID = photoObj.imageID;
        for (int i = 0; i < self.favoritesArray.count; i++)
        {
            NSString *checkID = self.favoritesArray[i][@"imageID"];
            if ([photoObj.imageID isEqualToString:checkID])
            {
                break;
            }
            else if (self.favoritesArray.count == i+1)
            {
                NSDictionary *photoDict = @{@"imageID" : photoObj.imageID, @"imgData" : photoObj.imgData, @"favImgStar" : photoObj.favImgStar}; // add more key:value from Photos if needed

                [self.favoritesArray addObject:photoDict];

                NSLog(@"Added object. Array count = %lu", (unsigned long)self.favoritesArray.count);
                NSURL *plistURL = [[self documentsDirectory] URLByAppendingPathComponent:@"fovorites.plist"];
                [self.favoritesArray writeToURL:plistURL atomically:YES];
            }

        //    [userDefaults setObject:[NSDate date] forKey:kNSUserDefaultsLastSavedKey];
        //    [userDefaults synchronize];
        }
    }
}

-(void)load
{
    NSURL *plistURL = [[self documentsDirectory] URLByAppendingPathComponent:@"fovorites.plist"];
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
//        NSDictionary *photoDict = self.favoritesArray[i];
        if ([self.favoritesArray[i][@"imageID"] isEqualToString:photoObj.imageID])
        {
            [self.favoritesArray removeObjectAtIndex:i];
            NSLog(@"Removed object. Array count = %lu", (unsigned long)self.favoritesArray.count);
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
