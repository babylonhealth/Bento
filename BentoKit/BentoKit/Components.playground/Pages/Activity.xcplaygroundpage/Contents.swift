import UIKit
import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let component = Component.Activity(isLoading: true)

PlaygroundPage.current.liveView = renderInTableView(component: component)
