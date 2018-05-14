//
//  ReceiveImageViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 28.03.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit

class ReceiveImageViewController: UIViewController, UIScrollViewDelegate {

    private var newImageView = UIImageView()
    private var image: UIImage! {
        didSet {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
    }
    private var networkLayer = NetworkLayer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var receiveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = false
        
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
            //print(data)
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
}
