//
//  AlertViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 19..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation

class ESTAlertView: UIViewController {
    
    // Alert로 한글 뜻 보여준다. (UIViewController를 받아온다.)
    func alertwithCancle(fromController controller: UIViewController, setTitle: String, setNotice: String)
    {
        let alertController = UIAlertController(title: setTitle, message: setNotice, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        alertController.addAction(alertOK)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
    func alertTwoButton()
    {
        // 알림창 인스턴스를 생성한다.
        let alertController = UIAlertController(title: "Two Button", message: "Here is message!", preferredStyle: .alert)
        
        let alertDestructive = UIAlertAction(title: "Destructive", style: .default) { (action) in
            // 취소 클릭 후 실행될 코드
            print("tapped Default button")
        }
        
        let alertCancle = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // 클릭 시 실행될 코드
            print("tapped Cancel button")
        }
        
        alertController.addAction(alertDestructive)
        alertController.addAction(alertCancle)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertWithMultiAction()
    {
        // 알림창 인스턴스를 생성한다.
        let alertController = UIAlertController(title: "Multi Action", message: "액션 선택이 여러가지", preferredStyle: .alert)
        
        // UIAlertActionStyle에는 Default, Cancel, Destructive가 있다.
        // .Default: Apply the default style to the action's button.
        // .Cancel: Apply a style that indicates the action cancels the operation and leaves things unchanged.
        // .Destructive: Apply a style that indicates the action might change or delete data.
        let alertAction1 = UIAlertAction(title: "Default button", style: .default) { (action) in
            print("Default button tapped!")
        }
        
        let alertAction2 = UIAlertAction(title: "Cancel button", style: .cancel) { (action) in
            print("Cancel button tapped!")
        }
        
        let alertAction3 = UIAlertAction(title: "Destructive button", style: .destructive) { (action) in
            print("Destructive button tapped!")
        }
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        alertController.addAction(alertAction3)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func alertWithInputField()
    {
        var inputTextField: UITextField?
        
        // 알림창 인스턴스를 생성한다.
        // UIAlertControllerStykle에는 ActionSheet와 Alert가 있다.
        let alertController = UIAlertController(title: "Input Your Name", message: "이름을 입력 하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        let alertOk = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // OK 버튼이 눌렸을때 처리할 코드
            print("input text is \(inputTextField?.text)")
            
        })
        
        let alertCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            // Cancel 버튼이 눌렸을때 처리할 코드
        })
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        alertController.addTextField(configurationHandler: { (textFild: UITextField!) -> Void in
            textFild.placeholder = "Input your name..,"
            inputTextField = textFild
        })
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func alertActionSheet()
    {
        // 알림창 인스턴스 생성
        let alertController = UIAlertController(title: nil, message: "UIAlertControllerStyle.ActionSheet", preferredStyle: .actionSheet)
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            // Cancel일 클릭될때 실행되는 코드
            print("tapped cancel")
        })
        
        let alertNotice1 = UIAlertAction(title: "첫 번째 공지입니다.", style: .default, handler: { (action) -> Void in
            // 클릭되었을때 실행되는 코드
            print("fierst notice")
        })
        
        let alertNotice2 = UIAlertAction(title: "두 번째 공지입니다.", style: .default, handler: { (action) -> Void in
            // 클릭되었을 때 실행되는 코드
            print("second notice")
        })
        
        let alertNotice3 = UIAlertAction(title: "홈 페이지 이동", style: .default, handler: { (action) -> Void in
            // 클릭되었을 때 실행되는 코드
            print("go Home")
        })
        
        alertController.addAction(alertCancel)
        alertController.addAction(alertNotice1)
        alertController.addAction(alertNotice2)
        alertController.addAction(alertNotice3)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func alertLogin()
    {
        var loginTextField: UITextField?
        var passwordTextField: UITextField?
        
        // 알림창 인스턴스를 생성한다.
        let alertController = UIAlertController(title: "Login", message: "로그인 하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            
            print(loginTextField.text!, passwordTextField.text!)
        })
        
        let alertForget = UIAlertAction(title: "Forgot password", style: .destructive, handler: { (action) -> Void in
            // 클릭되었을때 실행되는 코드
            print("I forgot my password.")
        })
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            // 클릭되었을 때 실행되는 코드
            print("canceled login")
        })
        
        alertController.addTextField(configurationHandler: { (textField) in
            loginTextField = textField
            loginTextField?.placeholder = "User Id"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
                loginAction.isEnabled = textField.text != ""
            })
        })
        
        alertController.addTextField(configurationHandler: { (textField) in
            passwordTextField = textField
            passwordTextField?.placeholder = "Password"
            passwordTextField?.isSecureTextEntry = true
        })
        
        alertController.addAction(loginAction)
        alertController.addAction(alertForget)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func alertSignup()
    {
        var loginTextField: UITextField?
        var passwordTextField: UITextField?
        var passwordComfirmationTextField: UITextField?
        
        // 알림창 인스턴스를 생성한다.
        let alertController = UIAlertController(title: "Login", message: "로그인 하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        let loginAction = UIAlertAction(title: "Sign Up", style: .default, handler: { (action) -> Void in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            let passwordComfirmationTextField = alertController.textFields![2] as UITextField
            
            print(loginTextField.text!, passwordTextField.text!, passwordComfirmationTextField.text!)
        })
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            // 클릭되었을 때 실행되는 코드
            print("canceled login")
        })
        
        // Text Field 추가 (User ID)
        alertController.addTextField(configurationHandler: { (textField) in
            loginTextField = textField
            loginTextField?.placeholder = "Email"
            loginTextField?.keyboardType = .emailAddress
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
                loginAction.isEnabled = textField.text != ""
            })
        })
        
        // Text Field 추가 (password)
        alertController.addTextField(configurationHandler: { (textField) in
            passwordTextField = textField
            passwordTextField?.placeholder = "Password"
            passwordTextField?.isSecureTextEntry = true
        })
        
        // Text Field 추가 (password comfirmation)
        alertController.addTextField(configurationHandler: { (textField) in
            passwordComfirmationTextField = textField
            passwordComfirmationTextField?.placeholder = "Password Confirmation"
            passwordComfirmationTextField?.isSecureTextEntry = true
        })
        
        alertController.addAction(loginAction)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
