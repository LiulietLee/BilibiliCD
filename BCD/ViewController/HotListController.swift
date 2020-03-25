//
//  HotListController.swift
//  BCD
//
//  Created by Liuliet.Lee on 28/9/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController
import ViewAnimator

class HotListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    private let listProvider = HotListProvider()
    private let assetProvider = AssetProvider()
    private var hotList = [(info: Info, image: UIImage?)]()
    private var isAnimatedOnce = false
    private var loadingView: LoadingView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .mikuGreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView = LoadingView(frame: view.bounds)
        loadingView.color = .mikuGreen
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        getList()
    }
    
    private func animateView() {
        let type = AnimationType.from(direction: .bottom, offset: ViewAnimatorConfig.offset)
        view.animateTableView(type: type)
        isAnimatedOnce = true
    }
    
    private func getList() {
        listProvider.getHotList { [weak self] hotList in
            guard let self = self, let list = hotList else { return }
            for item in list {
                self.hotList.append((info: item, image: #imageLiteral(resourceName: "placeholder_cover")))
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.loadingView.dismiss()
                if !self.isAnimatedOnce {
                    self.animateView()
                }
            }
            
            for item in list {
                self.assetProvider.getImage(fromUrlPath: item.imageURL) { [weak self] image in
                    guard let self = self,
                        let image = image,
                        let row = self.hotList.firstIndex(where: {$0.info.imageURL == item.imageURL})
                        else { return }
                    let img = image.uiImage.resized()
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.hotList[row].image = img
                        let indexPath = IndexPath(row: row, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HotListCell
        cell.authorLabel.text = hotList[indexPath.row].info.author
        cell.titleLabel.text = hotList[indexPath.row].info.title
        cell.coverView.image = hotList[indexPath.row].image
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "detail",
            let vc = segue.destination as? ImageViewController,
            let cell = sender as? HotListCell,
            let indexPath = tableView.indexPath(for: cell),
            hotList.count > indexPath.row {
            navigationController?.navigationBar.barTintColor = .bilibiliPink
            let cover = BilibiliCover(hotList[indexPath.row].info.stringID)
            vc.cover = cover
        }
    }

}
