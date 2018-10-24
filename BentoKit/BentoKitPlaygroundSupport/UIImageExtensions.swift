import UIKit

extension UIImage {
     static func image(fromColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        return UIGraphicsImageRenderer(size: size)
            .image { imageContext in
                imageContext.cgContext.setFillColor(color.cgColor)
                imageContext.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
