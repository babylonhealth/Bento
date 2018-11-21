import XCTest
import UIKit
@testable import StyleSheets

class StyleSheetTests: XCTestCase {

    func test_view_style_sheet() {
        let view = UIView()
        let styleSheet = ViewStyleSheet()
        testStyleSheet(styleSheet, in: view, exemptions: ["cornerRadius", "masksToBounds", "borderColor", "borderWidth"])
    }

    func test_label_style_sheet() {
        let label = UILabel()
        let styleSheet = LabelStyleSheet(font: .boldSystemFont(ofSize: 11.0))
        testStyleSheet(styleSheet, in: label, exemptions: ["cornerRadius", "masksToBounds", "borderColor", "borderWidth"])
    }

    func test_button_style_sheet() {
        let button = UIButton()
        let styleSheet = ButtonStyleSheet()
        testStyleSheet(styleSheet,
                       in: button,
                       exemptions: ["textFont", "masksToBounds", "cornerRadius", "titleColors", "images", "backgroundImages", "numberOfLines", "borderColor", "borderWidth", "textAlignment", "lineBreakMode"])
    }

    func test_imageview_style_sheet() {
        let imageView = UIImageView()
        let styleSheet = ImageViewStyleSheet(contentMode: .scaleAspectFill)
        testStyleSheet(styleSheet, in: imageView, exemptions: ["cornerRadius", "masksToBounds", "size", "borderColor", "borderWidth"])
    }

    func test_stackview_style_sheet() {
        let stackView = UIStackView()
        let styleSheet = StackViewStyleSheet(axis: .vertical, spacing: 8, distribution: .fill, alignment: .fill)
        testStyleSheet(styleSheet, in: stackView, exemptions: ["cornerRadius", "masksToBounds", "borderColor", "borderWidth"])
    }

    func testStyleSheet<S: StyleSheetProtocol, Element>(
        _ styleSheet: S,
        in element: Element,
        exemptions: Set<String> = []
    ) where S.Element == Element, Element: NSObject {

        let observer = PropertyObserver()

        let properties = Set(extract(propertiesFrom: Mirror(reflecting: styleSheet)))

        properties.forEach { property in
            element.addObserver(observer, forKeyPath: property, options: .new, context: nil)
        }

        styleSheet.apply(to: element)

        let observedKeys = Set(observer.changes.map { $0.key })

        let symmetricDifference = observedKeys
            .symmetricDifference(properties)
            .subtracting(exemptions)

        XCTAssert(
            symmetricDifference.isEmpty,
            "\(type(of: styleSheet)) didn't use all the properties to configure \(type(of: element)) - properties missing: \(symmetricDifference)"
        )
    }
}

private func extract(propertiesFrom mirror: Mirror?) -> [String] {
    guard let mirror = mirror else { return [] }
    return mirror.children.compactMap { $0.label } + extract(propertiesFrom: mirror.superclassMirror)
}

private final class PropertyObserver: NSObject {

    public var changes: [String : Any] = [:]

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard
            let keyPath = keyPath,
            let value = change?[.newKey]
            else { fatalError() }

        changes[keyPath] = value
    }
}
