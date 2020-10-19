//
//  LoginVC.swift
//  TimerToolProduct
//
//  Created by yongbin on 2019/11/4.
//  Copyright © 2019 sumemrthread. All rights reserved.
//

import UIKit
import AVFoundation

class LoginVC: UIViewController,UITextFieldDelegate {
    static let loginVC = LoginVC()
    
    @IBOutlet weak var t_uN: UITextField!
    @IBOutlet weak var t_pW: UITextField!
    @IBOutlet weak var t_cPW: UITextField!
    @IBOutlet weak var b_login: UIButton!
    @IBOutlet weak var b_tip: UIButton!
    @IBOutlet weak var bg_cPW: UIImageView!
    
    var host = ""
    var LoginOrReg = true
    let pw_usdf = "pw_usdf"
    let level_usdf = "level_usdf"
    let un_usdf = "un_usdf"
    let autoLogin_usdf = "autoLogin_usdf"
    let defaults = UserDefaults.standard
    var player: AVPlayer?
    var uuid = Keychain().UUIDString
    
    //------------------------------//
    var CID_usdf = "CID_usdf"
    var LID_usdf = "LID_usdf"
    var cheat_usdf = "cheat_usdf"
    //------------------------------//

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        t_cPW.isHidden = true
        bg_cPW.isHidden = true
        
        t_uN.text = defaults.string(forKey: un_usdf) ?? ""
        t_pW.text = defaults.string(forKey: pw_usdf) ?? ""
        t_pW.isSecureTextEntry = true
        t_cPW.isSecureTextEntry = true
        t_uN.keyboardType = .emailAddress
        t_uN.delegate = self
        t_cPW.delegate = self
        t_pW.delegate = self
        
        playBgv()
        
        print("id = \(uuid)")
    }
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //回车按钮
               t_uN.returnKeyType = .next
               //t_pW 的回车按钮的样式判断
               if t_cPW.isHidden == true {
                   t_pW.returnKeyType = .done
               }else{
                   t_pW.returnKeyType = .next
                   t_cPW.returnKeyType = .done
               }
        
        if(textField.returnKeyType == UIReturnKeyType.done)
    {
        textField.resignFirstResponder()//键盘收起
        return false
    }
    if(textField == t_uN)
    {
        t_pW.becomeFirstResponder()
       
    }else if(textField == t_pW && t_cPW.isHidden == false){
       
        t_cPW.becomeFirstResponder()
    }
    return true
    }
    
    
    
    func playBgv(){
        let path = Bundle.main.path(forResource: "moments", ofType: ".mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.seek(to: CMTime.zero)
        player!.play()
        self.player?.isMuted = false  // MARK: mute
      
    }
    
    @objc func playerItemDidReachEnd(){
        player!.seek(to: CMTime.zero)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let autoLogin = defaults.bool(forKey: autoLogin_usdf)
        if autoLogin {
            b_login_click(b_login)
        }
    }
    @IBAction func b_login_click(_ sender: UIButton) {
        var error:String!
        if t_uN.text!.count <= 0 {
            error = "请输入用户名\n Please enter username"
        }else if t_uN.text!.count > 20 {
            error = "用户名太长\n username too long"
        }else if t_pW.text!.count <= 0 {
            error = "请输入密码\n Please enter password"
        }
//        else if isPassWord(string: t_cPW.text!) == false {
//            error = "密码需至少包含一个字母，且长度在8-20之间\n Passwords should contain at least one letter and be between 8 and 20 in length"
//        }
        else{
            if !LoginOrReg {
                if t_cPW.text!.count <= 0 {
                    error = "请再输入密码\n Please enter password again"
                }else if t_pW.text! != t_cPW.text! {
                    error = "密码不一致\n The passwords entered are not the same"
                }else if isPassWord(string: t_cPW.text!) == false {
                error = "密码需至少包含一个字母，且长度在8-20之间\n Passwords should contain at least one letter and be between 8 and 20 in length"
                }
            }
        }
        if error != nil {
            alert(error)
        }else{
            b_login.isEnabled = false
            if LoginOrReg {
                POST(myurl: "\(host)/ONO/login.php",body: "userName=\(t_uN.text!)&passWord=\(t_pW.text!)&CID=\(uuid)")
            }else{
                POST(myurl: "\(host)/ONO/reg.php",body: "userName=\(t_uN.text!)&passWord=\(t_pW.text!)&c_passWord=\(t_cPW.text!)")
            }
        }
    }
    
    func isPassWord(string: String) -> Bool {
        let regex = "^(?=.*[a-z])[a-zA-Z0-9]{8,19}$"
        let allRegex : NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if allRegex.evaluate(with: string) {
            return true
        }
        return false
    }
    
    @IBAction func b_tip_click(_ sender: UIButton) {
        LoginOrReg = !LoginOrReg
        t_cPW.isHidden = LoginOrReg
        bg_cPW.isHidden = LoginOrReg
        if LoginOrReg {
            b_tip.setTitle("Doesn't have an account?", for: .normal)
            b_login.setTitle("Login", for: .normal)
        }else{
            b_tip.setTitle("Already have an account?", for: .normal)
            b_login.setTitle("Sign Up", for: .normal)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    func alert(_ text:String){
        
        let alertController = UIAlertController(title: "警告/Warning",
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的/OK", style: .default, handler: {
            action in
//            print("点击了确定")
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alert2(_ text:String){
            
            let alertController = UIAlertController(title: "警告/Warning",
                                                    message: text, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "明白/Understood", style: .default, handler: {
                action in
    //            print("点击了确定")
                let sb = UIStoryboard(name:"Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "enterSB") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = vc
                self.present(vc, animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    
    //发送POST请求NSURLSession
    func POST(myurl:String,body:String)
    {
        //1.创建会话对象
        let session: URLSession = URLSession.shared
        
        //2.根据会话对象创建task
        let url: NSURL = NSURL(string: myurl)!
        
        //3.创建可变的请求对象
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        //4.修改请求方法为POST
        request.httpMethod = "POST"
        
//        let body:String = "userName=&passWord="
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        //6.根据会话对象创建一个Task(发送请求）
        /*
         第一个参数：请求对象
         第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
         data：响应体信息（期望的数据）
         response：响应头信息，主要是对服务器端的描述
         error：错误信息，如果请求失败，则error有值
         */
        let dataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            //if(error == nil){
            //8.解析数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            //            var dict:NSDictionary? = nil
            //            do {
            //                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? NSDictionary
            //            } catch {
            //
            //            }
            DispatchQueue.main.async(execute: {
                
                self.b_login?.isEnabled = true
            })
            if(error != nil){
                DispatchQueue.main.async(execute: {
                    self.alert("出问题了，你再试一次 \n Something got wrong. Please try again\(error.debugDescription)")
                })
            }else if let mydata = data {
                print(String(bytes: mydata, encoding: .utf8)!)
                let resjson:NSDictionary = self.getDictionaryFromJSONData(jsonData: mydata)
                
                let res = (resjson["state"] as? String) ?? "0"
                let level = (resjson["level"] as? String) ?? "0"
            
                DispatchQueue.main.async(execute: {
                    let msg = (resjson["msg"] as? String) ?? ""
                    if res == "1" {
                        self.alert("注册成功，请登录！\n Registration successful, please login!")
                        self.b_tip_click(self.b_tip)
                        
                    }else if res == "2" {
                        
                        
//                        let LID = (resjson["LID"] as? String) ?? ""
//                        self.defaults.set(LID, forKey: self.LID_usdf)
                        let cheat = (resjson["cheat"] as? String) ?? ""
                        let cheatint = Int(cheat)!+1
                        let check = (resjson["check"] as? String) ?? ""
                        
                        
                        self.defaults.set(self.t_uN.text!, forKey: self.un_usdf)
                        self.defaults.set(self.t_pW.text!, forKey: self.pw_usdf)
                        self.defaults.set(true, forKey: self.autoLogin_usdf)
                        self.defaults.set(level,forKey: self.level_usdf)
                        self.player?.isMuted = true // MARK: MUTE
                        
//                        let sb = UIStoryboard(name:"Main", bundle: nil)
//
//                        let vc = sb.instantiateViewController(withIdentifier: "enterSB") as! UINavigationController
                        
                       
                        //MARK: 改根视图
                        //---------
//                        UIApplication.shared.keyWindow?.rootViewController = vc
//                        //---------
//                        self.present(vc, animated: true, completion: nil)
                        if check == "2.1" {
                            self.alert2("请勿将账号分享至他人使用，因违规导致账号密码窃失，陈永彬及TCC将不对此负责。 \n Please do not share your account with others. CHEN and TCC company will not be responsible for account being stolen due to sharing. \n cheat = \(cheatint)")
                        }else if check == "2.2" {
                            
                           let sb = UIStoryboard(name:"Main", bundle: nil)
                           let vc = sb.instantiateViewController(withIdentifier: "enterSB") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            self.present(vc, animated: true, completion: nil)
                            
                        }else if check == "2.3" {
                            self.alert2(msg)
                        }
                        
                        
                       
                    }else if res == "-1" {
                        self.alert(msg)
                    }
                    else if res == "3"{
                        //密码更改成功
                        self.defaults.set(false, forKey: self.autoLogin_usdf)
                        let sb = UIStoryboard(name:"Main",bundle: Bundle.main)
                        let vc = sb.instantiateViewController(withIdentifier: "loginSB")
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        self.present(vc, animated: true, completion: nil)
                    }
                })
                
                
            }
            
            //}
        }
        //5.执行任务
        dataTask.resume()
    }
    
    func getDictionaryFromJSONData(jsonData:Data) ->NSDictionary{
        
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    
    
    
    
    
//    func check () {
//
//        self.defaults.set(uuid, forKey: self.CID_usdf)
//        if self.defaults.string(forKey: self.LID_usdf) == nil {
//            POST(myurl: "\(host)/ONO/check.php",body: "userName=\(self.defaults.string(forKey: un_usdf) ?? "")&LID=\(uuid)")
//            //若传回来的LID为nil，则为初次登陆，将uuid传给服务器LID
//        } else if self.defaults.string(forKey: LID_usdf) != self.defaults.string(forKey: CID_usdf){
//
//           let cheat = self.defaults.integer(forKey: cheat_usdf) + 1
//            let warningMsg = "请勿将账号分享至他人使用，因违规导致账号密码窃失，陈永彬及TCC将不对此负责。\n Please do not share your account with others. CHEN and TCC company will not be responsible for account being stolen due to sharing. \n cheat=\(cheat)"
//            alert(warningMsg)
//            POST(myurl: "\(host)/ONO/check.php",body: "userName=\(self.defaults.string(forKey: un_usdf) ?? "")&cheat=\(cheat)&LID=\(uuid)")
//            //cheat+1之后传给服务器存起来，t然后将新的uuid传给服务器作为LID
//            //print("cheat = \(cheat)")
//
//
//        }
//    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
