import Foundation

enum MockResearchData {
    private static func date(_ year: Int, _ month: Int = 1) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) ?? .now
    }

    static let researches: [Research] = [
        Research(
            id: "strength-pms", pmid: "38010001", doi: nil,
            originalTitle: "Strength training and premenstrual symptoms",
            displayTitle: "Regular strength training may ease PMS symptoms",
            shortSummary: "A 12-week study found fewer mood swings and less bloating in women who strength trained 2–3 times per week.",
            keyFindings: ["Participants reported fewer disruptive premenstrual symptoms.", "Consistent moderate exercise produced the strongest association."],
            whyItMatters: "A practical movement routine may be a low-risk way to support wellbeing throughout the menstrual cycle.",
            limitations: "The intervention was short and relied partly on self-reported symptoms.",
            topicIds: ["hormones", "cycle-health"], authors: [ResearchAuthor(name: "A. Rivera", organization: "JAMA Network Open")],
            journalName: "JAMA Network Open", publicationDate: date(2023, 8),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=exercise+premenstrual+syndrome",
            studyType: .clinicalTrial, participantsCount: 182, evidenceQuality: .high, savesCount: 1200, isVisible: true
        ),
        Research(
            id: "mindfulness-cycle", pmid: "36620002", doi: nil,
            originalTitle: "Mindfulness and anxiety across the menstrual cycle",
            displayTitle: "Mindfulness may reduce anxiety during the menstrual cycle",
            shortSummary: "Women who practiced 10 minutes of daily mindfulness had lower anxiety, especially in the luteal phase.",
            keyFindings: ["Daily mindfulness was associated with lower reported anxiety.", "The largest change appeared during the luteal phase."],
            whyItMatters: "A short mindfulness practice is accessible and may help people manage cyclical changes in mood.",
            limitations: "The study was observational and cannot establish direct causation.",
            topicIds: ["mental-health", "cycle-health"], authors: [ResearchAuthor(name: "M. Chen", organization: "BMC Women’s Health")],
            journalName: "BMC Women’s Health", publicationDate: date(2022, 11),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=mindfulness+menstrual+anxiety",
            studyType: .observational, participantsCount: 356, evidenceQuality: .moderate, savesCount: 856, isVisible: true
        ),
        Research(
            id: "stress-cycles", pmid: "39030003", doi: nil,
            originalTitle: "Perceived stress and menstrual cycle length",
            displayTitle: "Shorter cycles may be linked to higher stress levels",
            shortSummary: "A large observational study found that women with higher perceived stress were more likely to have shorter menstrual cycles.",
            keyFindings: ["Higher stress scores correlated with shorter cycle length.", "The relationship remained after accounting for age and sleep."],
            whyItMatters: "Understanding stress as part of cycle health can help people spot patterns and seek support earlier.",
            limitations: "Stress and cycle data were self-reported.",
            topicIds: ["cycle-health", "mental-health"], authors: [ResearchAuthor(name: "L. Patel", organization: "Nature Communications")],
            journalName: "Nature Communications", publicationDate: date(2024, 2),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=stress+menstrual+cycle+length",
            studyType: .observational, participantsCount: 2180, evidenceQuality: .high, savesCount: 2100, isVisible: true
        ),
        Research(
            id: "magnesium-cramps", pmid: "37940004", doi: nil,
            originalTitle: "Magnesium supplementation for dysmenorrhea",
            displayTitle: "Magnesium may reduce menstrual cramps",
            shortSummary: "A meta-analysis found that magnesium supplementation was associated with significantly less pain during menstruation compared with placebo.",
            keyFindings: ["Across 12 randomized controlled trials involving 1,076 women, magnesium users reported lower pain scores.", "Participants were less likely to need pain medication during their period."],
            whyItMatters: "Menstrual cramps can interfere with daily life. Magnesium could be a simple, low-risk option to discuss with a clinician.",
            limitations: "Supplement dose and trial duration varied across the included studies.",
            topicIds: ["cycle-health", "nutrition"], authors: [ResearchAuthor(name: "S. Morgan", organization: "Frontiers in Nutrition")],
            journalName: "Frontiers in Nutrition", publicationDate: date(2023, 5),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=magnesium+dysmenorrhea+meta-analysis",
            studyType: .metaAnalysis, participantsCount: 1076, evidenceQuality: .moderate, savesCount: 2418, isVisible: true
        ),
        Research(
            id: "fiber-hormones", pmid: "39150005", doi: nil,
            originalTitle: "Dietary fiber and estrogen metabolism",
            displayTitle: "A higher fiber diet may support hormone balance",
            shortSummary: "Researchers found an association between varied fiber-rich diets and markers of healthy estrogen metabolism.",
            keyFindings: ["Higher dietary fiber was linked with more stable metabolic markers.", "Whole-food fiber sources showed the clearest association."],
            whyItMatters: "Everyday food choices may support long-term hormonal and digestive health.",
            limitations: "Diet was measured through participant recall questionnaires.",
            topicIds: ["nutrition", "hormones"], authors: [ResearchAuthor(name: "K. Young", organization: "Nutrients")],
            journalName: "Nutrients", publicationDate: date(2023, 9),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=dietary+fiber+estrogen+metabolism",
            studyType: .systematicReview, participantsCount: 940, evidenceQuality: .moderate, savesCount: 974, isVisible: true
        ),
        Research(
            id: "sleep-hormones", pmid: "39260006", doi: nil,
            originalTitle: "Sleep quality and hormonal health in women",
            displayTitle: "Better sleep may support hormonal health",
            shortSummary: "Regular sleep timing was associated with healthier hormonal markers and improved daily wellbeing.",
            keyFindings: ["Irregular sleep correlated with changes in hormonal markers.", "Regular sleep patterns were linked with improved wellbeing."],
            whyItMatters: "Sleep is a modifiable part of health that is often overlooked in conversations about hormones.",
            limitations: "The study found an association and did not prove causation.",
            topicIds: ["sleep", "hormones"], authors: [ResearchAuthor(name: "J. Smith", organization: "Journal of Women’s Health")],
            journalName: "Journal of Women’s Health", publicationDate: date(2024, 6),
            sourceURL: "https://pubmed.ncbi.nlm.nih.gov/?term=sleep+hormonal+health+women",
            studyType: .observational, participantsCount: 420, evidenceQuality: .emerging, savesCount: 632, isVisible: true
        )
    ]

    static let topics: [Topic] = [
        Topic(id: "my-feed", name: "My Feed", iconName: nil, order: 0, isActive: true, description: "Research selected around your interests."),
        Topic(id: "cycle-health", name: "Cycle health", iconName: nil, order: 1, isActive: true, description: "Research to help you understand and support your menstrual health at every stage."),
        Topic(id: "hormones", name: "Hormones", iconName: nil, order: 2, isActive: true, description: "Evidence about hormones, symptoms and everyday wellbeing."),
        Topic(id: "mental-health", name: "Mental health", iconName: nil, order: 3, isActive: true, description: "Research connecting emotional and physical health."),
        Topic(id: "nutrition", name: "Nutrition", iconName: nil, order: 4, isActive: true, description: "Practical findings about food and women’s health."),
        Topic(id: "fertility", name: "Fertility", iconName: nil, order: 5, isActive: true, description: "Research about fertility and reproductive health."),
        Topic(id: "sleep", name: "Sleep", iconName: nil, order: 6, isActive: true, description: "How rest and sleep patterns affect health.")
    ]
}
