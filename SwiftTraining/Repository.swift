//
//  Respository.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/25/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Accounts
import Social

protocol TwitterRepository {
    func fetchHomeTimeLine (page: NSNumber) -> SignalProducer<[Tweet], NSError>
}

class TwitterRepositoryImplementation: TwitterRepository {
    private let accountStore: ACAccountStore
    private let twitterAccountType: ACAccountType
    
    init () {
        self.accountStore = ACAccountStore()
        self.twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
    }
    
    func getTwitterAccount() -> ACAccount! {
        let arrayOfAccounts =
        self.accountStore.accountsWithAccountType(self.twitterAccountType)
        
        if arrayOfAccounts.count > 0 {
            return arrayOfAccounts.last as! ACAccount
        } else {
            return nil
        }
    }
    
    func getAccount() -> SignalProducer<ACAccount, NSError> {
        return SignalProducer {
            sink, disposable in
            self.accountStore.requestAccessToAccountsWithType(self.twitterAccountType, options: nil,
                completion: {(success: Bool, error: NSError!) -> Void in
                    
                    if success {
                        let twitterAccount = self.getTwitterAccount()
                        sink.sendNext(twitterAccount)
                    } else {
                        sink.sendFailed(error)
                    }
            })
        }
    }
    
    func fetchHomeTimeLine(page: NSNumber) -> SignalProducer<[Tweet], NSError> {
        return SignalProducer {
            sink, disposable in
            self.getAccount().startWithNext({ twitterAccount in
                let requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                print ("PageViewModel \(page)")
                
                let parameters = ["screen_name" : twitterAccount.username,
                    "count" : "20"]
//                    ,
//                    "max_id" : ]
                
                let postRequest = SLRequest(forServiceType:
                    SLServiceTypeTwitter,
                    requestMethod: SLRequestMethod.GET,
                    URL: requestURL,
                    parameters: parameters)
                
                postRequest.account = twitterAccount
                
                postRequest.performRequestWithHandler( { ( responseData: NSData!,
                    urlResponse: NSHTTPURLResponse!,
                    error: NSError!) -> Void in
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(responseData,
                            options: NSJSONReadingOptions.MutableLeaves) as? [AnyObject] {
                            sink.sendNext(Tweet.initWithArray(jsonResult as! [NSDictionary]))
                        }
                    } catch let error as NSError {
                        sink.sendFailed(error)
                    }
                    
                })
            })
        }
    }

}
