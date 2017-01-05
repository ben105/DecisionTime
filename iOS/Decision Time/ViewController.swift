//
//  ViewController.swift
//  Decision Time
//
//  Created by Ben Rooke on 1/1/17.
//
//

import UIKit

class ScoreCard: UIView {
    let democratColor = UIColor(red: 221.0/255.0, green: 235.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    let democratBorderColor = UIColor(red: 15.0/255.0, green: 40.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    let republicanColor = UIColor(red: 221.0/255.0, green: 235.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    let republicanBorderColor = UIColor(red: 221.0/255.0, green: 235.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    
    private var score = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8.0
        self.set(score: 0)
    }
    
    func set(score: Int) {
        self.score = score
        if score < 0 {
            self.backgroundColor = democratColor
            self.layer.borderColor = democratBorderColor.cgColor
        } else {
            self.backgroundColor = republicanColor
            self.layer.borderColor = republicanBorderColor.cgColor
        }
    }
}

class TopicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    weak var delegate: ViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    @IBAction func moreButtonHandler() {
        print("pressed more!")
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.backgroundColor = UIColor.clear
        
        // Add this view controller as an observer to the download event.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadingTopics),
                                               name: Notification.Name(WillDownloadTopics),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveTopics(_:)),
                                               name: Notification.Name(DidDownloadTopics),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedToReceiveTopics),
                                               name: Notification.Name(FailedToDownloadTopics),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(WillDownloadTopics), object:nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(DidDownloadTopics), object:nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(FailedToDownloadTopics), object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! TopicTableViewCell
        cell.delegate = self
        cell.topicTitleLabel.text = topics[indexPath.row].title
        return cell
    }
    
    // MARK: Handling New Topics Download
    
    func loadingTopics() {
        DispatchQueue.main.async {
//            self.loadingLabel.text = "Loading topics from server."
//            self.loadingActivityIndicator.isHidden = false
//            self.loadingView.isHidden = false
//            self.tableView.isHidden = true
        }
    }
    
    func didReceiveTopics(_ notification: Notification) {
        guard let data = notification.userInfo?["data"] as? [Topic] else {
            return
        }
        topics = data
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func failedToReceiveTopics() {
        DispatchQueue.main.async {
//            self.loadingLabel.text = "Failed to load topics."
//            self.loadingActivityIndicator.isHidden = true
//            self.loadingView.isHidden = false
//            self.tableView.isHidden = true
        }
    }

}

