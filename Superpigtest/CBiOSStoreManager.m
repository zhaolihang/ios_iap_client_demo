/*
 *  CBiOSStoreManager.mm
 *  CloudBox Cross-Platform Framework Project
 *
 *  Created by Cloud on 2012/10/30.
 *  Copyright 2011 Cloud Hsu. All rights reserved.
 *
 */

#import "CBiOSStoreManager.h"

@implementation CBiOSStoreManager

static CBiOSStoreManager* _sharedInstance = nil;

+(CBiOSStoreManager*)sharedInstance
{
	@synchronized([CBiOSStoreManager class])
	{
		if (!_sharedInstance)
			[[self alloc] init];
        
		return _sharedInstance;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([CBiOSStoreManager class])
	{
		NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.\n");
		_sharedInstance = [super alloc];
		return _sharedInstance;
	}
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
	}
	return self;
}

-(void)initialStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}
-(void)releaseStore
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)buy:(NSString*)buyProductIDTag
{
    [self requestProductData:buyProductIDTag];
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}   

-(void)requestProductData:(NSString*)buyProductIDTag
{
    NSLog(@"---------Request product information------------\n");
    _buyProductIDTag = [buyProductIDTag retain];
    NSArray *product = [[NSArray alloc] initWithObjects:buyProductIDTag,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    [product release];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{   
    
    NSLog(@"-----------Getting product information--------------\n");
    NSArray *myProduct = response.products;
    NSLog(@"Product ID:%@\n",response.invalidProductIdentifiers);
    NSLog(@"Product count: %d\n", [myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"Detail product info\n");
        NSLog(@"SKProduct description: %@\n", [product description]);
        NSLog(@"Product localized title: %@\n" , product.localizedTitle);
        NSLog(@"Product localized descitption: %@\n" , product.localizedDescription);
        NSLog(@"Product price: %@\n" , product.price);
        NSLog(@"Product identifier: %@\n" , product.productIdentifier);
    }
    SKPayment *payment = nil;
    //payment  = [SKPayment paymentWithProductIdentifier:_buyItemIDTag];
    //[_buyItemIDTag autorelease]
//    switch (buyType) {
//        case IAP0p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP0p99];    //支付$0.99
//            break;
//        case IAP1p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP1p99];    //支付$1.99
//            break;
//        case IAP4p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP4p99];    //支付$9.99
//            break;
//        case IAP9p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP9p99];    //支付$19.99
//            break;
//        case IAP24p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP24p99];    //支付$29.99
//            break;
//        default:
//            break;
//    }
    payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
    NSLog(@"---------Request payment------------\n");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [request autorelease];    
    
}
- (void)requestProUpgradeProductData:(NSString*)buyProductIDTag
{
    NSLog(@"------Request to upgrade product data---------\n");
    NSSet *productIdentifiers = [NSSet setWithObject:buyProductIDTag];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"-------Show fail message----------\n");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
    [alerView release];
}   

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------Request finished--------------\n");
    
}   

-(void) purchasedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Purchased Transaction----\n");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}    

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"-----Payment result--------\n");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                NSLog(@"-----Transaction purchased--------\n");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Congratulation"
                                                              message:@"Transaction suceed!"
                                                              delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];   
                
                [alerView show];
                [alerView release];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                NSLog(@"-----Transaction Failed--------\n");
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"Failed"
                                                               message:@"Sorry, your transcation failed, try again."
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];   
                
                [alerView2 show];
                [alerView2 release];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                NSLog(@"----- Already buy this product--------\n");
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"-----Transcation puchasing--------\n");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction   
{
    NSLog(@"-----completeTransaction--------\n");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;

    [self verifyReceipt:transaction];
    
    NSString * str = @" product＝商品购买结果";
    NSLog([str  stringByAppendingString:product ]);
    
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }   
    
    // Remove the transaction from the payment queue.   
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];   
    
}   

-(void)recordTransaction:(NSString *)product
{
    NSLog(@"-----Record transcation--------\n");
    // Todo: Maybe you want to save transaction result into plist.
    NSString * str = @" 商品购买结果";
    NSLog([str  stringByAppendingString:product ]);
}   

-(void)provideContent:(NSString *)product
{
    NSLog(@"-----Download product content--------\n");
    NSString * str = @" 商品购买结果";
    NSLog([str  stringByAppendingString:product ]);
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Failed\n");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{   
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Restore transaction--------\n");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"-------Payment Queue----\n");
}

#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@\n",  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{   
    
}   

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}   

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"test\n");
}   

-(void)dealloc
{
    [super dealloc];
}



- (BOOL) verifyReceipt:(SKPaymentTransaction *)transaction
{
    
    
    [self commitSeversSucceeWithTransaction:transaction];
    
    return NO;
}

- (void)commitSeversSucceeWithTransaction:(SKPaymentTransaction *)transaction

{
    
    //系统IOS7.0以上获取支付验证凭证的方式应该改变，切验证返回的数据结构也不一样了。
    
    
    NSString *aString = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    
    NSString * str = @" receipt的内容是：";
    NSLog([str  stringByAppendingString:aString ]);
    /*
     如果成功购买成功了在控制台 会打印下面的内容：
     receipt的内容是：{
     "signature" = "AgYRgjfkKKUXHFAlujndez0ErompChoVeRDa16xC2mPXXM2/Sy9ZwRXFVVyOY0YgmCZwKGVqUEH/Qj7A01QAttAcVjrosIS2zPVUfw5XKOgiII71kSui8NNzSt5oQ3F30+vt5h1EDfct6nSR+uXuFsUyqXtEnETAbdzwZD73Y+VnAAADVzCCA1MwggI7oAMCAQICCBup4+PAhm/LMA0GCSqGSIb3DQEBBQUAMH8xCzAJBgNVBAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEzMDEGA1UEAwwqQXBwbGUgaVR1bmVzIFN0b3JlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE0MDYwNzAwMDIyMVoXDTE2MDUxODE4MzEzMFowZDEjMCEGA1UEAwwaUHVyY2hhc2VSZWNlaXB0Q2VydGlmaWNhdGUxGzAZBgNVBAsMEkFwcGxlIGlUdW5lcyBTdG9yZTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMmTEuLgjimLwRJxy1oEf0esUNDVEIe6wDsnnal14hNBt1v195X6n93YO7gi3orPSux9D554SkMp+Sayg84lTc362UtmYLpWnb34nqyGx9KBVTy5OGV4ljE1OwC+oTnRM+QLRCmeNxMbPZhS47T+eZtDEhVB9usk3+JM2Cogfwo7AgMBAAGjcjBwMB0GA1UdDgQWBBSJaEeNuq9Df6ZfN68Fe+I2u22ssDAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFDYd6OKdgtIBGLUyaw7XQwuRWEM6MA4GA1UdDwEB/wQEAwIHgDAQBgoqhkiG92NkBgUBBAIFADANBgkqhkiG9w0BAQUFAAOCAQEAeaJV2U51rxfcqAAe5C2/fEW8KUl4iO4lMuta7N6XzP1pZIz1NkkCtIIweyNj5URYHK+HjRKSU9RLguNl0nkfxqObiMckwRudKSq69NInrZyCD66R4K77nb9lMTABSSYlsKt8oNtlhgR/1kjSSRQcHktsDcSiQGKMdkSlp4AyXf7vnHPBe4yCwYV2PpSN04kboiJ3pBlxsGwV/ZlL26M2ueYHKYCuXhdqFwxVgm52h3oeJOOt/vY4EcQq7eqHm6m03Z9b7PRzYM2KGXHDmOMk7vDpeMVlLDPSGYz1+U3sDxJzebSpbaJmT7imzUKfggEY7xxf4czfH0yj5wNzSGTOvQ==";
     "purchase-info" = "ewoJIm9yaWdpbmFsLXB1cmNoYXNlLWRhdGUtcHN0IiA9ICIyMDE1LTA1LTIxIDIzOjQyOjAyIEFtZXJpY2EvTG9zX0FuZ2VsZXMiOwoJInVuaXF1ZS1pZGVudGlmaWVyIiA9ICI1MzNjMDBiNWE5Zjc4YWIyYWVmNDQ4NDlmZmQ2ZDIzYTNhZTVhMzlmIjsKCSJvcmlnaW5hbC10cmFuc2FjdGlvbi1pZCIgPSAiMTAwMDAwMDE1NjI3OTM0MCI7CgkiYnZycyIgPSAiMS4wIjsKCSJ0cmFuc2FjdGlvbi1pZCIgPSAiMTAwMDAwMDE1NjI3OTM0MCI7CgkicXVhbnRpdHkiID0gIjEiOwoJIm9yaWdpbmFsLXB1cmNoYXNlLWRhdGUtbXMiID0gIjE0MzIyNzY5MjI1MTgiOwoJInVuaXF1ZS12ZW5kb3ItaWRlbnRpZmllciIgPSAiODk5OTFBREUtRjNCRC00QkQyLUEyOEEtRkU3MzU3MzE0NEEyIjsKCSJwcm9kdWN0LWlkIiA9ICJpZF96dWFuc2hpXzFfIjsKCSJpdGVtLWlkIiA9ICI5OTU5MjEzMzkiOwoJImJpZCIgPSAiY29tLndpbmdvZmdvZC53aW5nb2Znb2QiOwoJInB1cmNoYXNlLWRhdGUtbXMiID0gIjE0MzIyNzY5MjI1MTgiOwoJInB1cmNoYXNlLWRhdGUiID0gIjIwMTUtMDUtMjIgMDY6NDI6MDIgRXRjL0dNVCI7CgkicHVyY2hhc2UtZGF0ZS1wc3QiID0gIjIwMTUtMDUtMjEgMjM6NDI6MDIgQW1lcmljYS9Mb3NfQW5nZWxlcyI7Cgkib3JpZ2luYWwtcHVyY2hhc2UtZGF0ZSIgPSAiMjAxNS0wNS0yMiAwNjo0MjowMiBFdGMvR01UIjsKfQ==";
     "environment" = "Sandbox";
     "pod" = "100";
     "signing-status" = "0";
     }
     
     
     
     */

    
}






@end