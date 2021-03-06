//
//  IssueViewController.swift
//  DocFinder
//
//  Created by Russell Ladd on 1/17/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

import UIKit

class IssueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Initialization
    
    init(issue: PFObject) {
        
        self.issue = issue
        
        super.init(nibName: "IssueViewController", bundle: nil)
        
        // Navigation item
        
        navigationItem.title = issue["phoneNumber"] as? String
        
        // Fetch
        
        fetchMessages()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Model
    
    let issue: PFObject
    
    var messages: [PFObject]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    func fetchMessages() {
        
        let query = PFQuery(className: "Message")
        query.whereKey("issue", equalTo: issue)
        query.orderByDescending("date")
        query.includeKey("doctor")
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            if let objects = objects as? [PFObject] {
                self.messages = objects
            }
        }
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(Cell.DoctorMessage.nib, forCellReuseIdentifier: Cell.DoctorMessage.rawValue)
        tableView.registerNib(Cell.PatientMessage.nib, forCellReuseIdentifier: Cell.PatientMessage.rawValue)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Table view
    
    @IBOutlet weak var tableView: UITableView!
    
    enum Cell: String {
        
        case DoctorMessage = "DoctorMessageCell"
        case PatientMessage = "PatientMessageCell"
        
        var nib: UINib {
            return UINib(nibName: rawValue, bundle: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = messages![indexPath.row]
        
        let cell: MessageCell = {
            
            if let doctor = message["doctor"] as? PFObject {
                let cell = tableView.dequeueReusableCellWithIdentifier(Cell.DoctorMessage.rawValue, forIndexPath: indexPath) as MessageCell
                cell.senderLabel.text = doctor["name"] as? String
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Cell.PatientMessage.rawValue, forIndexPath: indexPath) as MessageCell
                cell.senderLabel.text = "Patient"
                return cell
            }
        }()
        
        cell.dateLabel.text = MessageDateFormatter.localizedStringFromDate(message["date"] as NSDate)
        cell.messageLabel.text = message["text"] as? String
        
        return cell
    }
}
