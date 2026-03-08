# Prisma AI — Extended Knowledge Graph Schema
## Edge Type Taxonomy · Error Classification · Query Library

---

## Part 1 — Why Multiple Edge Types?

The original schema had two edge types: `REQUIRES` and `IS_PART_OF`.
That's enough to answer one question: *"What does this student need to know first?"*

But the Tutor Agent needs to answer seven different questions:

| Agent needs to answer | Requires edge type |
|---|---|
| What is the student missing as a foundation? | `REQUIRES` |
| What is the student confusing this with? | `COMMONLY_CONFUSED_WITH` |
| What does this concept structurally resemble, from another chapter? | `ANALOGY_OF` |
| What is the general principle behind this special case? | `GENERALIZES` |
| What other concepts always co-appear with this in JEE problems? | `USED_TOGETHER` |
| What is this concept's opposite or complement? | `CONTRASTS_WITH` |
| Where is this concept actually applied in real problems? | `APPEARS_IN_PROBLEM_TYPE` |

Without the right edge type, the tutor agent fires the wrong traversal, finds
irrelevant concepts, and either over-teaches (bombards the student) or
misses the actual gap entirely.

---

## Part 2 — Complete Edge Type Taxonomy

### 2.1 `REQUIRES`  *(already in schema)*
**Direction:** `(A)-[:REQUIRES]->(B)` — A requires B  
**Semantics:** Hard prerequisite. A student who does not understand B cannot
meaningfully engage with A. Violated when a student attempts A and
fails because B is absent from their knowledge state.

**When the agent fires REQUIRES traversal:**
- Student gives a structurally correct setup but fails at a foundational
  step (wrong direction from cross product, wrong sign on potential)
- KT model shows high attempt rate but low success rate on concept A
  *and* low mastery on some B where `A-[:REQUIRES]->B`

**Traversal depth:** 1–4 hops. Beyond 4 hops you are usually in Class 10
territory which is assumed known.

---

### 2.2 `COMMONLY_CONFUSED_WITH`
**Direction:** Bidirectional `(A)-[:COMMONLY_CONFUSED_WITH]-(B)`  
**Semantics:** Students frequently substitute A when they should use B or
vice versa. This is an **error of commission**, not omission — the student
has *some* knowledge, just misfiled. Distinct from REQUIRES in that the
student has seen both A and B; they just can't tell them apart under
pressure.

**Examples in electrodynamics:**
```
electric_potential ↔ electric_potential_energy
resistance_resistivity ↔ temp_dependence_resistance
capacitive_reactance ↔ inductive_reactance
rms_values ↔ ac_basics (peak vs rms confusion)
gauss_law ↔ coulombs_law (flux vs force)
field_due_to_dipole ↔ potential_due_to_dipole (1/r² vs 1/r)
impedance ↔ resistance_resistivity
magnetic_flux ↔ electric_flux
faradays_law ↔ lenzs_law (magnitude vs direction)
self_inductance ↔ mutual_inductance
```

**When the agent fires COMMONLY_CONFUSED_WITH traversal:**
- Student applies correct method for a *related* concept on the wrong problem
- Student's error is systematic (same wrong substitution across multiple attempts)
- KT model: high mastery on A, low mastery on problems requiring B, but
  student's wrong answers on B are exactly what A would give

**Agent behavior:** Pull both A and its COMMONLY_CONFUSED_WITH neighbors.
Ask a discrimination question: *"Here are two problems. In which one do
you use [A] and in which one [B]? What is the deciding factor?"*

---

### 2.3 `ANALOGY_OF`
**Direction:** `(A)-[:ANALOGY_OF {strength: 0.9, domain: 'structural'}]->(B)`  
**Properties:** `strength` (0.0–1.0), `domain` ('structural' | 'mathematical' | 'physical')  
**Semantics:** A and B are structurally, mathematically, or physically
analogous. A student who deeply understands B should be able to derive
understanding of A by mapping the analogy. This is the most powerful
pedagogical edge — it lets the tutor skip re-teaching and instead
*transfer* mastery across chapters.

**Key analogies in electrodynamics:**
```
gauss_law      ↔  amperes_law           (flux law for E vs circulation law for B)
electric_flux  ↔  magnetic_flux         (both surface integrals of a vector field)
electric_dipole ↔ magnetic_dipole_moment_current  (p=qd vs m=NIA, same torque formula)
coulombs_law   ↔  biot_savart_law       (both 1/r² source laws, just different fields)
energy_stored_capacitor ↔ energy_stored_inductor (½CV² vs ½LI², dual energy forms)
capacitive_reactance ↔ inductive_reactance  (both are frequency-dependent "resistance")
lc_oscillations ↔ simple_harmonic_motion  (strongest analogy in all of physics)
electric_potential ↔ gravitational_potential  (cross-subject, very powerful)
faradays_law ↔ work_energy_theorem      (rate of flux change → EMF, as F·ds → work)
field_due_to_dipole ↔ field_due_to_bar_magnet  (identical math, different origin)
```

**When the agent fires ANALOGY_OF traversal:**
- Student has high mastery on B but zero mastery on A, and A ANALOGY_OF B exists
- This is an **opportunity** edge, not a gap edge — the agent *uses* known
  mastery rather than filling a void
- Student has shown ability to use analogical reasoning in past sessions
  (behavioral score dimension: `abstract_reasoning_score`)

**Agent behavior:** *"You already understand [B] well. The math of [A] is
identical — the quantities just play different roles. Let me show you the
mapping."* Then ask a transfer problem.

---

### 2.4 `GENERALIZES`
**Direction:** `(A)-[:GENERALIZES]->(B)` — A is the general case of B  
**Semantics:** B is a special case or limiting case of A. A student who
only knows B has **fragile knowledge** — they can solve standard problems
but fail as soon as a parameter changes. This is the core of JEE Advanced
difficulty: problems are specifically designed to be one step outside the
special case students practiced.

**Examples:**
```
gauss_law_applications  →  field_due_to_shell      (shell is a special Gaussian surface)
gauss_law_applications  →  field_due_to_solid_sphere
gauss_law_applications  →  field_due_to_line_charge
faradays_law            →  motional_emf            (motional EMF is a special case)
biot_savart_law         →  field_straight_wire     (straight wire is one integral)
biot_savart_law         →  field_circular_loop
amperes_law             →  field_solenoid
amperes_law             →  field_toroid
series_rlc_circuit      →  ac_through_resistor     (R-only is RLC with L=C=0)
kirchhoffs_laws         →  series_parallel_resistors
complex_resistor_networks → wheatstone_bridge
superposition_principle_fields → field_due_to_ring
```

**When the agent fires GENERALIZES traversal:**
- Student solves the standard form correctly but fails a variant problem
- KT model: high mastery on B, low mastery on A (knows special case, not general)
- This is the "overconfident gap" detector — the student *thinks* they know
  the chapter but only knows the formula, not the principle

**Agent behavior:** *"You solved the standard solenoid problem correctly.
Now here's a toroid — same law, different geometry. Try it."* The goal is
to push from B to A. If they fail, the diagnosis is confirmed; teach A
(the general principle) instead of re-teaching B.

---

### 2.5 `USED_TOGETHER`
**Direction:** `(A)-[:USED_TOGETHER {frequency: 0.8, problem_type: 'circuit_analysis'}]-(B)`  
**Properties:** `frequency` (how often they co-appear in JEE problems), `problem_type` (string tag)  
**Semantics:** A and B are not prerequisites of each other but appear
*simultaneously* in standard JEE problem types. A student who knows both
A and B in isolation may still fail a problem requiring both because they
haven't practiced the **coordination** of the two concepts.

**High-frequency pairs in electrodynamics:**
```
kirchhoffs_laws        + capacitors_networks      (capacitor circuits)
kirchhoffs_laws        + emf_internal_resistance  (multi-cell circuits)
faradays_law           + lenzs_law                (always needed together)
motional_emf           + magnetic_force_on_wire   (rod on rails problems)
self_inductance        + energy_stored_inductor   (magnetic energy problems)
gauss_law              + conductors_electrostatics (charge distribution problems)
lorentz_force          + circular_motion          (charged particle in B field)
series_rlc_circuit     + resonance_rlc            (resonance condition problems)
electric_potential     + work_energy_theorem      (charge movement problems)
wheatstone_bridge      + temp_dependence_resistance (thermistor bridge problems)
biot_savart_law        + superposition_principle_fields (multi-wire field problems)
```

**When the agent fires USED_TOGETHER traversal:**
- Student knows both A and B individually (KT model mastery > 0.7 on each)
  but fails problems where both appear simultaneously
- Session behavioral data shows student starts a problem correctly (uses A)
  then abandons or shifts approach mid-problem
- This is a **coordination gap**, distinct from a knowledge gap

**Agent behavior:** Give a problem that *requires* A and B to be used in
sequence. Don't explain either concept — explain the *coordination pattern*.

---

### 2.6 `CONTRASTS_WITH`
**Direction:** `(A)-[:CONTRASTS_WITH {dimension: 'sign_convention'}]-(B)`  
**Properties:** `dimension` (what dimension they differ on)  
**Semantics:** A and B are understood *by comparison*. Neither fully makes
sense in isolation — each concept defines its meaning partly through what
it is NOT. Critical for concepts that JEE distinguishes through sign,
direction, magnitude, or physical interpretation.

**Key contrasting pairs:**
```
electric_field_concept  ↔  electric_potential       (vector vs scalar)
capacitors_series       ↔  capacitors_parallel      (charge same vs voltage same)
self_inductance         ↔  mutual_inductance         (own flux vs mutual flux)
diamagnetism            ↔  paramagnetism             (χ < 0 vs χ > 0)
soft magnet             ↔  hard magnet               (hysteresis loop shape)
electric_flux           ↔  magnetic_flux             (Gauss: nonzero vs zero)
series resonance        ↔  parallel resonance        (I max vs I min)
emf_internal_resistance ↔  terminal_voltage          (open circuit vs loaded)
motional_emf            ↔  induced_electric_field    (conductor vs free space EMF)
ac_through_capacitor    ↔  ac_through_inductor       (phase lead vs lag)
```

**When the agent fires CONTRASTS_WITH traversal:**
- Student consistently gets the *sign* or *direction* wrong
- Student passes recognition questions but fails application (knows definition
  of both but applies wrong one under pressure)
- Discrimination task: present both A and B, ask student to identify which
  applies to a given scenario

---

### 2.7 `APPEARS_IN_PROBLEM_TYPE`
**Direction:** `(A)-[:APPEARS_IN_PROBLEM_TYPE]->(P:ProblemType)`  
*(Requires a `ProblemType` node layer — see Section 3)*  
**Semantics:** Concept A is the *key concept* tested in problem type P.
This edge connects the abstract concept graph to the concrete problem taxonomy
that JEE actually tests. Critical for a tutoring system: students need to
learn concepts *as they appear in problems*, not in the abstract.

**JEE Problem Types (ProblemType node examples):**
```
rod_on_rails            — motional_emf, magnetic_force_on_wire, kirchhoffs_laws
charged_particle_fields — lorentz_force, motion_in_magnetic_field, velocity_selector
capacitor_network       — capacitors_series, capacitors_parallel, kirchhoffs_laws
rc_transient            — rc_circuit_charging, kirchhoffs_laws, exponential_functions
spherical_conductor     — conductors_electrostatics, gauss_law_applications, potential_due_to_shell
resonance_circuit       — series_rlc_circuit, resonance_rlc, quality_factor
infinite_resistor_grid  — complex_resistor_networks, kirchhoffs_laws
electromagnetic_energy  — energy_stored_inductor, energy_stored_capacitor, lc_oscillations
dipole_problems         — electric_dipole, field_due_to_dipole, potential_due_to_dipole
```

**When the agent fires APPEARS_IN_PROBLEM_TYPE traversal:**
- Agent needs to construct a practice problem after identifying a weak concept
- Agent wants to find which problem types *test* a given concept (to give
  relevant practice, not random exercises)
- After mastery recovery: pick a problem type that exercises the recovered
  concept in combination with already-mastered concepts

---

### 2.8 `EXTENDS`
**Direction:** `(A)-[:EXTENDS]->(B)` — A is an advanced/deeper treatment of B  
**Semantics:** Softer than REQUIRES. A student can understand B without knowing A,
but A gives a deeper or more powerful perspective on B. Used for the
self-improving curriculum: when a student has fully mastered B, the agent
proactively suggests A to deepen understanding.

**Examples:**
```
gauss_law_applications  →  gauss_law               (applications extend the law itself)
induced_electric_field  →  faradays_law            (field form is deeper than EMF form)
maxwell_equations       →  amperes_law             (Maxwell's is the general form)
maxwell_equations       →  gauss_law               (one of the four)
poynting_vector         →  em_wave_energy_intensity (Poynting is the deep explanation)
complex_resistor_networks → kirchhoffs_laws        (complex networks extend basic KL)
akt_temporal_attention  →  lc_oscillations         (v2 research direction)
```

**When the agent fires EXTENDS traversal:**
- Student has mastered a concept (mastery > 0.85) and is showing curiosity
  (high engagement score in session behavioral data)
- Curriculum planner wants to proactively deepen, not just recover

---

## Part 3 — ProblemType Nodes (New Node Type)

Add a third node type to the schema:

```cypher
(:ProblemType {
  id:           'rod_on_rails',
  name:         'Conducting Rod on Rails in Magnetic Field',
  difficulty:   0.65,
  jee_frequency: 0.08,    // appears in ~8% of JEE EMI questions
  key_concepts: ['motional_emf', 'magnetic_force_on_wire', 'kirchhoffs_laws'],
  typical_traps: ['forgetting circuit resistance', 'wrong direction of induced current']
})
```

---

## Part 4 — Updated Neo4j Schema Summary

```cypher
// NODES
(:Concept  { id, name, chapter, difficulty, source, common_misconceptions })
(:Chapter  { id, name, subject, class, jee_weightage })
(:ProblemType { id, name, difficulty, jee_frequency, key_concepts, typical_traps })

// EDGES
(:Concept)-[:IS_PART_OF]->(:Chapter)
(:Concept)-[:REQUIRES]->(:Concept)
(:Concept)-[:COMMONLY_CONFUSED_WITH]->(:Concept)         // bidirectional in practice
(:Concept)-[:ANALOGY_OF { strength, domain }]->(:Concept)
(:Concept)-[:GENERALIZES]->(:Concept)
(:Concept)-[:USED_TOGETHER { frequency, problem_type }]->(:Concept)
(:Concept)-[:CONTRASTS_WITH { dimension }]->(:Concept)   // bidirectional
(:Concept)-[:APPEARS_IN_PROBLEM_TYPE]->(:ProblemType)
(:Concept)-[:EXTENDS]->(:Concept)

// STUDENT EDGES (per-student mastery)
(:Student)-[:HAS_MASTERY { score: 0.73, last_seen: datetime(), attempt_count: 12 }]->(:Concept)
```

---

## Part 5 — Error Classification Taxonomy

The Tutor Agent + KT model jointly classify student errors into these categories.
Each error type maps to exactly one primary graph traversal.

```
ERROR_TYPE_1: PREREQUISITE_GAP
ERROR_TYPE_2: CONFUSION_ERROR
ERROR_TYPE_3: SPECIAL_CASE_FIXATION
ERROR_TYPE_4: ANALOGICAL_TRANSFER_FAILURE
ERROR_TYPE_5: COORDINATION_FAILURE
ERROR_TYPE_6: DISCRIMINATION_FAILURE
ERROR_TYPE_7: PROBLEM_TYPE_UNFAMILIARITY
ERROR_TYPE_8: SURFACE_KNOWLEDGE (knows formula, not principle)
```

### How error types are detected:

| Error Type | Signal from KT Model | Signal from Behavioral Data |
|---|---|---|
| PREREQUISITE_GAP | mastery(A) low AND mastery(req B of A) low | Gets stuck at foundational step |
| CONFUSION_ERROR | mastery(A) low BUT mastery(B) high, wrong answers on A match B's method | Consistent wrong substitution |
| SPECIAL_CASE_FIXATION | mastery(B=special) high, mastery(A=general) low | Solves standard form, fails variant |
| ANALOGICAL_TRANSFER_FAILURE | mastery(B) high, mastery(A) near zero despite A ANALOGY_OF B | No attempt transfer, treats as new topic |
| COORDINATION_FAILURE | mastery(A) > 0.7 AND mastery(B) > 0.7, fails problems with both | Long pause mid-problem, approach shift |
| DISCRIMINATION_FAILURE | alternates between A and B answers across similar problems | Variable accuracy on same concept type |
| PROBLEM_TYPE_UNFAMILIARITY | concept mastery decent, problem-type-specific accuracy low | "I knew the concept but not what to do" |
| SURFACE_KNOWLEDGE | high recall accuracy, very low transfer accuracy | Can recite formula, fails novel setup |

---

## Part 6 — Query Library (Cypher)

One query per error type. These are the functions exposed by `KnowledgeGraphPlugin`
to the Semantic Kernel tutor agent.

---

### Q1: `find_prerequisite_chain(student_id, concept_id, max_depth=4)`
**Fires on:** ERROR_TYPE_1 — PREREQUISITE_GAP  
**Returns:** All prerequisite concepts up to max_depth hops where student mastery < threshold

```cypher
MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(target:Concept {id: $concept_id})
MATCH path = (target)-[:REQUIRES*1..$max_depth]->(prereq:Concept)
OPTIONAL MATCH (s)-[pm:HAS_MASTERY]->(prereq)
WITH prereq,
     COALESCE(pm.score, 0.0) AS prereq_mastery,
     length(path) AS depth
WHERE prereq_mastery < 0.6
RETURN prereq.id,
       prereq.name,
       prereq.chapter,
       prereq.difficulty,
       prereq_mastery,
       depth,
       prereq.common_misconceptions
ORDER BY depth ASC, prereq_mastery ASC
LIMIT 8
```

**Agent action:** Teach the shallowest (depth=1) weak prerequisite first.
Do not expose the student to all gaps at once.

---

### Q2: `find_confusion_pair(student_id, concept_id)`
**Fires on:** ERROR_TYPE_2 — CONFUSION_ERROR  
**Returns:** The most likely concept being confused with the target, with discrimination hints

```cypher
MATCH (target:Concept {id: $concept_id})-[:COMMONLY_CONFUSED_WITH]-(confused:Concept)
OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(confused)
OPTIONAL MATCH (s)-[tm:HAS_MASTERY]->(target)
RETURN confused.id,
       confused.name,
       confused.chapter,
       COALESCE(m.score, 0.0)  AS confused_mastery,
       COALESCE(tm.score, 0.0) AS target_mastery,
       confused.common_misconceptions
ORDER BY confused_mastery DESC
LIMIT 3
```

**Agent action:** Surface the confused concept. Ask a discrimination question
that forces the student to articulate *why* they are different. Do not
just explain both — let the student reason first (Socratic).

---

### Q3: `find_general_principle(concept_id)`
**Fires on:** ERROR_TYPE_3 — SPECIAL_CASE_FIXATION  
**Returns:** The general concept(s) that the known concept is a special case of

```cypher
MATCH (general:Concept)-[:GENERALIZES]->(special:Concept {id: $concept_id})
OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(general)
RETURN general.id,
       general.name,
       general.chapter,
       general.difficulty,
       COALESCE(m.score, 0.0) AS general_mastery,
       general.common_misconceptions
ORDER BY general_mastery ASC
```

**Agent action:** *"You know the formula for [special case]. But the real
question is: why does that formula work? It comes from [general principle]."*
Then give a variant problem that cannot be solved with the special-case formula.

---

### Q4: `find_analogy_bridge(student_id, weak_concept_id)`
**Fires on:** ERROR_TYPE_4 — ANALOGICAL_TRANSFER_FAILURE  
**Returns:** An analogous concept the student already masters well, plus the mapping

```cypher
MATCH (weak:Concept {id: $weak_concept_id})-[r:ANALOGY_OF]->(bridge:Concept)
MATCH (s:Student {id: $student_id})-[bm:HAS_MASTERY]->(bridge)
WHERE bm.score > 0.7
OPTIONAL MATCH (s)-[wm:HAS_MASTERY]->(weak)
RETURN bridge.id,
       bridge.name,
       bridge.chapter,
       bm.score         AS bridge_mastery,
       COALESCE(wm.score, 0.0) AS weak_mastery,
       r.strength       AS analogy_strength,
       r.domain         AS analogy_domain
ORDER BY bm.score DESC, r.strength DESC
LIMIT 2
```

**Agent action:** *"Think of [bridge concept] that you already know well.
[Weak concept] follows exactly the same structure. Let me show you the
one-to-one mapping between them."* Then present the structural mapping
as a table, not as new explanation.

---

### Q5: `find_coordination_concepts(student_id, concept_id)`
**Fires on:** ERROR_TYPE_5 — COORDINATION_FAILURE  
**Returns:** All concepts that frequently co-appear with the given concept, where student masters each individually but hasn't practiced together

```cypher
MATCH (target:Concept {id: $concept_id})-[r:USED_TOGETHER]-(partner:Concept)
MATCH (s:Student {id: $student_id})-[pm:HAS_MASTERY]->(partner)
MATCH (s)-[tm:HAS_MASTERY]->(target)
WHERE pm.score > 0.65 AND tm.score > 0.65
RETURN partner.id,
       partner.name,
       partner.chapter,
       pm.score             AS partner_mastery,
       tm.score             AS target_mastery,
       r.frequency          AS co_occurrence_frequency,
       r.problem_type       AS problem_context
ORDER BY r.frequency DESC
LIMIT 5
```

**Agent action:** Identify the highest-frequency co-occurrence pair. Present
a problem that *requires* both. Don't re-explain either concept — explicitly
say: *"You know both of these. The trick is using them in the right sequence."*

---

### Q6: `find_discrimination_pair(student_id, concept_id)`
**Fires on:** ERROR_TYPE_6 — DISCRIMINATION_FAILURE  
**Returns:** CONTRASTS_WITH neighbors + the dimension of contrast

```cypher
MATCH (target:Concept {id: $concept_id})-[r:CONTRASTS_WITH]-(contrast:Concept)
OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(contrast)
RETURN contrast.id,
       contrast.name,
       contrast.chapter,
       r.dimension          AS contrast_dimension,
       COALESCE(m.score, 0.0) AS contrast_mastery
ORDER BY contrast_mastery ASC
```

**Agent action:** Present two scenarios side by side — one where target applies,
one where contrast applies. Ask: *"What is the single deciding factor that
tells you which one to use?"* Force explicit articulation.

---

### Q7: `find_problem_types_for_concept(concept_id, student_id)`
**Fires on:** ERROR_TYPE_7 — PROBLEM_TYPE_UNFAMILIARITY  
**Returns:** All JEE problem types that test this concept, sorted by frequency

```cypher
MATCH (target:Concept {id: $concept_id})-[:APPEARS_IN_PROBLEM_TYPE]->(pt:ProblemType)
RETURN pt.id,
       pt.name,
       pt.difficulty,
       pt.jee_frequency,
       pt.key_concepts,
       pt.typical_traps
ORDER BY pt.jee_frequency DESC
LIMIT 4
```

**Then pull co-concepts for context:**
```cypher
MATCH (target:Concept {id: $concept_id})-[:APPEARS_IN_PROBLEM_TYPE]->(pt:ProblemType)
MATCH (other:Concept)-[:APPEARS_IN_PROBLEM_TYPE]->(pt)
WHERE other.id <> $concept_id
OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(other)
RETURN other.id, other.name, COALESCE(m.score, 0.0) AS mastery, pt.id AS problem_type
ORDER BY pt.jee_frequency DESC, mastery ASC
LIMIT 10
```

**Agent action:** Pick the most frequent problem type. Present the problem type
template. If the co-concepts are also weak, note them — but focus on the
*pattern* of the problem type, not the individual concepts.

---

### Q8: `find_transfer_problems(student_id, concept_id)`
**Fires on:** ERROR_TYPE_8 — SURFACE_KNOWLEDGE  
**Returns:** Problem types where this concept appears in a non-standard role,
plus the GENERALIZES chain to find the deeper principle

```cypher
// Step 1: Find the general principle behind the concept
MATCH (general:Concept)-[:GENERALIZES]->(target:Concept {id: $concept_id})
OPTIONAL MATCH (s:Student {id: $student_id})-[gm:HAS_MASTERY]->(general)
WITH general, COALESCE(gm.score, 0.0) AS general_mastery
WHERE general_mastery < 0.7

// Step 2: Find problem types that test the general principle, not the special case
MATCH (general)-[:APPEARS_IN_PROBLEM_TYPE]->(hard_pt:ProblemType)
RETURN general.id        AS principle_id,
       general.name      AS principle_name,
       general_mastery,
       hard_pt.id        AS problem_type_id,
       hard_pt.name      AS problem_type_name,
       hard_pt.difficulty,
       hard_pt.typical_traps
ORDER BY hard_pt.difficulty ASC
LIMIT 3
```

**Agent action:** *"You can recall the formula. Let's check if you understand
*why* it works."* Present a problem where the formula doesn't directly apply
but the principle does. If they fail, pivot to the GENERALIZES concept.

---

### Q9: `get_viewport_with_rich_context(student_id, chapter, mastery_threshold=0.6)`
**Fires on:** Dashboard load / session start  
**Returns:** Full enriched subgraph for visualization — concepts, their
confusion pairs, and their problem types — for the current chapter

```cypher
// All weak concepts in chapter with their REQUIRES gaps
MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(c:Concept)
WHERE c.chapter = $chapter AND m.score < $mastery_threshold
MATCH path = (c)-[:REQUIRES*1..3]->(prereq:Concept)
OPTIONAL MATCH (s)-[pm:HAS_MASTERY]->(prereq)

// Also pull confusion neighbors for these concepts
OPTIONAL MATCH (c)-[:COMMONLY_CONFUSED_WITH]-(confused:Concept)

WITH c, prereq, relationships(path) AS req_edges,
     COALESCE(pm.score, 0.0) AS prereq_mastery,
     collect(DISTINCT confused.id) AS confusion_neighbors

RETURN c       AS weak_concept,
       m.score AS mastery,
       prereq,
       req_edges,
       prereq_mastery,
       confusion_neighbors
LIMIT 50
```

---

### Q10: `find_opportunity_concepts(student_id, chapter)`
**Fires on:** When student is performing well — looking for next challenge  
**Returns:** Concepts within reach via ANALOGY_OF or EXTENDS from currently mastered concepts

```cypher
MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(mastered:Concept)
WHERE m.score > 0.8

// Find concepts the student could learn next via analogy
MATCH (next:Concept)-[:ANALOGY_OF {strength: r_strength}]->(mastered)
  WHERE r_strength > 0.7
OPTIONAL MATCH (s)-[nm:HAS_MASTERY]->(next)
WITH next, COALESCE(nm.score, 0.0) AS next_mastery, mastered, r_strength
WHERE next_mastery < 0.5 AND next.chapter = $chapter

RETURN next.id,
       next.name,
       next.chapter,
       next.difficulty,
       next_mastery,
       mastered.id    AS bridge_from,
       r_strength     AS analogy_strength
ORDER BY r_strength DESC, next.difficulty ASC
LIMIT 5
```

---

## Part 7 — Semantic Kernel Plugin Interface

These queries translate into KnowledgeGraphPlugin functions. The agent
*reasons* about which function to call based on its error classification.

```python
# services/kg_plugin.py

class KnowledgeGraphPlugin:

    @kernel_function(description="""
        Call when student fails a concept due to missing foundational knowledge.
        Returns prerequisite concepts with low mastery, ordered by proximity.
        Error type: PREREQUISITE_GAP
    """)
    async def find_prerequisite_gaps(self, student_id: str, concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student applies a correct method for the WRONG concept.
        Systematic substitution errors. Returns the likely confused concept pair.
        Error type: CONFUSION_ERROR
    """)
    async def find_confusion_pair(self, student_id: str, concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student solves standard problems but fails variants.
        Returns the general principle the student is missing.
        Error type: SPECIAL_CASE_FIXATION
    """)
    async def find_general_principle(self, student_id: str, concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student has zero mastery on a concept but high mastery
        on an analogous concept in another chapter. Returns the bridge concept.
        Error type: ANALOGICAL_TRANSFER_FAILURE
    """)
    async def find_analogy_bridge(self, student_id: str, weak_concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student knows both concepts individually but fails combined problems.
        Returns co-occurring concepts and the problem types where they appear together.
        Error type: COORDINATION_FAILURE
    """)
    async def find_coordination_pair(self, student_id: str, concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student alternates between two answers for the same type of problem.
        Returns the contrasting concept and the discriminating dimension.
        Error type: DISCRIMINATION_FAILURE
    """)
    async def find_discrimination_pair(self, student_id: str, concept_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student knows the concept but doesn't know what kind of JEE
        problem tests it. Returns problem type templates for the concept.
        Error type: PROBLEM_TYPE_UNFAMILIARITY
    """)
    async def find_problem_types(self, concept_id: str, student_id: str) -> str:
        ...

    @kernel_function(description="""
        Call when student can recall formula but fails transfer problems.
        Returns the deeper general principle and harder problem types.
        Error type: SURFACE_KNOWLEDGE
    """)
    async def find_transfer_challenge(self, student_id: str, concept_id: str) -> str:
        ...
```

---

## Part 8 — Decision Logic for the Tutor Agent

The system prompt for the Tutor Agent should include this decision tree
so it can self-select the right query:

```
Observe the student's error. Classify it:

1. Did they get stuck without even attempting? → PREREQUISITE_GAP
   → call find_prerequisite_gaps()

2. Did they attempt but use the method for a DIFFERENT concept?
   (e.g., used capacitor formula on inductor) → CONFUSION_ERROR
   → call find_confusion_pair()

3. Did they solve the standard form but fail when one parameter changed? → SPECIAL_CASE_FIXATION
   → call find_general_principle()

4. Did they treat a concept as entirely new when an analogous one exists? → ANALOGICAL_TRANSFER_FAILURE
   → call find_analogy_bridge()

5. Did they solve A correctly and B correctly in separate problems,
   but fail a problem requiring both? → COORDINATION_FAILURE
   → call find_coordination_pair()

6. Did they get the same concept right sometimes and wrong other times,
   seemingly randomly? → DISCRIMINATION_FAILURE
   → call find_discrimination_pair()

7. Did they say "I know the concept but didn't know how to start the problem"? → PROBLEM_TYPE_UNFAMILIARITY
   → call find_problem_types()

8. Did they recite the formula correctly but fail to apply it to a new setup? → SURFACE_KNOWLEDGE
   → call find_transfer_challenge()
```

---

## Part 9 — Edge Type Count Estimates for Electrodynamics Domain

| Edge Type | Estimated count (electrodynamics KG) |
|---|---|
| REQUIRES | ~285 (already built) |
| COMMONLY_CONFUSED_WITH | ~40 pairs → ~80 directed edges |
| ANALOGY_OF | ~20 pairs (high-value, curated) |
| GENERALIZES | ~35 edges |
| USED_TOGETHER | ~60 pairs → ~120 directed edges |
| CONTRASTS_WITH | ~25 pairs → ~50 directed edges |
| APPEARS_IN_PROBLEM_TYPE | ~80 edges (10 problem types × ~8 concepts each) |
| EXTENDS | ~20 edges |
| IS_PART_OF | ~155 |
| **Total** | **~885 edges across 8 edge types** |

This is the density needed for the agent to have enough resolution
to distinguish error types. A sparse graph forces the agent to
default to re-teaching everything — the most inefficient strategy.

---

*Schema version: 2.0 — Extended edge taxonomy*
*Build order: REQUIRES → COMMONLY_CONFUSED_WITH → ANALOGY_OF → GENERALIZES → USED_TOGETHER → CONTRASTS_WITH → APPEARS_IN_PROBLEM_TYPE → EXTENDS*
