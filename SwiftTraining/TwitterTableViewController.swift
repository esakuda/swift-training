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

class TwitterTableViewController: UITableViewController {
    let tableViewModel = TwitterTableViewModel()
    private var _loadingHUD: MBProgressHUD!
    
    var imageViewSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadingHUD = MBProgressHUD.showHUDAddedTo(tableView, animated:true)
        tableView.registerNib(UINib(nibName: "TwitterCell", bundle: nil), forCellReuseIdentifier: "TwitterCell")
        tableViewModel.fetchTimeline.executing.producer.startWithNext { [unowned self] executing in
            if executing {
                self._loadingHUD.show(true)
            } else {
                self._loadingHUD.hide(true)
            }
        }
        tableViewModel.fetchTimeline.errors.observeNext { error in
            print("Error fetching tweets: \(error)")
        }
        tableViewModel.fetchTimeline.values.observeNext { [unowned self] _ in self.tableView.reloadData() }
        tableViewModel.fetchTimeline.apply(true).start()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tableViewModel.tweetsCount)
        return tableViewModel.tweetsCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("tweetsCount: \(tableViewModel.tweetsCount)")
        print(indexPath.row)
        if (indexPath.row == tableViewModel.tweetsCount - 1) {
            print("Asking for next page??")
            print(tableViewModel.fetchTimeline)
            tableViewModel.fetchTimeline.apply(false).start()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell") as! TwitterCell
        let tweet = tableViewModel[indexPath.row]
        cell.bindViewModel(tweet)
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        tableViewModel.fetchTimeline.apply(true).start {
            switch $0 {
            case .Next(_): break
            default: self.refreshControl?.endRefreshing()
            }
        }
    }

}