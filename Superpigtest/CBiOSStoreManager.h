/*
 *  CBiOSStoreManager.h
 *  CloudBox Cross-Platform Framework Project
 *
 *  Created by Cloud on 2012/10/30.
 *  Copyright 2011 Cloud Hsu. All rights reserved.
 *
 */

#import <UIKit/UIKit.h> 
#import <StoreKit/StoreKit.h>

@interface CBiOSStoreManager : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    int buyType;
    NSString* _buyProductIDTag;
}

+ (CBiOSStoreManager*) sharedInstance;

- (void) buy:(NSString*)buyProductIDTag;
- (bool) CanMakePay;
- (void) initialStore;
- (void) releaseStore;
- (void) requestProductData:(NSString*)buyProductIDTag;
- (void) provideContent:(NSString *)product;
- (void) recordTransaction:(NSString *)product;

- (void) requestProUpgradeProductData:(NSString*)buyProductIDTag;
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) purchasedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
- (void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (BOOL) verifyReceipt:(NSData*)receipt;
@end