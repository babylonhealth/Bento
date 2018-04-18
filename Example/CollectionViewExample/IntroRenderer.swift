import Bento

final class IntroRenderer {
    
    private let content: [IntroContent]
    init(_ content: [IntroContent]) {
        self.content = content
    }

    enum SectionId {
        case intro
    }

    enum RowId {
        case introPage
        case loading
    }

    func render(state: IntroViewModel.State) -> Box<SectionId, RowId> {
        switch state {
        case .loading:
            return renderLoading()
        case let .loaded(content):
            return render(page: content)
        }
    }

    private func renderLoading() -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.intro,
                        header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
            |---+ RowId.loading <> LoadingIndicatorComponent(isLoading: true)
    }

    private func render(page: IntroContent) -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.intro,
                        header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
            |---+ RowId.introPage <> IconTitleDetailsComponent(icon: page.image,
                                                               title: page.title,
                                                               subtitle: page.body)
    }
}
