import UIKit
import ReactiveSwift
import Result

public struct IntroContent {
    let image: UIImage
    let title: String
    let body: String
}

struct IntroViewModel {
    let content = [
        IntroContent(image: UIImage(named: "bentobox-hero")!,
                     title: "Bento Box Hero",
                     body: "with Teriyaki Pineapple and Speckled Rice"),
        IntroContent(image: UIImage(named: "jackfruit-stir-fry-hero")!,
                     title: "Jackfruit Shiitake Stir-fry",
                     body: "with Quinoa and Spinach"),
        IntroContent(image: UIImage(named: "peanut-tofu-hero")!,
                     title: "Crispy Peanut Tofu",
                     body: "with Zucchini and Carrot Noodles"),
        IntroContent(image: UIImage(named: "sushi-ritto-hero")!,
                     title: "Sushi-rito",
                     body: "with Roma Edamame Salad and Wasabi Aioli")
    ]
}
