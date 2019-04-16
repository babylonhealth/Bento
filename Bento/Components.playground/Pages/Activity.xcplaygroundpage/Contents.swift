import UIKit
import Bento
import BentoPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let component = Component.Activity(isLoading: true)

PlaygroundPage.current.liveView = renderInTableView(component: component)
