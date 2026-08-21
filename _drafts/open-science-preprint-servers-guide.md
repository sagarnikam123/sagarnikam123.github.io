---
title: "The Complete Guide to Preprint Servers Across All Disciplines (2026)"
description: "A comprehensive guide to preprint servers organized by discipline. Compare arXiv, bioRxiv, medRxiv, SSRN, ChemRxiv, TechRxiv, and Research Square — screening speed, licensing, DOI assignment, and journal compatibility."
author: sagarnikam123
date: 2026-09-15 12:00:00 +0530
categories: [research, open-access]
tags: [preprints, arxiv, biorxiv, medrxiv, ssrn, research-square, chemrxiv, techrxiv, psyarxiv, socarxiv, osf, open-access, research, scientific-publishing, peer-review]
mermaid: true
image:
  path: assets/img/posts/20260915/open-science-preprint-servers-guide.webp
  alt: Complete Guide to Preprint Servers by Discipline
---

> This is **Part 2** of the [Open Science Toolbox](/posts/open-science-toolbox-free-research/) series.

A **preprint** is a complete, freely accessible scientific manuscript shared on a public server **prior to formal peer review**. It establishes priority, timestamps discovery with a permanent DOI, and accelerates scientific discourse by months or years.

---

## 1. The Publication Pipeline: Where Preprints Fit

```mermaid
flowchart LR
    WP["1. Working Draft<br/><i>(Private)</i>"] --> PP["2. Preprint<br/><b>(arXiv, bioRxiv)</b>"]
    PP --> PR["3. Peer Review<br/><i>(Journal cycle)</i>"]
    PR --> AM["4. Accepted Manuscript<br/><i>(Green OA)</i>"]
    AM --> VoR["5. Version of Record<br/><i>(Publisher Journal)</i>"]

    PP -.->|"Immediate & Free (1-2 days)"| R1["Public Access"]
    AM -.->|"Free after embargo"| R2["Public Access"]
    VoR -.->|"Free (OA) or Paywalled"| R3["Open / Subscription"]

    classDef stepStyle fill:#0f172a,stroke:#38bdf8,stroke-width:1px,color:#f8fafc;
    classDef pubStyle fill:#1e293b,stroke:#22c55e,stroke-width:1px,color:#f8fafc;
    class WP,PP,PR,AM,VoR stepStyle;
    class R1,R2,R3 pubStyle;
```

| Lifecycle Stage | Peer-Reviewed? | Cost to Read? | Citable with DOI? | Editable? |
| :--- | :---: | :---: | :---: | :--- |
| **Working Paper** | ❌ | Usually Free | ❌ (No DOI) | Internal |
| **Preprint** | ❌ | **100% Free** | ✅ **Yes (DataCite DOI)** | ✅ Versioned (v1, v2, v3) |
| **Accepted Manuscript** | ✅ | Free (Green OA) | ✅ Yes | ❌ Fixed author text |
| **Version of Record (VoR)** | ✅ | Paywalled (or OA APC) | ✅ Yes | ❌ Publisher formatted |

> [!WARNING]
> **Critical Medical & Clinical Caveat:** Preprints have **not** undergone formal peer review. Never base immediate clinical treatments, health policies, or medical prescriptions solely on preprint findings without peer-reviewed validation.

---

## 2. Master Directory of Preprint Servers by Discipline

| Discipline | Top Preprint Server | Operator / Backing | Size | Moderation / Screening | Direct Link |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Physics, Math, CS, Stats** | **[arXiv](https://arxiv.org/)** | Cornell University | 2.4M+ | Scholarly check + category moderation (1–2 days) | [arxiv.org](https://arxiv.org/) |
| **Biology & Life Sciences** | **[bioRxiv](https://www.biorxiv.org/)** | openRxiv / CSHL | 300K+ | Basic screening & plagiarism check (<48h) | [biorxiv.org](https://www.biorxiv.org/) |
| **Medicine & Clinical** | **[medRxiv](https://www.medrxiv.org/)** | openRxiv / CSHL / BMJ / Yale | 75K+ | Enhanced safety & ethical protocol audit (2–4 days) | [medrxiv.org](https://www.medrxiv.org/) |
| **Chemistry & Materials** | **[ChemRxiv](https://chemrxiv.org/)** | ACS, RSC, GDCh, CSJ, CCS | 25K+ | Chemical society editorial check (1–2 days) | [chemrxiv.org](https://chemrxiv.org/) |
| **Engineering & Tech** | **[TechRxiv](https://www.techrxiv.org/)** | IEEE | 12K+ | IEEE scope and formatting check (1–3 days) | [techrxiv.org](https://www.techrxiv.org/) |
| **Social Sciences & Econ** | **[SSRN](https://www.ssrn.com/)** | Elsevier | 1.2M+ | Working paper series & editorial screening | [ssrn.com](https://www.ssrn.com/) |
| **Psychology** | **[PsyArXiv](https://psyarxiv.com/)** | SIPS / OSF | 18K+ | Community moderation with preregistration links | [psyarxiv.com](https://psyarxiv.com/) |
| **Earth & Space Sciences** | **[ESSOAr](https://www.essoar.org/)** / **[EarthArXiv](https://eartharxiv.org/)** | AGU / CDL | 15K+ | Earth & environmental sciences scope check | [essoar.org](https://www.essoar.org/) |
| **Multidisciplinary** | **[Research Square](https://www.researchsquare.com/)** | Springer Nature partner | 250K+ | Fast screening + live "In Review" journal badge | [researchsquare.com](https://www.researchsquare.com/) |
| **Multidisciplinary (France)**| **[HAL](https://hal.science/)** | CNRS / CCSD | 4M+ | French national repository & preprint archive | [hal.science](https://hal.science/) |

---

## 3. OSF Community Preprint Services

The [Open Science Framework (OSF)](https://osf.io/preprints/) provides open-source repository infrastructure for over 30+ domain-specific and regional preprint hubs:

| Domain | Community Server | Domain | Community Server |
| :--- | :--- | :--- | :--- |
| **Sociology & Social Sci** | [SocArXiv](https://osf.io/preprints/socarxiv) | **Agriculture** | [AgriXiv](https://osf.io/preprints/agrixiv) |
| **Education Research** | [EdArXiv](https://osf.io/preprints/edarxiv) | **Electrochemistry** | [ECSarXiv](https://osf.io/preprints/ecsarxiv) |
| **Law & Jurisprudence** | [LawArXiv](https://osf.io/preprints/lawarxiv) | **Library & Info Science** | [LISSA](https://osf.io/preprints/lissa) |
| **Marine Conservation** | [MarXiv](https://osf.io/preprints/marxiv) | **Metascience** | [MetaArXiv](https://osf.io/preprints/metaarxiv) |
| **Paleontology** | [PaleorXiv](https://osf.io/preprints/paleorxiv) | **Africa Regional Hub** | [AfricArXiv](https://osf.io/preprints/africarxiv) |
| **India Regional Hub** | [IndiaRxiv](https://osf.io/preprints/indiarxiv) | **Latin America / Iberia** | [SciELO Preprints](https://preprints.scielo.org/) |

---

## 4. Screening vs. Peer Review: What Gets Checked?

Preprint servers enforce quality control via **screening**, not exhaustive peer review:

```mermaid
flowchart TD
    subgraph S["⚡ Preprint Screening (24–72 Hours)"]
        S1["Spam & Obvious Plagiarism Check"]
        S2["Scope & Scholarly Tone Verification"]
        S3["Ethical Declarations & Patient Safety"]
    end

    subgraph P["🔍 Journal Peer Review (3–12 Months)"]
        P1["Deep Methodological & Statistical Audit"]
        P2["Novelty & Theoretical Soundness"]
        P3["Replication & Data Scrutiny"]
    end

    S1 --> S2 --> S3
    P1 --> P2 --> P3

    classDef screen fill:#1e293b,stroke:#38bdf8,stroke-width:1px,color:#f8fafc;
    classDef peer fill:#1e293b,stroke:#a855f7,stroke-width:1px,color:#f8fafc;
    class S screen;
    class P peer;
```

---

## 5. Licensing: Don't Compromise Your Publication Rights

When depositing a preprint, your license choice dictates downstream reuse:

| License | Public Reading | Attribution Required | Derivative Works Allowed | Commercial Exploitation | Recommendation |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **CC-BY 4.0** | ✅ | ✅ | ✅ | ✅ | **Best for maximum citations & grant compliance** |
| **CC-BY-NC** | ✅ | ✅ | ✅ | ❌ | Good if preventing commercial paywall repackaging |
| **CC-BY-ND** | ✅ | ✅ | ❌ | ✅ | ⚠️ Avoid: Disallows translation & figure reuse |
| **CC0 (Public Domain)**| ✅ | ❌ (Academic norms apply) | ✅ | ✅ | **Ideal for raw data tables and software code** |

> [!TIP]
> Always verify your target journal's policy on [Sherpa Romeo](https://v2.sherpa.ac.uk/romeo/). Almost all major publishers (Nature, Science/AAAS, Elsevier, Springer, IEEE, PLOS) fully accept preprinted manuscripts.

---

## 6. How to Select the Right Preprint Server

```mermaid
flowchart TD
    Start{"What is your research discipline?"}

    Start -->|Physics, Math, CS, Stats, AI| S1["Post to <b><a href='https://arxiv.org/'>arXiv</a></b><br/><i>(Industry gold standard)</i>"]
    Start -->|Biology, Genomics, Ecology| S2["Post to <b><a href='https://www.biorxiv.org/'>bioRxiv</a></b><br/><i>(Offers direct 1-click B2J journal submission)</i>"]
    Start -->|Medicine, Clinical Trials| S3["Post to <b><a href='https://www.medrxiv.org/'>medRxiv</a></b><br/><i>(Strict clinical safety screening)</i>"]
    Start -->|Chemistry, Nanotech| S4["Post to <b><a href='https://chemrxiv.org/'>ChemRxiv</a></b><br/><i>(Backed by ACS & global societies)</i>"]
    Start -->|Electrical, Hardware, Robotics| S5["Post to <b><a href='https://www.techrxiv.org/'>TechRxiv</a></b><br/><i>(Direct IEEE journal integration)</i>"]
    Start -->|Social Science, Economics, Law| S6["Post to <b><a href='https://www.ssrn.com/'>SSRN</a></b> or <b><a href='https://osf.io/preprints/socarxiv'>SocArXiv</a></b>"]
    Start -->|Multidisciplinary / Cross-Domain| S7["Post to <b><a href='https://www.researchsquare.com/'>Research Square</a></b> or <b><a href='https://osf.io/preprints/'>OSF</a></b>"]

    classDef startNode fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff;
    classDef serverNode fill:#0f172a,stroke:#38bdf8,stroke-width:1px,color:#f8fafc;
    class Start startNode;
    class S1,S2,S3,S4,S5,S6,S7 serverNode;
```

---

## 7. Open Review Platforms & Living Preprints

Preprints are increasingly reviewed openly by the scientific community before formal acceptance:

- **[PREreview](https://prereview.org/)** — Crowdsourced, structured peer reviews for preprints across disciplines.
- **[Review Commons](https://www.reviewcommons.org/)** — High-quality, journal-agnostic peer review. Authors receive a peer-reviewed "Refereed Preprint" that can be transferred directly to participating journals without starting over.
- **[Peer Community In (PCI)](https://peercommunityin.org/)** — Community of researchers that peer-reviews and recommends preprints for free, creating Diamond OA validation without journal fees.

---

## References & Authority Links

- [Directory of Open Access Preprint Repositories (DOAPR)](https://doapr.coar-repositories.org/repositories/)
- [Sherpa Romeo — Publisher Copyright & Self-Archiving Policies](https://v2.sherpa.ac.uk/romeo/)
- [OSF Preprint Services Infrastructure](https://help.osf.io/article/686-preprint-services)
- [openRxiv Organization](https://www.openrxiv.org/)
- [arXiv Operational Overview & Submission Help](https://info.arxiv.org/help/index.html)

---

*Previous: **[Part 1 — 25+ Academic Search Engines](/posts/open-science-search-engines-discovery-tools/)** | Next: **[Part 3 — How to Find Paywalled Research Papers for Free — Legally](/posts/open-science-find-paywalled-research-free/)***
