@testable import Bento
import Nimble
import XCTest
import FlexibleDiff

typealias TestStore = AdapterStore<Int, Int>

class AdapterStoreTests: XCTestCase {
    let defaultBoundSize = CGSize(width: 10000, height: 10000)

    func test_should_report_non_existing_supplement_even_if_caching_is_disabled() {
        var store = TestStore()

        store.update(
            with: [
                Section(id: 0, items: [Node(id: 0, component: TestComponent(size: .zero))])
            ],
            knownSupplements: []
        )

        expect(store.cachesSizeInformation) == false
        expect(store.size(for: .header, inSection: 0)) == .doesNotExist
    }

    func test_should_report_caching_disabled_if_supplement_exists() {
        var store = TestStore()

        store.update(
            with: [
                Section(id: 0, header: TestComponent(size: .zero))
            ],
            knownSupplements: []
        )

        expect(store.cachesSizeInformation) == false
        expect(store.size(for: .header, inSection: 0)) == .noCachedResult
    }

    func test_should_return_nil_for_item_size_if_caching_is_disabled() {
        var store = TestStore()

        store.update(
            with: [
                Section(id: 0, items: [Node(id: 0, component: TestComponent(size: .zero))])
            ],
            knownSupplements: []
        )

        expect(store.cachesSizeInformation) == false
        expect(store.size(forItemAt: [0, 0])).to(beNil())
    }

    func test_supplement_should_return_size_no_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(
            with: makeSingleSection(withJust: .header, value: 123),
            knownSupplements: [.header]
        )

        expect(store.size(for: .header, inSection: 0)) == .size(CGSize(width: 123, height: 123))

        store.update(
            with: makeSingleSection(withJust: .header, value: 456),
            knownSupplements: [.header]
        )

        // NOTE: Since there is no changeset, the store would simply wipe out all cached information, instead of trying
        //       to shuffle existing information to their up-to-date location.
        expect(store.size(for: .header, inSection: 0, allowEstimation: true)) == .noCachedResult
        expect(store.size(for: .header, inSection: 0)) == .size(CGSize(width: 456, height: 456))
    }

    func test_item_should_return_size_no_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(
            with: makeSingleSectionWithSingleItem(value: 123),
            knownSupplements: []
        )

        expect(store.size(forItemAt: [0, 0])) == CGSize(width: 123, height: 123)

        store.update(
            with: makeSingleSectionWithSingleItem(value: 456),
            knownSupplements: []
        )

        // NOTE: Since there is no changeset, the store would simply wipe out all cached information, instead of trying
        //       to shuffle existing information to their up-to-date location.
        expect(store.size(forItemAt: [0, 0], allowEstimation: true)).to(beNil())
        expect(store.size(forItemAt: [0, 0])) == CGSize(width: 456, height: 456)
    }

    func test_should_return_correct_size_after_deletion_no_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubA(), knownSupplements: [])
        assert(&store, matches: makeStubA())

        store.update(with: makeStubB(), knownSupplements: [])
        assertNoCachedSize(&store, useEstimation: true)
        assert(&store, matches: makeStubB())
    }

    func test_should_return_correct_size_after_insertion_no_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubB(), knownSupplements: [])
        assert(&store, matches: makeStubB())

        store.update(with: makeStubA(), knownSupplements: [])
        assertNoCachedSize(&store, useEstimation: true)
        assert(&store, matches: makeStubA())
    }

    func test_should_return_correct_size_after_deletion_has_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubA(), knownSupplements: [])
        assert(&store, matches: makeStubA())

        store.update(with: makeStubB(), knownSupplements: [], changeset: stubChangesetAToB())
        assert(&store, useEstimation: true, matches: makeStubBWithEstimatedSizesFromStubA())
        assert(&store, matches: makeStubB())
    }

    func test_should_return_correct_size_after_insertion_has_changeset() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubB(), knownSupplements: [])
        assert(&store, matches: makeStubB())

        store.update(with: makeStubA(), knownSupplements: [], changeset: stubChangesetBToA())
        assert(&store, useEstimation: true, matches: makeStubAWithEstimatedSizesFromStubB())
        assert(&store, matches: makeStubA())
    }

    func test_should_return_correct_size_after_sections_have_moved_scenario_1() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubC(), knownSupplements: [])
        assert(&store, matches: makeStubC())

        store.update(with: makeStubD(), knownSupplements: [], changeset: stubChangesetCAndD())
        assert(&store, useEstimation: true, matches: makeStubDWithEstimatedSizesFromStubC())
        assert(&store, matches: makeStubD())
    }

    func test_should_return_correct_size_after_sections_have_moved_scenario_2() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(with: makeStubD(), knownSupplements: [])
        assert(&store, matches: makeStubD())

        store.update(with: makeStubC(), knownSupplements: [], changeset: stubChangesetCAndD())
        assert(&store, useEstimation: true, matches: makeStubCWithEstimatedSizesFromStubD())
        assert(&store, matches: makeStubC())
    }

    func test_boundSizeChange_should_invalidate_sizes() {
        var store = TestStore()
        store.cachesSizeInformation = true
        store.boundSize = defaultBoundSize

        store.update(
            with: makeSingleSectionWithSingleItem(value: 5000),
            knownSupplements: []
        )

        expect(store.size(forItemAt: [0, 0])) == CGSize(width: 5000, height: 5000)

        store.boundSize = CGSize(width: 1, height: 1)
        expect(store.size(forItemAt: [0, 0], allowEstimation: true)) == CGSize(width: 5000, height: 5000)
        expect(store.size(forItemAt: [0, 0])) == CGSize(width: 1, height: 5000)
    }

    private func makeSingleSectionWithSingleItem(value: CGFloat) -> [Section<Int, Int>] {
        return [
            Section(
                id: 0,
                items: [
                    Node(id: 0, component:
                        TestComponent(size: CGSize(width: value, height: value)
                    ))
                ]
            )
        ]
    }

    private func makeSingleSection(withJust supplement: Supplement, value: CGFloat) -> [Section<Int, Int>] {
        return [
            Section(id: 0)
                .adding(
                    supplement,
                    TestComponent(size: CGSize(width: value, height: value))
            )
        ]
    }

    private func makeStubA() -> [Section<Int, Int>] {
        return [
            Section(id: 0, items: [
                Node(id: 0, component:
                    TestComponent(size: CGSize(width: 123, height: 123)
                )),
                Node(id: 1, component:
                    TestComponent(size: CGSize(width: 456, height: 456)
                ))
            ]),
            Section(id: 1, items: [
                Node(id: 2, component:
                    TestComponent(size: CGSize(width: 789, height: 789)
                )),
                Node(id: 3, component:
                    TestComponent(size: CGSize(width: 901, height: 901)
                )),
                Node(id: 4, component:
                    TestComponent(size: CGSize(width: 234, height: 234)
                ))
            ])
        ]
    }

    private func makeStubB() -> [Section<Int, Int>] {
        return [
            Section(id: 1, items: [
                Node(id: 3, component:
                    TestComponent(size: CGSize(width: 432, height: 432)
                ))
            ])
        ]
    }

    private func makeStubAWithEstimatedSizesFromStubB() -> [Section<Int, Int>] {
        return [
            Section(id: 0, items: [
                Node(id: 0, component: NoSizePlaceholder()),
                Node(id: 1, component: NoSizePlaceholder())
            ]),
            Section(id: 1, items: [
                Node(id: 2, component: NoSizePlaceholder()),
                Node(id: 3, component:
                    TestComponent(size: CGSize(width: 432, height: 432))
                ),
                Node(id: 4, component: NoSizePlaceholder())
            ])
        ]
    }

    private func makeStubBWithEstimatedSizesFromStubA() -> [Section<Int, Int>] {
        return [
            Section(id: 1, items: [
                Node(id: 3, component:
                    TestComponent(size: CGSize(width: 901, height: 901))
                )
            ])
        ]
    }

    private func stubChangesetAToB() -> SectionedChangeset {
        return SectionedChangeset(
            sections: Changeset(removals: [0], mutations: [1]),
            mutatedSections: [
                SectionedChangeset.MutatedSection(
                    source: 1,
                    destination: 0,
                    changeset: Changeset(
                        removals: [0, 2],
                        moves: [Changeset.Move(source: 1, destination: 0, isMutated: true)]
                    )
                )
            ]
        )
    }

    private func stubChangesetBToA() -> SectionedChangeset {
        return SectionedChangeset(
            sections: Changeset(inserts: [0], mutations: [1]),
            mutatedSections: [
                SectionedChangeset.MutatedSection(
                    source: 0,
                    destination: 1,
                    changeset: Changeset(
                        inserts: [0, 2],
                        moves: [Changeset.Move(source: 0, destination: 1, isMutated: true)]
                    )
                )
            ]
        )
    }

    private func makeStubC() -> [Section<Int, Int>] {
        return [
            Section(id: 0, items: [
                Node(id: 0, component:
                    TestComponent(size: CGSize(width: 123, height: 123)
                ))
            ]),
            Section(id: 50, items: [
                Node(id: 50, component:
                    TestComponent(size: CGSize(width: 456, height: 456)
                ))
            ]),
            Section(id: 100, items: [
                Node(id: 100, component:
                    TestComponent(size: CGSize(width: 789, height: 789)
                ))
            ])
        ]
    }

    private func makeStubD() -> [Section<Int, Int>] {
        return [
            Section(id: 100, items: [
                Node(id: 100, component:
                    TestComponent(size: CGSize(width: 789, height: 789)
                ))
            ]),
            Section(id: 50, items: [
                Node(id: 50, component:
                    TestComponent(size: CGSize(width: 1000, height: 1000)
                ))
            ]),
            Section(id: 0, items: [
                Node(id: 0, component:
                    TestComponent(size: CGSize(width: 123, height: 123)
                ))
            ])
        ]
    }

    private func stubChangesetCAndD() -> SectionedChangeset {
        return SectionedChangeset(
            sections: Changeset(
                mutations: [1],
                moves: [
                    Changeset.Move(source: 0, destination: 2, isMutated: false),
                    Changeset.Move(source: 2, destination: 0, isMutated: false),
                ]
            ),
            mutatedSections: [
                SectionedChangeset.MutatedSection(
                    source: 1,
                    destination: 1,
                    changeset: Changeset(mutations: [0])
                )
            ]
        )
    }

    private func makeStubCWithEstimatedSizesFromStubD() -> [Section<Int, Int>] {
        return [
            Section(id: 0, items: [
                Node(id: 0, component:
                    TestComponent(size: CGSize(width: 123, height: 123)
                ))
            ]),
            Section(id: 50, items: [
                Node(id: 50, component:
                    TestComponent(size: CGSize(width: 1000, height: 1000)
                ))
            ]),
            Section(id: 100, items: [
                Node(id: 100, component:
                    TestComponent(size: CGSize(width: 789, height: 789)
                ))
            ])
        ]
    }


    private func makeStubDWithEstimatedSizesFromStubC() -> [Section<Int, Int>] {
        return [
            Section(id: 100, items: [
                Node(id: 100, component:
                    TestComponent(size: CGSize(width: 789, height: 789)
                ))
            ]),
            Section(id: 50, items: [
                Node(id: 50, component:
                    TestComponent(size: CGSize(width: 456, height: 456)
                ))
            ]),
            Section(id: 0, items: [
                Node(id: 0, component:
                    TestComponent(size: CGSize(width: 123, height: 123)
                ))
            ])
        ]
    }
}


private func assertNoCachedSize(
    _ pointer: UnsafeMutablePointer<TestStore>,
    useEstimation: Bool = false,
    file: FileString = #file,
    line: UInt = #line
) {
    for sectionOffset in pointer.pointee.sections.indices {
        for itemOffset in pointer.pointee.sections[sectionOffset].items.indices {
            expect(
                pointer.pointee.size(forItemAt: [sectionOffset, itemOffset], allowEstimation: useEstimation),
                file: file,
                line: line
            ).to(beNil())
        }
    }
}

private func assert(
    _ pointer: UnsafeMutablePointer<TestStore>,
    useEstimation: Bool = false,
    matches stub: [Section<Int, Int>],
    file: FileString = #file,
    line: UInt = #line
) {
    for (sectionOffset, section) in stub.enumerated() {
        for (itemOffset, item) in section.items.enumerated() {
            expect(
                pointer.pointee.size(forItemAt: [sectionOffset, itemOffset], allowEstimation: useEstimation),
                file: file,
                line: line
            ).to(
                (item.component(as: TestComponent.self)?.size).map(equal) ?? beNil()
            )
        }
    }
}

struct NoSizePlaceholder: Renderable {
    func render(in view: UIView) {}
}

struct TestComponent: Renderable {
    let size: CGSize

    init(size: CGSize) {
        self.size = size
    }

    func render(in view: TestComponent.View) {
        view.size = size
    }

    class View: UIView {
        var size: CGSize = .zero

        override func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            return CGSize(
                width: min(size.width, horizontalFittingPriority == .required ? targetSize.width : .greatestFiniteMagnitude),
                height: min(size.height, verticalFittingPriority == .required ? targetSize.height : .greatestFiniteMagnitude)
            )
        }
    }
}
