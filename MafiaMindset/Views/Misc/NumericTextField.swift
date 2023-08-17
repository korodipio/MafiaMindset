import UIKit

class NumericTextField: UITextField, UITextFieldDelegate {

    override var isEnabled: Bool {
        didSet {
            updateTextColor()
        }
    }
    
    var activeTextColor: UIColor = .link {
        didSet {
            updateTextColor()
        }
    }
    var inactiveTextColor: UIColor? {
        didSet {
            updateTextColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    private func updateTextColor() {
        textColor = isEnabled ? activeTextColor : (inactiveTextColor ?? activeTextColor)
    }
}
