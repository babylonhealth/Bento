import Bento

final class FoodListRenderer {
    enum SectionId {
        case intro
    }

    enum RowId: Hashable {
        case introPage(FoodItem)
        case loading
    }

    func render(state: FoodListViewModel.State) -> Box<SectionId, RowId> {
        switch state {
        case .loading:
            return renderLoading()
        case let .loaded(pages):
            return render(pages: pages)
        }
    }

    private func renderLoading() -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.intro,
                        header: IconTextComponent(image: nil, title: "Loading"))
            |---+ Node(id: RowId.loading, component: LoadingIndicatorComponent(isLoading: true))
    }

    private func render(pages: [FoodItem]) -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>(
            sections: [Section(
                id: SectionId.intro,
                header: IconTextComponent(image: nil, title: "Header"),
                footer: IconTextComponent(image: nil, title: "Footer"),
                items: pages.map { page in
                    return Node(id: RowId.introPage(page), component:
                        FoodItemComponent(title: page.title,
                                       body: page.body,
                                       image: page.image
                        )
                    )
                }
            )]
        )
    }
}
