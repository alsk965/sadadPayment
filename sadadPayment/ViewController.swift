//
//  ViewController.swift
//  sadadPayment
//
//  Created by aly fawzy on 14/05/2022.
//

import UIKit
import SadadPaymentSDK

class ViewController: UIViewController, SelectCardReponseDelegate {
    
    
    let arrProduct:NSMutableArray = NSMutableArray()
    var strAccessToken:String = ""
    var token_url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupArrProd()
    }
    
    @IBAction func payNow(_ sender: Any) {
        GenerateToken()
    }
    
    func setupArrProd()  {
        let productDIC = NSMutableDictionary()
        productDIC.setValue("GUCCI Perfume", forKey: "itemname")
        productDIC.setValue(1, forKey: "quantity")
        productDIC.setValue(100, forKey: "amount")
        arrProduct.add(productDIC)
    }
    
    func GenerateToken() {
        DispatchQueue.main.async {
            AppUtils.startLoading(self.view)
        }
        let Url = String(format: token_url)
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = NSMutableDictionary()
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            defer{ DispatchQueue.main.async { AppUtils.stopLoading() } }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let TempResponse = json as! NSDictionary
                    if let strAccessTokenData = TempResponse.value(forKey: "data") as? NSDictionary{
                        if let strAccessToken = strAccessTokenData.value(forKey: "accessToken") as? String{
                            self.strAccessToken = strAccessToken
                            DispatchQueue.main.async {
                                let podBundle = Bundle(for: SelectPaymentMethodVC.self)
                                let storyboard = UIStoryboard(name: "mainStoryboard", bundle: podBundle)
                                if let vc = storyboard.instantiateViewController(withIdentifier: "SelectPaymentMethodVC") as? SelectPaymentMethodVC{
                                    vc.delegate = self
                                    vc.isSandbox = false
                                    vc.strAccessToken = strAccessToken
                                    vc.amount = Double(200)
                                    vc.arrProductDetails = self.arrProduct
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    navigationController.modalPresentationStyle = .overCurrentContext
                                    self.present(navigationController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } catch {
                    print("Something went wrong please try again later.\(error)")
                }
            }else{
                print("Something went wrong please try again later....")
            }
        }.resume()
    }
    
    
  
    
    func ResponseData(DataDIC: NSMutableDictionary) {
        DispatchQueue.main.async {
            print("message ::  \(DataDIC.value(forKey: "message") as! String)")
            print("statusCode ::  \(DataDIC.value(forKey: "statusCode") as! Int)")
        }
    }
}

