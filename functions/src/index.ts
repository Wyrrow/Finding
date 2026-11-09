/* eslint-disable require-jsdoc */

import {initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

initializeApp();

setGlobalOptions({
  region: "europe-west1",
  maxInstances: 3,
});

const db = getFirestore();
const RESEARCH_COLLECTION = "researches";
const TOPICS_COLLECTION = "topics";
const EUROPE_PMC_SEARCH_URL =
  "https://www.ebi.ac.uk/europepmc/webservices/rest/search";

interface EuropePmcAuthor {
  fullName?: string;
  affiliation?: string;
}

interface EuropePmcResult {
  id?: string;
  pmid?: string;
  doi?: string;
  title?: string;
  abstractText?: string;
  journalTitle?: string;
  firstPublicationDate?: string;
  authorString?: string;
  authorList?: {
    author?: EuropePmcAuthor[];
  };
  pubTypeList?: {
    pubType?: string[];
  };
}

interface EuropePmcSearchResponse {
  resultList?: {
    result?: EuropePmcResult[];
  };
}

interface ResearchAuthor {
  name: string;
  organization: string | null;
}

interface ImportedResearch {
  id: string;
  pmid: string | null;
  doi: string | null;
  originalTitle: string;
  displayTitle: string;
  shortSummary: string;
  keyFindings: string[];
  whyItMatters: string;
  limitations: string;
  topicIds: string[];
  authors: ResearchAuthor[];
  journalName: string;
  publicationDate: Timestamp | null;
  sourceURL: string;
  studyType: string;
  participantsCount: number | null;
  evidenceQuality: "high" | "moderate" | "emerging";
  savesCount: number;
  isVisible: boolean;
  sourceName: "Europe PMC";
  processingStatus: "pending_ai";
  importedAt: FieldValue;
  updatedAt: FieldValue;
}

const topics = [
  {
    id: "my-feed",
    name: "My Feed",
    iconName: null,
    order: 0,
    isActive: true,
    description: "Research selected around your interests.",
  },
  {
    id: "cycle-health",
    name: "Cycle health",
    iconName: null,
    order: 1,
    isActive: true,
    description: "Research about menstrual health at every stage.",
  },
  {
    id: "hormones",
    name: "Hormones",
    iconName: null,
    order: 2,
    isActive: true,
    description: "Evidence about hormones, symptoms and wellbeing.",
  },
  {
    id: "mental-health",
    name: "Mental health",
    iconName: null,
    order: 3,
    isActive: true,
    description: "Research connecting emotional and physical health.",
  },
  {
    id: "nutrition",
    name: "Nutrition",
    iconName: null,
    order: 4,
    isActive: true,
    description: "Research about food and women's health.",
  },
  {
    id: "fertility",
    name: "Fertility",
    iconName: null,
    order: 5,
    isActive: true,
    description: "Research about fertility and reproductive health.",
  },
  {
    id: "sleep",
    name: "Sleep",
    iconName: null,
    order: 6,
    isActive: true,
    description: "How rest and sleep patterns affect health.",
  },
] as const;

export const importRecentResearch = onSchedule(
  {
    schedule: "every day 06:00",
    timeZone: "Europe/Chisinau",
    timeoutSeconds: 300,
    memory: "512MiB",
    maxInstances: 1,
    retryCount: 1,
  },
  async () => {
    await ensureTopics();

    const publications = await fetchRecentPublications();
    const importedCount = await saveNewPublications(publications);

    logger.info("Research import completed", {
      receivedCount: publications.length,
      importedCount,
    });
  },
);

async function ensureTopics(): Promise<void> {
  const batch = db.batch();

  for (const topic of topics) {
    const reference = db.collection(TOPICS_COLLECTION).doc(topic.id);
    batch.set(reference, topic, {merge: true});
  }

  await batch.commit();
}

async function fetchRecentPublications(): Promise<EuropePmcResult[]> {
  const fromDate = new Date();
  fromDate.setUTCFullYear(fromDate.getUTCFullYear() - 2);

  const query = [
    "SRC:MED",
    "HAS_ABSTRACT:Y",
    `FIRST_PDATE:[${formatDate(fromDate)} TO ${formatDate(new Date())}]`,
    "(women OR female)",
    "(menstrual OR hormone OR fertility OR pregnancy OR menopause " +
      "OR endometriosis OR PCOS OR contraception)",
  ].join(" AND ");

  const parameters = new URLSearchParams({
    query: `${query} sort_date:y`,
    format: "json",
    resultType: "core",
    pageSize: "25",
  });

  const response = await fetch(`${EUROPE_PMC_SEARCH_URL}?${parameters}`);

  if (!response.ok) {
    throw new Error(
      `Europe PMC request failed: ${response.status} ${response.statusText}`,
    );
  }

  const payload = await response.json() as EuropePmcSearchResponse;
  return payload.resultList?.result ?? [];
}

async function saveNewPublications(
  publications: EuropePmcResult[],
): Promise<number> {
  const candidates = publications
    .map(mapPublication)
    .filter((item): item is ImportedResearch => item !== null);

  if (candidates.length === 0) {
    return 0;
  }

  const references = candidates.map((item) =>
    db.collection(RESEARCH_COLLECTION).doc(item.id),
  );
  const existingSnapshots = await db.getAll(...references);
  const batch = db.batch();
  let importedCount = 0;

  existingSnapshots.forEach((snapshot, index) => {
    if (snapshot.exists) {
      return;
    }

    batch.create(references[index], candidates[index]);
    importedCount += 1;
  });

  if (importedCount > 0) {
    await batch.commit();
  }

  return importedCount;
}

function mapPublication(result: EuropePmcResult): ImportedResearch | null {
  const originalTitle = cleanText(result.title ?? "");
  const abstract = cleanText(result.abstractText ?? "");
  const id = createResearchId(result);

  if (!id || !originalTitle || !abstract) {
    return null;
  }

  const studyType = detectStudyType(result.pubTypeList?.pubType ?? []);

  return {
    id,
    pmid: result.pmid ?? null,
    doi: result.doi?.toLowerCase() ?? null,
    originalTitle,
    displayTitle: originalTitle,
    shortSummary: firstSentences(abstract, 2, 600),
    keyFindings: [],
    whyItMatters: "",
    limitations: "",
    topicIds: detectTopicIds(`${originalTitle} ${abstract}`),
    authors: mapAuthors(result),
    journalName: cleanText(result.journalTitle ?? "Unknown journal"),
    publicationDate: parsePublicationDate(result.firstPublicationDate),
    sourceURL: createSourceUrl(result),
    studyType,
    participantsCount: null,
    evidenceQuality: preliminaryEvidenceQuality(studyType),
    savesCount: 0,
    isVisible: false,
    sourceName: "Europe PMC",
    processingStatus: "pending_ai",
    importedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function createResearchId(result: EuropePmcResult): string | null {
  if (result.pmid) {
    return `pmid-${result.pmid}`;
  }

  if (result.doi) {
    return `doi-${result.doi.toLowerCase().replace(/[^a-z0-9]+/g, "-")}`
      .replace(/-+$/g, "");
  }

  if (result.id) {
    return `europe-pmc-${result.id.toLowerCase()}`;
  }

  return null;
}

function mapAuthors(result: EuropePmcResult): ResearchAuthor[] {
  const detailedAuthors = result.authorList?.author
    ?.filter((author) => author.fullName)
    .slice(0, 20)
    .map((author) => ({
      name: cleanText(author.fullName ?? ""),
      organization: author.affiliation ?
        cleanText(author.affiliation) :
        null,
    }));

  if (detailedAuthors?.length) {
    return detailedAuthors;
  }

  return (result.authorString ?? "")
    .split(",")
    .map((name) => cleanText(name))
    .filter(Boolean)
    .slice(0, 20)
    .map((name) => ({name, organization: null}));
}

function detectStudyType(publicationTypes: string[]): string {
  const value = publicationTypes.join(" ").toLowerCase();

  if (value.includes("meta-analysis")) return "metaAnalysis";
  if (value.includes("systematic review")) return "systematicReview";
  if (value.includes("clinical trial") || value.includes("randomized")) {
    return "clinicalTrial";
  }
  if (value.includes("observational") || value.includes("cohort") ||
      value.includes("case-control")) {
    return "observational";
  }
  if (value.includes("laboratory") || value.includes("in vitro")) {
    return "laboratory";
  }
  if (value.includes("review")) return "review";
  return "other";
}

function preliminaryEvidenceQuality(
  studyType: string,
): "high" | "moderate" | "emerging" {
  if (studyType === "metaAnalysis" || studyType === "systematicReview") {
    return "moderate";
  }
  if (studyType === "clinicalTrial") {
    return "moderate";
  }
  return "emerging";
}

function detectTopicIds(text: string): string[] {
  const normalized = text.toLowerCase();
  const detected = new Set<string>();

  addTopic(detected, normalized, "cycle-health", [
    "menstrual", "menstruation", "premenstrual", "dysmenorrhea", "period",
  ]);
  addTopic(detected, normalized, "hormones", [
    "hormone", "estrogen", "oestrogen", "progesterone", "endocrine",
    "pcos", "polycystic ovary", "menopause",
  ]);
  addTopic(detected, normalized, "mental-health", [
    "mental health", "depression", "anxiety", "stress", "mood",
  ]);
  addTopic(detected, normalized, "nutrition", [
    "nutrition", "diet", "food", "vitamin", "mineral", "supplement",
  ]);
  addTopic(detected, normalized, "fertility", [
    "fertility", "infertility", "pregnan", "ovulation", "reproductive",
    "contraception", "endometriosis",
  ]);
  addTopic(detected, normalized, "sleep", [
    "sleep", "insomnia", "circadian",
  ]);

  if (detected.size === 0) {
    detected.add("cycle-health");
  }

  return [...detected];
}

function addTopic(
  target: Set<string>,
  text: string,
  topicId: string,
  keywords: string[],
): void {
  if (keywords.some((keyword) => text.includes(keyword))) {
    target.add(topicId);
  }
}

function parsePublicationDate(value?: string): Timestamp | null {
  if (!value) return null;

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : Timestamp.fromDate(date);
}

function createSourceUrl(result: EuropePmcResult): string {
  if (result.pmid) {
    return `https://pubmed.ncbi.nlm.nih.gov/${result.pmid}/`;
  }
  if (result.doi) {
    return `https://doi.org/${result.doi}`;
  }
  return `https://europepmc.org/article/MED/${result.id ?? ""}`;
}

function firstSentences(
  text: string,
  sentenceCount: number,
  maxLength: number,
): string {
  const sentences = text.match(/[^.!?]+[.!?]+|[^.!?]+$/g) ?? [text];
  const summary = sentences.slice(0, sentenceCount).join(" ").trim();

  if (summary.length <= maxLength) {
    return summary;
  }

  return `${summary.slice(0, maxLength - 1).trimEnd()}…`;
}

function cleanText(value: string): string {
  return value
    .replace(/<[^>]*>/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, "\"")
    .replace(/&#39;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}
