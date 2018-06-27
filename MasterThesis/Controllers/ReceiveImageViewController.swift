//
//  ReceiveImageViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 28.03.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit

class ReceiveImageViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    private var newImageView = UIImageView()
    private var image: UIImage! {
        didSet {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
    }
    private var networkLayer = NetworkLayer()
    private var results = [(data: Double, red: Double, green: Double, blue: Double)]() {
        didSet {
            resultsTableView.reloadData()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = false
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        receiveButton.layer.cornerRadius = receiveButton.frame.size.height/2
    }

    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = UIScreen.main.bounds
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        let imageView = sender.view as? UIImageView
        newImageView.image = imageView?.image
        newImageView.clipsToBounds = true
        newImageView.contentMode = .scaleAspectFit
        newImageView.backgroundColor = .black
        newImageView.frame = UIScreen.main.bounds
        scrollView.addSubview(newImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        scrollView.addGestureRecognizer(tap)
        
        self.view.addSubview(scrollView)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func receiveImageFromProcessing(_ sender: UIButton) {
        popLoadingView()
        networkLayer.downloadImage { (responseCode, imageData) -> (Void) in
            self.removeLoadingView()
            switch responseCode {
            case 200:
                self.popsTheAlert(title: "OK", message: "Odbiór zdjęcia zakończony prawidłowo")
                self.image = UIImage(data: imageData, scale: 1)
                self.imageView.isUserInteractionEnabled = true
            default:
                self.popsTheAlert(title: "Błąd", message: "Błąd w trakcie pobierania zdjęcia. Prosimy spróbować ponownie.")
            }
        }
        
        networkLayer.getData { (data) -> (Void) in
            for element in data {
                self.results.append((element.data, element.red, element.green, element.blue))
            }
        }
    }
    
    @objc func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    // Mark: - Delegates
    // scroll view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
        if let resultCell = cell as? ResultCell {
            let element = results[indexPath.row]
            resultCell.data = "Pałeczka nr \(indexPath.row+1) - \(element.data)"
            resultCell.color = UIColor(red: CGFloat(element.red/255), green: CGFloat(element.green/255), blue: CGFloat(element.blue/255), alpha: 1)
        }
        return cell
    }
}

class ResultCell: UITableViewCell {
    @IBOutlet weak var resultLabel: UILabel!
    var data: String? {
        didSet {
            updateData()
        }
    }
    var color: UIColor? {
        didSet {
            updateColor()
        }
    }
    
    private func updateData() {
        // reset any existing informations
        resultLabel.text = ""
        resultLabel.textAlignment = .center
        
        resultLabel.text = data
    }
    
    private func updateColor() {
        // reset any existing informations
        resultLabel.textColor = UIColor.black
        
        resultLabel.textColor = color
    }
}
