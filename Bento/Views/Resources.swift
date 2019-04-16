import Foundation

final class Resources {
    /// If Bento is being used via Cocoapods then resources are
    /// in the Bento.bundle resource bundle
    /// Otherwise they are in the module bundle.
    static var bundle: Bundle = {
        let moduleBundle = Bundle(for: Resources.self)

        guard let url = moduleBundle.url(forResource: "Bento", withExtension: "bundle"),
            let resourceBundle = Bundle(url: url) else {
            return moduleBundle
        }

        return resourceBundle
    }()
}
