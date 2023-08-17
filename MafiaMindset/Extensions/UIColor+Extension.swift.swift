import UIKit

extension UIColor {
    class func random () -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0)
    }
    
    class func withLightAppearance(named: String) -> UIColor? {
        UIColor(named: named)?.resolvedColor(with: .init(userInterfaceStyle: .light))
    }
    
    convenience init(red: some BinaryInteger, green: some BinaryInteger, blue: some BinaryInteger) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: some BinaryInteger) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static var primary: UIColor? {
        return .init(named: "PrimaryColor")
    }
    
    var opaque: UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var rgb: Int32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int32 = (Int32)(red * 255) << 16 | (Int32)(green * 255) << 8 | (Int32)(blue * 255) << 0
        return rgb
    }
    
    func image(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { ctx in
            self.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    func normalize(to white: CGFloat) -> UIColor {
        var whiteColor: CGFloat = 0
        var alphaComponent: CGFloat = 0
        self.getWhite(&whiteColor, alpha: &alphaComponent)
        if whiteColor > white {
            let d = whiteColor - white
            return self - d
        }
        else {
            let d = white - whiteColor
            return self + d
        }
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
    
    static func -(lhs: UIColor, rhs: CGFloat) -> UIColor {
        let rgba = lhs.rgba
        return UIColor(red: max(0.0, rgba.red - rhs), green: max(0.0, rgba.green - rhs), blue: max(0.0, rgba.blue - rhs), alpha: rgba.alpha)
    }
    static func +(lhs: UIColor, rhs: CGFloat) -> UIColor {
        let rgba = lhs.rgba
        return UIColor(red: min(1.0, rgba.red + rhs), green: min(1.0, rgba.green + rhs), blue: min(1.0, rgba.blue + rhs), alpha: rgba.alpha)
    }
}
