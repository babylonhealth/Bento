import UIKit
import FormsKit

final class BookAppointmentViewController: UIViewController {
    enum SectionId {
        case user
        case consultantDate
        case audioVideo
        case symptoms
        case book
    }
    enum RowId {
        case user
        case consultant
        case date
        case audioVideo
        case symptoms
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let form = Form<SectionId, RowId>.empty
            |-+ Section(id: SectionId.user,
                        header: EmptySpaceComponent(height: 24, color: .clear))
            |--+ Node(id: RowId.user,
                      component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName: "chuck_norris_walker"),
                                                           title: "Chuck Norris",
                                                           subtitle: ""))
            |-+ Section(id: SectionId.consultantDate,
                        header: EmptySpaceComponent(height: 24, color: .clear))
            |--+ Node(id: RowId.consultant,
                      component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName: "consultantIcon"),
                                                           title: "Consultant type",
                                                           subtitle: "GP"))
            |--+ Node(id: RowId.date,
                      component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName: "timeIcon"),
                                                           title: "Date & time",
                                                           subtitle: "Today 21:30"))
            |-+ Section(id: SectionId.audioVideo,
                        header: EmptySpaceComponent(height: 24, color: .clear))
            |--+ Node(id: RowId.audioVideo,
                      component: SegmetControlComponent(firstIcon: #imageLiteral(resourceName: "video"),
                                                        secondIcon: #imageLiteral(resourceName: "phone"),
                                                        onSegmentSelected: { print("Selected index", $0) }))
            |-+ Section(id: SectionId.audioVideo,
                        header: EmptySpaceComponent(height: 24, color: .clear))
            |-+ Section(id: SectionId.audioVideo,
                        header: ButtonComponent(buttonTitle: "Book",
                                                onBattonPressed: { print("Book an Appointment") }))
//
        form.render(in: tableView)
    }
    
    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

}
