//
//  TwitterTableViewController.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import MBProgressHUD
import AlamofireImage

final class TwitterTableViewController: UITableViewController {
    
    let tableViewModel = TwitterTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "TwitterCell", bundle: nil), forCellReuseIdentifier: "TwitterCell")
        tableViewModel.fetchTimeline.executing.producer.startWithNext { [unowned self] executing in
            if executing {
                MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            } else {
                MBProgressHUD.hideAllHUDsForView(self.tableView, animated: true)
            }
        }
        tableViewModel.fetchTimelineNextPage.executing.signal.observeNext { [unowned self] executing in
            if executing {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                activityIndicator.startAnimating()
                self.tableView.tableFooterView = activityIndicator
            } else {
                self.tableView.tableFooterView = nil
            }
        }
        tableViewModel.fetchTimeline.errors.observeNext { error in
            print("Error fetching tweets: \(error)")
        }
        tableViewModel.tweets.signal.observeNext { [unowned self] _ in self.tableView.reloadData() }
        
        reloadTweets.start()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.tweetsCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == tableViewModel.tweetsCount - 1) {
            tableViewModel.fetchTimelineNextPage.apply("").start()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell") as! TwitterCell
        let tweet = tableViewModel[indexPath.row]
        cell.bindViewModel(tweet)
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        reloadTweets.start {
            switch $0 {
            case .Next(_): break
            default: self.refreshControl?.endRefreshing()
            }
        }
    }

}

private extension TwitterTableViewController {
    
    var reloadTweets: SignalProducer<[TweetViewModel], ActionError<NSError>> {
        return tableViewModel.fetchTimeline.apply("")
    }
    
}