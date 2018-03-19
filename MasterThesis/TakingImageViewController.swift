import UIKit
import AVFoundation

class TakingImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    private var newImageView = UIImageView()
    private var image: UIImage! {
        didSet {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
    }
    
    private var pickerDataSource: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    private var pickedRow = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = false
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Wyloguj", style: .plain, target: self, action: #selector(TakingImageViewController.backButtonPressed(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        NetworkLayer().getAlgorithms { (algorithms) -> (Void) in
            self.pickerDataSource = algorithms
        }
    }
    
    @IBAction func takingPhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        picker.allowsEditing = true
        picker.showsCameraControls = true
        picker.cameraFlashMode = .auto
        
        present(picker, animated: true, completion: nil)
        // popracować nad dostępem
        /*if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authdorized {
                
            } else {
                noAccessAlert()
            }
        } else {
            noCameraAlert()
        }*/
    }
    
    @IBAction func pickingPhotoFromLibrary(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
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
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func sendImageToProcess(_ sender: UIButton) {
        if let image = image {
            popLoadingView()
            let imageData = UIImageJPEGRepresentation(image, 1.0)!
            let parameters = ["selectedAlgorithm": pickerDataSource[pickedRow]];
            NetworkLayer().uploadImage(imageData: imageData, parameters: parameters, getResponseCode: { (responseCode) -> (Void) in
                switch responseCode {
                case 200:
                    self.removeLoadingView()
                    self.popsTheAlert(title: "OK", message: "Zdjęcie wysłane prawidłowo")
                default:
                    self.removeLoadingView()
                    self.popsTheAlert(title: "Błąd", message: "Błąd w trakcie przetwarzania danych. Prosimy spróbować ponownie.")
                }
            })
        } else {
            popsTheAlert(title: "Błąd", message: "Nie wybrano zdjęcia.")
        }
    }
    
    @IBAction func receiveImageFromProcessing(_ sender: UIButton) {
        popLoadingView()
        NetworkLayer().downloadImage { (responseCode, imageData) -> (Void) in
            self.removeLoadingView()
            switch responseCode {
            case 200:
                self.popsTheAlert(title: "OK", message: "Odbiór zdjęcia zakończony prawidłowo")
                self.image = UIImage(data: imageData, scale: 1)
            default:
                self.popsTheAlert(title: "Błąd", message: "Błąd w trakcie pobierania zdjęcia. Prosimy spróbować ponownie.")
            }
        }
    }
    
    @objc func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    private func noCameraAlert() {
        let alert = UIAlertController(title: "Brak aparatu", message: "Urządzenie którego używasz nie posiada aparatu lub jest on zepsuty", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func noAccessAlert() {
        let alert = UIAlertController(title: "Brak dostępu", message: "Kamera jest wymagana do zrobienia zdjęcia próbki", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil)
        let givePermissionAction = UIAlertAction(title: "Daj dostęp", style: .default, handler: { (alert) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(givePermissionAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func backButtonPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Uwaga!", message: "Czy na pewno chcesz się wylogować?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
        let logOffAction = UIAlertAction(title: "Tak", style: .default) { (alert) in
            DatabaseLayer().deleteCookies()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancelAction)
        alert.addAction(logOffAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Mark: - Delegates
    // picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.isUserInteractionEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // scroll view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedRow = row
    }
}
