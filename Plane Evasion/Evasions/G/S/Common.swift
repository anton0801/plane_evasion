import Foundation
import SpriteKit

extension SKTexture {
    static func roundedRect(size: CGSize, radius: CGFloat, color: UIColor) -> SKTexture {
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        // Create a UIImage with rounded corners
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create SKTexture from UIImage
        return SKTexture(image: image!)
    }
    
    static func roundedStrokeRect(size: CGSize, radius: CGFloat, strokeColor: UIColor, lineWidth: CGFloat) -> SKTexture {
       let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
       let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
       
       // Create a UIImage with rounded stroke
       UIGraphicsBeginImageContextWithOptions(size, false, 0)
       
       // Stroke color
       strokeColor.setStroke()
       path.lineWidth = lineWidth
       path.stroke()
       
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       // Create SKTexture from UIImage
       return SKTexture(image: image!)
   }

}
