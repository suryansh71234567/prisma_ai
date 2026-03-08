# Prisma AI
### Adaptive JEE/NEET Tutoring Through Knowledge-Aware Socratic Dialogue

> *"The goal is not to detect what students know. It is to detect the distance between what they know and what they think they know — and close it."*

---

## The Problem Nobody Is Solving Correctly

Every serious JEE aspirant studies for 4–6 hours a day. Most have access to video lectures, mock tests, and coaching institute materials. Yet the gap between students who crack JEE Advanced and those who don't is rarely a gap in exposure to content. It is a gap in **calibration**.

Students fail JEE Advanced not because they haven't seen Gauss's Law. They fail because they have seen it, practiced it in its standard form, scored well on chapter tests — and then encounter a problem that is one step outside the familiar format, and freeze. They *believe* they know the concept. They don't know that they only know the special case. This is **metacognitive miscalibration** — and it is the central, unsolved problem in JEE preparation.

Current solutions treat this as a content problem. Give the student more practice problems. More video lectures. More mock tests. None of this closes the calibration gap because none of it is designed to. A student who scores 70% on a capacitor chapter test and a student who genuinely understands capacitors look identical to every existing tool. They are not identical students.

Prisma AI is built around one thesis: **the most valuable thing a tutoring system can do is find and close the gap between a student's perceived mastery and their actual mastery**, concept by concept, in real time.

---

## What Prisma AI Does

Prisma AI is a personalized tutoring system for JEE/NEET aspirants that combines a knowledge graph of the entire JEE syllabus, a Socratic AI tutor that teaches rather than explains, and a machine learning model that tracks the student's true knowledge state across every session.

The system runs in 25-minute sessions. At the start of each session, a planner reads the student's full learning history and knowledge state, and generates a precise session plan — which concept to teach, how to teach it, which past concepts to embed into practice problems for automatic revision, and which error types to specifically probe based on past failures. The tutor then executes this plan through dialogue, asking questions, giving hints, presenting problems, and adapting in real time. At the end of the session, the knowledge graph is updated and the next session is planned during the break.

---

## The Research Foundation

### Productive Failure (Kapur, 2016)

Manu Kapur's research on productive failure demonstrated that students who struggle with a problem *before* being taught the solution develop significantly deeper conceptual understanding than students who are taught first and then practice. The conventional tutoring model — explain, then ask — is pedagogically backwards for developing robust knowledge.

Prisma AI's Socratic tutor is built on this principle. The tutor does not explain first. It asks first, probes the student's existing mental model, and uses the student's own reasoning — correct or incorrect — as the foundation for teaching. Explanation follows struggle, not the other way around.

### Interleaved Practice (Rohrer & Taylor, 2007)

Blocked practice — studying all of Chapter 5 before moving to Chapter 6 — produces strong short-term performance but poor long-term retention. Interleaved practice, where each problem mixes concepts from multiple chapters, produces dramatically better retention and transfer, even though students find it harder and rate it less enjoyable in the moment.

Every question in a Prisma AI session is designed to *primarily* test the current session's concept while *embedding* 1–2 previously learned concepts in the problem setup. A problem about capacitor energy that requires Kirchhoff's Laws to set up is simultaneously teaching new content and revising old content. This makes dedicated revision sessions unnecessary — revision is structurally built into every problem.

### Knowledge Tracing (Corbett & Anderson, 1994 — BKT; Zhang et al., 2017 — DKT; Ghosh et al., 2020 — AKT)

The Knowledge Tracing lineage, from Bayesian Knowledge Tracing through Deep Knowledge Tracing to Attentive Knowledge Tracing, establishes that a student's knowledge state can be modeled as a latent variable that updates with each observed interaction. The key insight from AKT specifically — that attention mechanisms can weight past interactions by their *relevance* to the current question, not just their recency — is what makes fine-grained concept-level mastery estimation possible at scale.

Prisma AI's Knowledge Tracing component is designed around this lineage, with an LSTM baseline that upgrades to an AKT-inspired attention model as the system accumulates interaction data.

---

## The Core Architecture

### The Knowledge Graph

The backbone of the system is a Neo4j knowledge graph covering the entire JEE syllabus. What makes this graph different from a simple topic hierarchy is its **edge type taxonomy** — eight distinct types of relationships between concepts, each encoding a different kind of pedagogical relationship.

The most important insight embedded in this graph is that student errors are not all the same. A student who confuses Gauss's Law with Coulomb's Law needs a discrimination exercise. A student who can solve the standard spherical shell problem but fails when the geometry changes needs exposure to the general principle they're missing. A student who has never connected LC oscillations to their strong understanding of simple harmonic motion needs an analogy bridge, not re-teaching. These are three different errors, requiring three different interventions, and a system that treats them all as "weak on electrostatics" will give the wrong intervention two out of three times.

The eight edge types — REQUIRES, COMMONLY_CONFUSED_WITH, ANALOGY_OF, GENERALIZES, USED_TOGETHER, CONTRASTS_WITH, APPEARS_IN_PROBLEM_TYPE, EXTENDS — collectively encode enough structure for the system to identify which of eight error types is occurring and route to the precise intervention for that error type.

### The Error Taxonomy

| Error Type | What It Looks Like | What It Actually Is |
|---|---|---|
| PREREQUISITE_GAP | Student gets stuck early in a problem | Missing foundational concept |
| CONFUSION_ERROR | Student applies the right method to the wrong concept | Two concepts misfiled as one |
| SPECIAL_CASE_FIXATION | Solves standard problems, fails variants | Knows the formula, not the principle |
| ANALOGICAL_TRANSFER_FAILURE | Treats a familiar concept as entirely new | Hasn't connected it to what they know |
| COORDINATION_FAILURE | Knows A and B separately, fails problems requiring both | Never practiced them together |
| DISCRIMINATION_FAILURE | Alternates between correct and incorrect on similar problems | Can't identify the deciding factor |
| PROBLEM_TYPE_UNFAMILIARITY | "I knew it but didn't know how to start" | Concept knowledge without problem-type knowledge |
| SURFACE_KNOWLEDGE | High recall, low transfer | Memorized form, not understood principle |

### The Session Loop

```
BREAK (5 min)
  Planner LLM reads knowledge graph + session history
  Generates structured 25-minute session plan
  Plan written to Redis before break ends

SESSION (25 min)
  Tutor works through: intro → definition → examples →
  logical questions → problem → solution discussion → wrap-up
  Real-time adaptation based on student responses
  Session ends when tutor signals completion or time runs out

POST-SESSION
  Summarizer generates structured handoff for next planner
  Knowledge graph mastery scores updated
  Student sees graph visualization during break
```

The feedback loop is 30 minutes. Most adaptive learning systems have a 24-hour feedback cycle — they update after a day's work and adjust for the next day. Prisma AI adjusts every session. A misaligned plan costs 25 minutes, not a week.

### Commentary-Based Question Retrieval

Questions in Prisma AI are not retrieved by keyword matching or simple topic tags. Each question has an LLM-generated commentary that describes what a student who truly understands the concept will do, what a student with surface knowledge will do, which error type the question is designed to expose, and which prerequisite concepts are implicitly required. Questions are retrieved by embedding this commentary and searching semantically.

This means when the tutor needs a question targeting SPECIAL_CASE_FIXATION on Gauss's Law at medium difficulty, it retrieves questions that actually test that specific failure mode — not just any Gauss's Law question.

---

## How This Compares to What Exists

### Coaching Institute Apps (Vedantu, Unacademy, PW)

These are delivery platforms. They take the classroom model — a teacher explains, students watch — and put it online. The student's role is passive. There is no model of what any individual student knows. Content is the same for everyone. Adaptation, if it exists at all, means "you got this wrong, here's the solution video." This is not adaptive tutoring. It is adaptive content recommendation, which is a much weaker intervention.

### AI Chat Tutors (ChatGPT, generic LLM wrappers)

These systems have no persistent model of the student. Every conversation starts fresh. They explain when asked and answer when questioned, but they do not probe, they do not sequence, and they do not adapt based on history. Most importantly, they explain rather than question — they are encyclopedias, not tutors. A student can have a productive conversation with ChatGPT about Gauss's Law and come away believing they understand it without having demonstrated any understanding at all. Prisma AI's Socratic approach specifically prevents this by requiring the student to reason, not just receive.

### Squirrel AI

Squirrel AI is the most serious comparison. It is a Chinese adaptive learning company that has published peer-reviewed research demonstrating mastery learning outcomes comparable to one-on-one human tutoring. Their system works through granular knowledge component decomposition, mastery-based progression, and a large proprietary question bank.

Prisma AI is building toward the same destination through a different path. Where Squirrel AI decomposes knowledge into fine-grained components and routes students through a mastery sequence, Prisma AI adds a conversational tutoring layer that makes the *type* of gap visible — not just which concepts are weak, but why they are weak and which intervention closes them fastest. The knowledge graph's edge taxonomy is doing work that Squirrel AI's component graph cannot: it encodes the relationship between concepts at a pedagogical level, not just a curriculum sequencing level.

At scale, with sufficient interaction data, Prisma AI's graph-informed Knowledge Tracing model should outperform topic-based mastery estimation on transfer problems — the exact problems that determine JEE rank.

The key commercial difference: Squirrel AI requires a massive proprietary question bank built over years. Prisma AI's commentary-based retrieval and Socratic generation approach allows a much smaller seed question bank to cover a much larger effective question space, because the tutor generates question variants rather than retrieving from a fixed set.

---

## Why This Could Be a Large Company

The JEE preparation market in India is approximately $3–4 billion annually. It is dominated by offline coaching institutes (Allen, FIITJEE, Resonance) whose unit economics — large classrooms, one teacher, standardized content — have not changed in 30 years. The market is price-sensitive but highly performance-sensitive: families routinely spend ₹1–3 lakh per year on JEE preparation for a child, and the primary purchase criterion is results.

The insight that matters for the business case is this: **a system that reliably improves student rank by identifying and closing metacognitive gaps is not competing with coaching institutes on price. It is offering something coaching institutes structurally cannot offer — individualization at scale.** A classroom of 150 students cannot receive 150 different session plans. Prisma AI can serve 150,000 students simultaneously with individualized plans.

The NEET market is structurally similar and approximately the same size. JEE and NEET together represent roughly 2.5 million serious annual aspirants, most of whom spend significant money on preparation. The same knowledge graph, reweighted for NEET subject matter, serves both markets.

Beyond India, the GRE, GMAT, UPSC, and international competitive exam markets are structurally identical problems — fixed syllabi, high stakes, large preparation markets, and no existing solution that closes the calibration gap.

---

## Future Development

### Graph Neural Networks for Concept Representation

The current Knowledge Tracing model treats concept mastery as independent estimates. In reality, concepts are deeply interdependent — mastery on Gauss's Law is informative about likely mastery on Ampere's Law in a way that a flat feature vector cannot capture.

The natural extension is to encode the knowledge graph structure directly into the student model using a Relational Graph Convolutional Network (R-GCN). Each concept node's embedding would be informed by its neighbors' embeddings, weighted by edge type. A student who has mastered three of the four Maxwell's Equations prerequisites would have a meaningfully different embedding for displacement current than a student who has mastered none — even if their direct interaction history with displacement current is identical.

This is the architecture that would allow Prisma AI to predict performance on concepts the student has never directly practiced, by propagating mastery signals through the graph. The R-GCN encoder would feed into the attention-based Knowledge Tracing model, replacing the flat concept ID embeddings with graph-informed representations.

### Attentive Knowledge Tracing (AKT)

The LSTM baseline handles sequential interaction history well but treats all past interactions as equally relevant given their position in the sequence. The AKT model's key contribution — using a monotonic attention mechanism that weights past interactions by their relevance to the current question — would significantly improve mastery estimation accuracy, particularly for concepts with sparse interaction history that are topologically close to well-practiced concepts in the graph.

The combination of R-GCN concept embeddings with AKT-style temporal attention would produce a student model that understands both the structure of knowledge and the dynamics of learning within that structure.

### Self-Improving Curriculum Graph

The current knowledge graph is hand-curated by domain experts. At scale, the system will observe thousands of students failing concept A immediately after succeeding on concept B — a signal that A requires B in practice even if it was not encoded as a prerequisite in the original graph. Attention co-activation patterns from the AKT model, combined with embedding similarity clustering, could automatically propose new edges for human review, making the graph progressively more accurate as the system accumulates data.

### Misconception Fingerprinting

When enough students have made the same error on the same concept, the pattern of wrong answers becomes a fingerprint. Students who write `E = kQ/r²` when asked about the field inside a uniformly charged sphere are making a specific, nameable mistake — they know the outside formula but don't know it doesn't apply inside. At sufficient scale, wrong answer clustering would allow the system to identify previously unnamed misconceptions and automatically create targeted interventions for them, making the error taxonomy self-extending.

---

## Technical Stack

| Layer | Technology |
|---|---|
| Backend | FastAPI (Python) |
| LLM Orchestration | Semantic Kernel |
| Language Model | Azure OpenAI GPT-4o / Ollama (local) |
| Knowledge Graph | Neo4j |
| Relational Store | PostgreSQL |
| Session Cache | Redis |
| Vector Search | FAISS (local) / Azure AI Search (production) |
| ML Model | PyTorch LSTM → AKT |
| Embeddings | BAAI/bge-base-en-v1.5 |
| Deployment | Azure App Service + Azure Functions |
| Observability | Azure Application Insights + Semantic Kernel tracing |

---

## Team

**Aryan Gupta · Suryansh Singh · Suyash Agrawal**
Indian Institute of Technology Roorkee

Built for the Microsoft Azure AI Unlocked Hackathon — AI for Education track.

---

## References

- Kapur, M. (2016). Examining Productive Failure, Productive Success, Unproductive Failure, and Unproductive Success in Learning. *Educational Psychologist*, 51(2), 289–299.
- Rohrer, D., & Taylor, K. (2007). The shuffling of mathematics problems improves learning. *Instructional Science*, 35, 481–498.
- Corbett, A. T., & Anderson, J. R. (1994). Knowledge tracing: Modeling the acquisition of procedural knowledge. *User Modeling and User-Adapted Interaction*, 4(4), 253–278.
- Zhang, J., et al. (2017). Dynamic Key-Value Memory Networks for Knowledge Tracing. *WWW '17*.
- Ghosh, A., et al. (2020). Context-Aware Attentive Knowledge Tracing. *KDD '20*.
- Bloom, B. S. (1984). The 2 Sigma Problem: The Search for Methods of Group Instruction as Effective as One-to-One Tutoring. *Educational Researcher*, 13(6), 4–16.
