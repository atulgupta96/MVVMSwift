//
//  PostListingController.swift
//  ProjectMVVM
//
//  Created by Atul Gupta on 03/01/23.
//

import UIKit

class PostListingController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Private Variables
    private var refreshControl: UIRefreshControl?
    private let viewModel = PostListingViewModel()
    private var page = 0
    private var posts = [Post]()
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "All Posts"
        
        getPosts()
    }
    
    //MARK: Private Methods
    private func setupPullToRefresh() {
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(swipeToRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
            
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @objc func swipeToRefresh() {
        page = 0
        getPosts()
    }
}

//MARK: API Calls
extension PostListingController {
    private func getPosts() {
        guard page != -1 else {return}
        
        if !(refreshControl?.isRefreshing ?? false) && page == 0 {
            activityIndicator.startAnimating()
        }
        
        viewModel(.getPosts(page))
        
        viewModel.getPostsCallback = { [weak self] response in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if self.page == 0 {
                    self.posts = response.posts
                    
                } else {
                    self.posts.append(contentsOf: response.posts)
                }
                
                if response.posts.count == 0 || self.posts.count >= response.total {
                    self.page = -1
                } else {
                    self.page += 1
                }
                
                self.tableView.reloadData()
                self.setupPullToRefresh()
            }
        }
        
        viewModel.errorCallback = { [weak self] message in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                debugPrint(message)
            }
        }
    }
}

//MARK: UITableViewDelegate & UITableViewDataSource
extension PostListingController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let post = posts[indexPath.row]
        
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        
        return cell
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // UITableView only moves in one direction, y axis
        let currentOffset = tableView.contentOffset.y
        let maximumOffset = tableView.contentSize.height - tableView.frame.size.height
        
        if maximumOffset - currentOffset <= 10 {
            self.getPosts()
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1

        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            
            if page != -1 {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                tableView.tableFooterView = spinner
                
            } else {
                tableView.tableFooterView?.removeFromSuperview()
            }
        }
    }
}
