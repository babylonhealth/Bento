import Bento

final class IntroRenderer {
    enum SectionId {
        case intro
    }

    enum RowId: Hashable {
        case introPage(IntroContent)
        case loading
    }

    func render(state: IntroViewModel.State) -> Box<SectionId, RowId> {
        switch state {
        case .loading:
            return renderLoading()
        case let .loaded(pages):
            return render(pages: pages)
        }
    }

    private func renderLoading() -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.intro)
            |---+ RowId.loading <> LoadingIndicatorComponent(isLoading: true)
    }

    private func render(pages: [IntroContent]) -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.intro)
            |---* pages.map { page in
                RowId.introPage(page) <> IntroComponent(title: page.title,
                                                        body: page.body,
                                                        image: page.image)
            }
    }
}
