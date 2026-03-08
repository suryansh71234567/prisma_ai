// =============================================================================
// PRISMA AI — KNOWLEDGE GRAPH SEED SCRIPT
// Domain: Physics — Electrodynamics
// Covers: Electrostatics · Capacitors · Current Electricity ·
//         Magnetic Effects of Current · Magnetism & Matter ·
//         Electromagnetic Induction · Alternating Current ·
//         Electromagnetic Waves
//
// Schema:
//   (:Chapter)  — macro nodes (50–200 total across all subjects)
//   (:Concept)  — micro nodes (1,000–5,000 granular concepts)
//   [:IS_PART_OF]  — Concept → Chapter
//   [:REQUIRES]    — Concept → Concept (prerequisite dependency)
//
// Difficulty scale: 0.0 (trivial) → 1.0 (hardest JEE Advanced)
// Source: "expert_defined" for all nodes in this file
// Run with: neo4j-shell -file kg_seed_electrodynamics.cypher
//           OR paste into Neo4j Browser
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 0 — CONSTRAINTS & INDEXES
// Run once per database setup
// ─────────────────────────────────────────────────────────────────────────────

CREATE CONSTRAINT concept_id_unique IF NOT EXISTS
  FOR (c:Concept) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT chapter_id_unique IF NOT EXISTS
  FOR (ch:Chapter) REQUIRE ch.id IS UNIQUE;

CREATE INDEX concept_chapter_idx IF NOT EXISTS
  FOR (c:Concept) ON (c.chapter);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — CHAPTER NODES (Macro Layer)
// ─────────────────────────────────────────────────────────────────────────────

// ── Electrodynamics chapters (Class 12 Physics) ──────────────────────────────
MERGE (:Chapter {
  id: 'electrostatics',
  name: 'Electrostatics',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.07
});

MERGE (:Chapter {
  id: 'capacitors',
  name: 'Capacitors',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.05
});

MERGE (:Chapter {
  id: 'current_electricity',
  name: 'Current Electricity',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.06
});

MERGE (:Chapter {
  id: 'magnetic_effects_current',
  name: 'Magnetic Effects of Current',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.07
});

MERGE (:Chapter {
  id: 'magnetism_matter',
  name: 'Magnetism and Matter',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.03
});

MERGE (:Chapter {
  id: 'electromagnetic_induction',
  name: 'Electromagnetic Induction',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.07
});

MERGE (:Chapter {
  id: 'alternating_current',
  name: 'Alternating Current',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.05
});

MERGE (:Chapter {
  id: 'electromagnetic_waves',
  name: 'Electromagnetic Waves',
  subject: 'physics',
  class: 12,
  jee_weightage: 0.02
});

// ── Cross-subject prerequisite chapters ──────────────────────────────────────
MERGE (:Chapter {
  id: 'vectors_mathematics',
  name: 'Vectors',
  subject: 'mathematics',
  class: 11,
  jee_weightage: 0.04
});

MERGE (:Chapter {
  id: 'calculus',
  name: 'Calculus',
  subject: 'mathematics',
  class: 12,
  jee_weightage: 0.10
});

MERGE (:Chapter {
  id: 'mechanics_basics',
  name: 'Laws of Motion & Work-Energy',
  subject: 'physics',
  class: 11,
  jee_weightage: 0.08
});

MERGE (:Chapter {
  id: 'rotational_motion',
  name: 'Rotational Motion',
  subject: 'physics',
  class: 11,
  jee_weightage: 0.06
});

MERGE (:Chapter {
  id: 'oscillations',
  name: 'Oscillations and Simple Harmonic Motion',
  subject: 'physics',
  class: 11,
  jee_weightage: 0.05
});

MERGE (:Chapter {
  id: 'trigonometry',
  name: 'Trigonometry',
  subject: 'mathematics',
  class: 11,
  jee_weightage: 0.04
});


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — CROSS-SUBJECT PREREQUISITE CONCEPTS
// These nodes exist in other chapters but are required by electrodynamics.
// Do NOT duplicate them if those chapters are also seeded — use MERGE.
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'vectors_basics'})
  ON CREATE SET
    c.name = 'Vector Quantities and Basic Operations',
    c.chapter = 'vectors_mathematics',
    c.difficulty = 0.2,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing vector addition with scalar addition',
      'forgetting direction when stating results'];

MERGE (c:Concept {id: 'vectors_dot_product'})
  ON CREATE SET
    c.name = 'Dot Product (Scalar Product)',
    c.chapter = 'vectors_mathematics',
    c.difficulty = 0.25,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting cosθ gives scalar result',
      'confusing with cross product'];

MERGE (c:Concept {id: 'vectors_cross_product'})
  ON CREATE SET
    c.name = 'Cross Product (Vector Product)',
    c.chapter = 'vectors_mathematics',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['direction error using right-hand rule',
      'treating result as scalar'];

MERGE (c:Concept {id: 'calculus_derivatives'})
  ON CREATE SET
    c.name = 'Differentiation and Derivatives',
    c.chapter = 'calculus',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'calculus_integration'})
  ON CREATE SET
    c.name = 'Definite and Indefinite Integration',
    c.chapter = 'calculus',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'calculus_line_integral'})
  ON CREATE SET
    c.name = 'Line Integral of a Vector Field',
    c.chapter = 'calculus',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not accounting for path direction',
      'using scalar integral formula for vector fields'];

MERGE (c:Concept {id: 'exponential_functions'})
  ON CREATE SET
    c.name = 'Exponential Functions and Natural Logarithm',
    c.chapter = 'calculus',
    c.difficulty = 0.25,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'trigonometry_basics'})
  ON CREATE SET
    c.name = 'Trigonometric Functions and Identities',
    c.chapter = 'trigonometry',
    c.difficulty = 0.2,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'newtons_laws'})
  ON CREATE SET
    c.name = "Newton's Laws of Motion",
    c.chapter = 'mechanics_basics',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'work_energy_theorem'})
  ON CREATE SET
    c.name = 'Work-Energy Theorem and Conservative Forces',
    c.chapter = 'mechanics_basics',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying only to kinetic energy changes',
      'ignoring potential energy in conservative systems'];

MERGE (c:Concept {id: 'energy_conservation'})
  ON CREATE SET
    c.name = 'Conservation of Energy',
    c.chapter = 'mechanics_basics',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'circular_motion'})
  ON CREATE SET
    c.name = 'Uniform Circular Motion',
    c.chapter = 'mechanics_basics',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'torque_mechanics'})
  ON CREATE SET
    c.name = 'Torque and Angular Momentum',
    c.chapter = 'rotational_motion',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'simple_harmonic_motion'})
  ON CREATE SET
    c.name = 'Simple Harmonic Motion',
    c.chapter = 'oscillations',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing frequency and angular frequency',
      'not distinguishing between amplitude and displacement'];

MERGE (c:Concept {id: 'phasors'})
  ON CREATE SET
    c.name = 'Phasors and Phase Angle Representation',
    c.chapter = 'alternating_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['treating phasor magnitude as instantaneous value',
      'confusing phase lead and phase lag'];

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — ELECTROSTATICS CONCEPTS
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'electric_charge'})
  ON CREATE SET
    c.name = 'Electric Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.1,
    c.source = 'expert_defined',
    c.common_misconceptions = ['treating charge as continuous when quantization matters'];

MERGE (c:Concept {id: 'charge_quantization'})
  ON CREATE SET
    c.name = 'Quantization of Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.15,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting Q = ne only for fundamental charges'];

MERGE (c:Concept {id: 'charge_conservation'})
  ON CREATE SET
    c.name = 'Conservation of Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.15,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'coulombs_law'})
  ON CREATE SET
    c.name = "Coulomb's Law",
    c.chapter = 'electrostatics',
    c.difficulty = 0.25,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting it applies only to point charges',
      'ignoring the 1/r² dependence vs 1/r²-style field'];

MERGE (c:Concept {id: 'superposition_principle_forces'})
  ON CREATE SET
    c.name = 'Superposition Principle for Electrostatic Forces',
    c.chapter = 'electrostatics',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['adding magnitudes instead of vectors'];

MERGE (c:Concept {id: 'electric_field_concept'})
  ON CREATE SET
    c.name = 'Electric Field — Concept and Definition',
    c.chapter = 'electrostatics',
    c.difficulty = 0.25,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing test charge with source charge',
      'thinking field depends on test charge magnitude'];

MERGE (c:Concept {id: 'electric_field_point_charge'})
  ON CREATE SET
    c.name = 'Electric Field due to Point Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'superposition_principle_fields'})
  ON CREATE SET
    c.name = 'Superposition Principle for Electric Fields',
    c.chapter = 'electrostatics',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['adding field magnitudes instead of vectors'];

MERGE (c:Concept {id: 'continuous_charge_distributions'})
  ON CREATE SET
    c.name = 'Continuous Charge Distributions (λ, σ, ρ)',
    c.chapter = 'electrostatics',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing linear, surface, and volume charge density units'];

MERGE (c:Concept {id: 'field_due_to_line_charge'})
  ON CREATE SET
    c.name = 'Electric Field due to Infinite Line Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting the 1/r dependence (not 1/r²)'];

MERGE (c:Concept {id: 'field_due_to_ring'})
  ON CREATE SET
    c.name = 'Electric Field due to Uniformly Charged Ring',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting the net transverse components cancel by symmetry'];

MERGE (c:Concept {id: 'field_due_to_disk'})
  ON CREATE SET
    c.name = 'Electric Field due to Uniformly Charged Disk',
    c.chapter = 'electrostatics',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'field_due_to_shell'})
  ON CREATE SET
    c.name = 'Electric Field due to Spherical Shell',
    c.chapter = 'electrostatics',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming nonzero field inside shell'];

MERGE (c:Concept {id: 'field_due_to_solid_sphere'})
  ON CREATE SET
    c.name = 'Electric Field due to Uniformly Charged Solid Sphere',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'electric_field_lines'})
  ON CREATE SET
    c.name = 'Electric Field Lines and Properties',
    c.chapter = 'electrostatics',
    c.difficulty = 0.2,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking field lines represent actual paths of charges',
      'crossing field lines'];

MERGE (c:Concept {id: 'electric_flux'})
  ON CREATE SET
    c.name = 'Electric Flux',
    c.chapter = 'electrostatics',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing flux with field strength',
      'ignoring the cosθ factor for tilted surfaces'];

MERGE (c:Concept {id: 'gauss_law'})
  ON CREATE SET
    c.name = "Gauss's Law",
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying to non-symmetric distributions',
      'confusing enclosed charge with charge on Gaussian surface'];

MERGE (c:Concept {id: 'gauss_law_applications'})
  ON CREATE SET
    c.name = "Applications of Gauss's Law",
    c.chapter = 'electrostatics',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['choosing wrong Gaussian surface shape',
      'including unenclosed charges in calculation'];

MERGE (c:Concept {id: 'electric_dipole'})
  ON CREATE SET
    c.name = 'Electric Dipole',
    c.chapter = 'electrostatics',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing direction of dipole moment (negative to positive)'];

MERGE (c:Concept {id: 'dipole_moment'})
  ON CREATE SET
    c.name = 'Electric Dipole Moment',
    c.chapter = 'electrostatics',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'field_due_to_dipole'})
  ON CREATE SET
    c.name = 'Electric Field due to Dipole (Axial and Equatorial)',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing axial and equatorial expressions',
      'forgetting that axial field is double the equatorial field'];

MERGE (c:Concept {id: 'dipole_in_uniform_field'})
  ON CREATE SET
    c.name = 'Dipole in Uniform External Electric Field',
    c.chapter = 'electrostatics',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['ignoring torque formula τ = p×E',
      'confusing stable and unstable equilibrium orientations'];

MERGE (c:Concept {id: 'electric_potential_energy'})
  ON CREATE SET
    c.name = 'Electric Potential Energy',
    c.chapter = 'electrostatics',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing PE of system with PE of individual charge',
      'ignoring sign of charges in calculation'];

MERGE (c:Concept {id: 'electric_potential'})
  ON CREATE SET
    c.name = 'Electric Potential',
    c.chapter = 'electrostatics',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing potential with potential energy',
      'thinking zero potential means zero field'];

MERGE (c:Concept {id: 'relation_E_and_V'})
  ON CREATE SET
    c.name = 'Relation Between Electric Field and Potential (E = -dV/dr)',
    c.chapter = 'electrostatics',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['ignoring the negative sign',
      'applying only along one axis in multi-dimensional problems'];

MERGE (c:Concept {id: 'equipotential_surfaces'})
  ON CREATE SET
    c.name = 'Equipotential Surfaces',
    c.chapter = 'electrostatics',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking field lines are parallel to equipotentials'];

MERGE (c:Concept {id: 'potential_due_to_point_charge'})
  ON CREATE SET
    c.name = 'Electric Potential due to Point Charge',
    c.chapter = 'electrostatics',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'potential_due_to_system'})
  ON CREATE SET
    c.name = 'Potential due to System of Charges',
    c.chapter = 'electrostatics',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['vector-adding scalar potentials'];

MERGE (c:Concept {id: 'potential_due_to_dipole'})
  ON CREATE SET
    c.name = 'Potential due to Electric Dipole',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'potential_due_to_shell'})
  ON CREATE SET
    c.name = 'Potential due to Spherical Shell (Inside, Outside)',
    c.chapter = 'electrostatics',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['treating inside potential as zero instead of constant'];

MERGE (c:Concept {id: 'conductors_electrostatics'})
  ON CREATE SET
    c.name = 'Conductors in Electrostatic Equilibrium',
    c.chapter = 'electrostatics',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming field is nonzero inside conductor',
      'not recognizing surface as equipotential'];

MERGE (c:Concept {id: 'induced_charges_conductors'})
  ON CREATE SET
    c.name = 'Induced Charges and Electrostatic Shielding',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking induced charges appear from nowhere'];

MERGE (c:Concept {id: 'charge_distribution_on_surface'})
  ON CREATE SET
    c.name = 'Charge Distribution on Conductor Surface',
    c.chapter = 'electrostatics',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming uniform distribution on irregular conductors'];

MERGE (c:Concept {id: 'electrostatic_pressure'})
  ON CREATE SET
    c.name = 'Electrostatic Pressure on Conductor Surface',
    c.chapter = 'electrostatics',
    c.difficulty = 0.65,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'dielectrics'})
  ON CREATE SET
    c.name = 'Dielectrics — Polar and Non-Polar',
    c.chapter = 'electrostatics',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking dielectrics conduct electricity'];

MERGE (c:Concept {id: 'polarization'})
  ON CREATE SET
    c.name = 'Polarization of Dielectrics',
    c.chapter = 'electrostatics',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'dielectric_constant'})
  ON CREATE SET
    c.name = 'Dielectric Constant (Relative Permittivity)',
    c.chapter = 'electrostatics',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing dielectric constant with dielectric strength'];

MERGE (c:Concept {id: 'bound_and_free_charges'})
  ON CREATE SET
    c.name = 'Bound Charges and Free Charges in Dielectrics',
    c.chapter = 'electrostatics',
    c.difficulty = 0.55,
    c.source = 'expert_defined';


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — CAPACITORS CONCEPTS
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'capacitance'})
  ON CREATE SET
    c.name = 'Capacitance — Definition and Units',
    c.chapter = 'capacitors',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking capacitance depends on charge or potential separately'];

MERGE (c:Concept {id: 'parallel_plate_capacitor'})
  ON CREATE SET
    c.name = 'Parallel Plate Capacitor',
    c.chapter = 'capacitors',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting C = ε₀A/d and that d matters linearly'];

MERGE (c:Concept {id: 'capacitor_with_dielectric'})
  ON CREATE SET
    c.name = 'Capacitor with Dielectric — Effect on C, V, Q, E',
    c.chapter = 'capacitors',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not distinguishing connected vs disconnected battery scenarios',
      'forgetting E reduces inside dielectric'];

MERGE (c:Concept {id: 'energy_stored_capacitor'})
  ON CREATE SET
    c.name = 'Energy Stored in a Capacitor',
    c.chapter = 'capacitors',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing U = ½QV, ½CV², Q²/2C — all equivalent'];

MERGE (c:Concept {id: 'energy_density_electric_field'})
  ON CREATE SET
    c.name = 'Energy Density of Electric Field (u = ½ε₀E²)',
    c.chapter = 'capacitors',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'capacitors_series'})
  ON CREATE SET
    c.name = 'Capacitors in Series',
    c.chapter = 'capacitors',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['using resistor series formula instead of 1/C_eff = Σ1/Cᵢ'];

MERGE (c:Concept {id: 'capacitors_parallel'})
  ON CREATE SET
    c.name = 'Capacitors in Parallel',
    c.chapter = 'capacitors',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'capacitors_networks'})
  ON CREATE SET
    c.name = 'Capacitor Networks and Circuit Reduction',
    c.chapter = 'capacitors',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong junction analysis', 'ignoring symmetry to simplify'];

MERGE (c:Concept {id: 'spherical_capacitor'})
  ON CREATE SET
    c.name = 'Spherical Capacitor',
    c.chapter = 'capacitors',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'cylindrical_capacitor'})
  ON CREATE SET
    c.name = 'Cylindrical Capacitor',
    c.chapter = 'capacitors',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'charge_sharing_capacitors'})
  ON CREATE SET
    c.name = 'Charge Sharing Between Capacitors',
    c.chapter = 'capacitors',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['energy is conserved during sharing — it is not'];

MERGE (c:Concept {id: 'rc_circuit_charging'})
  ON CREATE SET
    c.name = 'RC Circuit — Charging',
    c.chapter = 'capacitors',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing time constant τ with time to fully charge',
      'using linear instead of exponential equations'];

MERGE (c:Concept {id: 'rc_circuit_discharging'})
  ON CREATE SET
    c.name = 'RC Circuit — Discharging',
    c.chapter = 'capacitors',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'van_de_graaff_generator'})
  ON CREATE SET
    c.name = 'Van de Graaff Generator',
    c.chapter = 'capacitors',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'partial_dielectric_insertion'})
  ON CREATE SET
    c.name = 'Partially Filled Dielectric Capacitor (Slab and Layer)',
    c.chapter = 'capacitors',
    c.difficulty = 0.7,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not treating slab parallel vs series to field direction differently'];


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — CURRENT ELECTRICITY CONCEPTS
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'electric_current'})
  ON CREATE SET
    c.name = 'Electric Current — Definition',
    c.chapter = 'current_electricity',
    c.difficulty = 0.2,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'current_density'})
  ON CREATE SET
    c.name = 'Current Density (J)',
    c.chapter = 'current_electricity',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing current I and current density J'];

MERGE (c:Concept {id: 'drift_velocity'})
  ON CREATE SET
    c.name = 'Drift Velocity of Electrons',
    c.chapter = 'current_electricity',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing drift velocity with Fermi velocity',
      'thinking electrons move fast through wire'];

MERGE (c:Concept {id: 'ohms_law'})
  ON CREATE SET
    c.name = "Ohm's Law (V = IR)",
    c.chapter = 'current_electricity',
    c.difficulty = 0.2,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying to non-ohmic devices'];

MERGE (c:Concept {id: 'resistance_resistivity'})
  ON CREATE SET
    c.name = 'Resistance, Resistivity, and Conductivity',
    c.chapter = 'current_electricity',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing resistance and resistivity', 'R = ρL/A vs ρ'];

MERGE (c:Concept {id: 'temp_dependence_resistance'})
  ON CREATE SET
    c.name = 'Temperature Dependence of Resistance',
    c.chapter = 'current_electricity',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying metallic formula to semiconductors'];

MERGE (c:Concept {id: 'emf_internal_resistance'})
  ON CREATE SET
    c.name = 'EMF and Internal Resistance of a Cell',
    c.chapter = 'current_electricity',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing terminal voltage with EMF',
      'ignoring internal resistance in series'];

MERGE (c:Concept {id: 'kirchhoffs_current_law'})
  ON CREATE SET
    c.name = "Kirchhoff's Current Law (KCL)",
    c.chapter = 'current_electricity',
    c.difficulty = 0.35,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong sign convention at junction'];

MERGE (c:Concept {id: 'kirchhoffs_voltage_law'})
  ON CREATE SET
    c.name = "Kirchhoff's Voltage Law (KVL)",
    c.chapter = 'current_electricity',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['inconsistent loop direction', 'sign errors across EMF sources'];

MERGE (c:Concept {id: 'kirchhoffs_laws'})
  ON CREATE SET
    c.name = "Kirchhoff's Laws — Combined Application",
    c.chapter = 'current_electricity',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['insufficient equations for unknowns',
      'wrong sign in multi-loop circuit'];

MERGE (c:Concept {id: 'series_parallel_resistors'})
  ON CREATE SET
    c.name = 'Series and Parallel Combination of Resistors',
    c.chapter = 'current_electricity',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'complex_resistor_networks'})
  ON CREATE SET
    c.name = 'Complex Resistor Networks (Ladder, Infinite, Star-Delta)',
    c.chapter = 'current_electricity',
    c.difficulty = 0.75,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not using symmetry to reduce', 'wrong star-delta conversion'];

MERGE (c:Concept {id: 'wheatstone_bridge'})
  ON CREATE SET
    c.name = 'Wheatstone Bridge',
    c.chapter = 'current_electricity',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying balance condition when bridge is not balanced'];

MERGE (c:Concept {id: 'meter_bridge'})
  ON CREATE SET
    c.name = 'Meter Bridge',
    c.chapter = 'current_electricity',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'potentiometer'})
  ON CREATE SET
    c.name = 'Potentiometer — EMF Comparison and Internal Resistance',
    c.chapter = 'current_electricity',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['treating potentiometer like a voltmeter'];

MERGE (c:Concept {id: 'electric_power'})
  ON CREATE SET
    c.name = 'Electric Power (P = VI = I²R = V²/R)',
    c.chapter = 'current_electricity',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['using wrong formula when R is fixed vs V is fixed'];

MERGE (c:Concept {id: 'joule_heating'})
  ON CREATE SET
    c.name = "Joule's Law of Heating",
    c.chapter = 'current_electricity',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'cells_series_parallel'})
  ON CREATE SET
    c.name = 'Cells in Series and Parallel',
    c.chapter = 'current_electricity',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming parallel cells always give more current than series'];

MERGE (c:Concept {id: 'electrical_instruments'})
  ON CREATE SET
    c.name = 'Electrical Measuring Instruments (Ammeter, Voltmeter)',
    c.chapter = 'current_electricity',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['using non-ideal instrument without correction'];


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — MAGNETIC EFFECTS OF CURRENT
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'magnetic_field_concept'})
  ON CREATE SET
    c.name = 'Magnetic Field — Concept and Units',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.25,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing B (flux density) with H (magnetic intensity)'];

MERGE (c:Concept {id: 'magnetic_force_moving_charge'})
  ON CREATE SET
    c.name = 'Magnetic Force on Moving Charge (F = qv×B)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting force is zero when v ∥ B',
      'wrong direction from right-hand rule'];

MERGE (c:Concept {id: 'lorentz_force'})
  ON CREATE SET
    c.name = 'Lorentz Force (F = q(E + v×B))',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['ignoring electric component in combined fields'];

MERGE (c:Concept {id: 'motion_in_magnetic_field'})
  ON CREATE SET
    c.name = 'Motion of Charged Particle in Uniform Magnetic Field',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting radius r = mv/qB', 'confusing helical and circular paths'];

MERGE (c:Concept {id: 'velocity_selector'})
  ON CREATE SET
    c.name = 'Velocity Selector (E and B Fields Combined)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'cyclotron'})
  ON CREATE SET
    c.name = 'Cyclotron — Working and Cyclotron Frequency',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking cyclotron frequency depends on velocity'];

MERGE (c:Concept {id: 'magnetic_force_on_wire'})
  ON CREATE SET
    c.name = 'Magnetic Force on Current-Carrying Conductor (F = IL×B)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['using scalar instead of vector form'];

MERGE (c:Concept {id: 'torque_on_current_loop'})
  ON CREATE SET
    c.name = 'Torque on a Current Loop in Magnetic Field (τ = NIAB sinθ)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing torque formula with force formula'];

MERGE (c:Concept {id: 'magnetic_dipole_moment_current'})
  ON CREATE SET
    c.name = 'Magnetic Dipole Moment of Current Loop (m = NIA)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.4,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'biot_savart_law'})
  ON CREATE SET
    c.name = 'Biot-Savart Law',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting the sin θ between dl and r̂',
      'wrong direction of dB from cross product'];

MERGE (c:Concept {id: 'field_straight_wire'})
  ON CREATE SET
    c.name = 'Magnetic Field due to Straight Current-Carrying Wire',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not using finite vs infinite wire formula correctly'];

MERGE (c:Concept {id: 'field_circular_loop'})
  ON CREATE SET
    c.name = 'Magnetic Field due to Circular Current Loop (at center)',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'field_axis_circular_loop'})
  ON CREATE SET
    c.name = 'Magnetic Field on Axis of Circular Current Loop',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'amperes_law'})
  ON CREATE SET
    c.name = "Ampere's Circuital Law",
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying to non-symmetric current distributions',
      'wrong choice of Amperian loop'];

MERGE (c:Concept {id: 'field_solenoid'})
  ON CREATE SET
    c.name = 'Magnetic Field inside Solenoid',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming field outside solenoid is nonzero for ideal solenoid'];

MERGE (c:Concept {id: 'field_toroid'})
  ON CREATE SET
    c.name = 'Magnetic Field inside Toroid',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['assuming uniform field outside toroid'];

MERGE (c:Concept {id: 'force_between_wires'})
  ON CREATE SET
    c.name = 'Force Between Two Parallel Current-Carrying Wires',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong direction of force for parallel vs anti-parallel currents'];

MERGE (c:Concept {id: 'moving_coil_galvanometer'})
  ON CREATE SET
    c.name = 'Moving Coil Galvanometer',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.4,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'ammeter_voltmeter'})
  ON CREATE SET
    c.name = 'Conversion of Galvanometer to Ammeter and Voltmeter',
    c.chapter = 'magnetic_effects_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing shunt (parallel) for ammeter vs multiplier (series) for voltmeter'];


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7 — MAGNETISM AND MATTER
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'bar_magnet'})
  ON CREATE SET
    c.name = 'Bar Magnet and Magnetic Poles',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.25,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking magnetic monopoles exist'];

MERGE (c:Concept {id: 'field_due_to_bar_magnet'})
  ON CREATE SET
    c.name = 'Magnetic Field due to Bar Magnet (Axial and Equatorial)',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing axial vs equatorial field direction'];

MERGE (c:Concept {id: 'magnetic_intensity_H'})
  ON CREATE SET
    c.name = 'Magnetic Intensity (H) and Relationship to B',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing B and H', 'ignoring material permeability'];

MERGE (c:Concept {id: 'magnetization'})
  ON CREATE SET
    c.name = 'Magnetization (M) of Materials',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'magnetic_susceptibility'})
  ON CREATE SET
    c.name = 'Magnetic Susceptibility (χ)',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'magnetic_permeability'})
  ON CREATE SET
    c.name = 'Magnetic Permeability (μ = μ₀μᵣ)',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'diamagnetism'})
  ON CREATE SET
    c.name = 'Diamagnetism',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing with paramagnetism'];

MERGE (c:Concept {id: 'paramagnetism'})
  ON CREATE SET
    c.name = 'Paramagnetism and Curie Law',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'ferromagnetism'})
  ON CREATE SET
    c.name = 'Ferromagnetism and Magnetic Domains',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'hysteresis'})
  ON CREATE SET
    c.name = 'Hysteresis Loop — Retentivity and Coercivity',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing soft and hard magnetic materials from hysteresis shape'];

MERGE (c:Concept {id: 'curie_temperature'})
  ON CREATE SET
    c.name = 'Curie Temperature',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.4,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'earths_magnetism'})
  ON CREATE SET
    c.name = "Earth's Magnetism",
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'magnetic_declination_inclination'})
  ON CREATE SET
    c.name = 'Magnetic Declination, Dip, and Horizontal Component',
    c.chapter = 'magnetism_matter',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing angle of declination and angle of dip'];


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8 — ELECTROMAGNETIC INDUCTION
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'magnetic_flux'})
  ON CREATE SET
    c.name = 'Magnetic Flux (Φ = B·A cosθ)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['ignoring angle between B and area vector'];

MERGE (c:Concept {id: 'faradays_law'})
  ON CREATE SET
    c.name = "Faraday's Law of Electromagnetic Induction",
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting the negative sign (Lenz\'s law connection)',
      'using |dΦ/dt| without direction'];

MERGE (c:Concept {id: 'lenzs_law'})
  ON CREATE SET
    c.name = "Lenz's Law",
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.45,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong direction of induced current'];

MERGE (c:Concept {id: 'motional_emf'})
  ON CREATE SET
    c.name = 'Motional EMF (ε = BLv)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying formula when wire is not perpendicular to B',
      'forgetting to identify effective length'];

MERGE (c:Concept {id: 'motional_emf_rotating'})
  ON CREATE SET
    c.name = 'Motional EMF in Rotating Conductor',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong integration limits for rotating rod'];

MERGE (c:Concept {id: 'induced_electric_field'})
  ON CREATE SET
    c.name = 'Induced Electric Field from Changing Magnetic Flux',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking induced E requires conductor to exist'];

MERGE (c:Concept {id: 'self_inductance'})
  ON CREATE SET
    c.name = 'Self Inductance (L)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing L with mutual inductance M'];

MERGE (c:Concept {id: 'self_inductance_solenoid'})
  ON CREATE SET
    c.name = 'Self Inductance of Solenoid (L = μ₀n²Al)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'mutual_inductance'})
  ON CREATE SET
    c.name = 'Mutual Inductance (M)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking M is always symmetric — it is (M₁₂ = M₂₁)'];

MERGE (c:Concept {id: 'mutual_inductance_coils'})
  ON CREATE SET
    c.name = 'Mutual Inductance of Coaxial Coils and Solenoids',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.65,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'energy_stored_inductor'})
  ON CREATE SET
    c.name = 'Energy Stored in Inductor (U = ½LI²)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'energy_density_magnetic_field'})
  ON CREATE SET
    c.name = 'Energy Density of Magnetic Field (u = B²/2μ₀)',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'lc_oscillations'})
  ON CREATE SET
    c.name = 'LC Oscillations and Analogy with SHM',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.7,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not identifying energy exchange analogy correctly',
      'wrong formula for angular frequency ω = 1/√(LC)'];

MERGE (c:Concept {id: 'rl_circuits'})
  ON CREATE SET
    c.name = 'RL Circuit — Current Growth and Decay',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing time constant τ = L/R with τ = RC'];

MERGE (c:Concept {id: 'eddy_currents'})
  ON CREATE SET
    c.name = 'Eddy Currents — Cause, Effects, and Uses',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.4,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'ac_generator'})
  ON CREATE SET
    c.name = 'AC Generator — Principle and EMF Expression',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.5,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'transformer'})
  ON CREATE SET
    c.name = 'Transformer — Step-up, Step-down, Efficiency',
    c.chapter = 'electromagnetic_induction',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking ideal transformer conserves current not power'];


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 9 — ALTERNATING CURRENT
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'ac_basics'})
  ON CREATE SET
    c.name = 'Alternating Current — Waveform and Representation',
    c.chapter = 'alternating_current',
    c.difficulty = 0.3,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'rms_values'})
  ON CREATE SET
    c.name = 'RMS and Peak Values of AC',
    c.chapter = 'alternating_current',
    c.difficulty = 0.4,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing Vrms = V₀/√2 with Vavg = 2V₀/π'];

MERGE (c:Concept {id: 'ac_through_resistor'})
  ON CREATE SET
    c.name = 'AC Through Pure Resistor',
    c.chapter = 'alternating_current',
    c.difficulty = 0.35,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'ac_through_capacitor'})
  ON CREATE SET
    c.name = 'AC Through Pure Capacitor — Capacitive Reactance',
    c.chapter = 'alternating_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting 90° phase lead of current over voltage'];

MERGE (c:Concept {id: 'capacitive_reactance'})
  ON CREATE SET
    c.name = 'Capacitive Reactance (Xc = 1/ωC)',
    c.chapter = 'alternating_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'ac_through_inductor'})
  ON CREATE SET
    c.name = 'AC Through Pure Inductor — Inductive Reactance',
    c.chapter = 'alternating_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['forgetting 90° phase lag of current behind voltage'];

MERGE (c:Concept {id: 'inductive_reactance'})
  ON CREATE SET
    c.name = 'Inductive Reactance (XL = ωL)',
    c.chapter = 'alternating_current',
    c.difficulty = 0.45,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'series_rlc_circuit'})
  ON CREATE SET
    c.name = 'Series RLC Circuit',
    c.chapter = 'alternating_current',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['adding V_R, V_L, V_C as scalars instead of phasors',
      'wrong impedance formula'];

MERGE (c:Concept {id: 'impedance'})
  ON CREATE SET
    c.name = 'Impedance (Z = √(R² + (XL-XC)²))',
    c.chapter = 'alternating_current',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'resonance_rlc'})
  ON CREATE SET
    c.name = 'Resonance in RLC Circuit',
    c.chapter = 'alternating_current',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing series resonance (I max) with parallel resonance (I min)',
      'forgetting ω₀ = 1/√(LC)'];

MERGE (c:Concept {id: 'quality_factor'})
  ON CREATE SET
    c.name = 'Quality Factor (Q-factor) of RLC Circuit',
    c.chapter = 'alternating_current',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing Q-factor definition with bandwidth'];

MERGE (c:Concept {id: 'power_ac_circuits'})
  ON CREATE SET
    c.name = 'Power in AC Circuits',
    c.chapter = 'alternating_current',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['using V*I for AC without power factor'];

MERGE (c:Concept {id: 'power_factor'})
  ON CREATE SET
    c.name = 'Power Factor (cos φ)',
    c.chapter = 'alternating_current',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking pure reactive circuits consume power'];

MERGE (c:Concept {id: 'wattless_current'})
  ON CREATE SET
    c.name = 'Wattless Current (Reactive Component)',
    c.chapter = 'alternating_current',
    c.difficulty = 0.6,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'parallel_rlc_circuit'})
  ON CREATE SET
    c.name = 'Parallel RLC Circuit and Resonance',
    c.chapter = 'alternating_current',
    c.difficulty = 0.7,
    c.source = 'expert_defined',
    c.common_misconceptions = ['applying series resonance formula to parallel circuit'];

MERGE (c:Concept {id: 'choke_coil'})
  ON CREATE SET
    c.name = 'Choke Coil vs Resistance (Power Loss Comparison)',
    c.chapter = 'alternating_current',
    c.difficulty = 0.5,
    c.source = 'expert_defined';


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 10 — ELECTROMAGNETIC WAVES
// ─────────────────────────────────────────────────────────────────────────────

MERGE (c:Concept {id: 'displacement_current'})
  ON CREATE SET
    c.name = "Displacement Current (Maxwell's Correction to Ampere's Law)",
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.6,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking displacement current requires actual charge flow',
      'not applying in capacitor gap region'];

MERGE (c:Concept {id: 'maxwell_equations'})
  ON CREATE SET
    c.name = "Maxwell's Equations — Conceptual Overview",
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.7,
    c.source = 'expert_defined',
    c.common_misconceptions = ['not knowing which law each equation represents'];

MERGE (c:Concept {id: 'electromagnetic_waves'})
  ON CREATE SET
    c.name = 'Electromagnetic Waves — Production and Propagation',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.55,
    c.source = 'expert_defined',
    c.common_misconceptions = ['thinking EM waves need medium to propagate'];

MERGE (c:Concept {id: 'em_wave_properties'})
  ON CREATE SET
    c.name = 'Properties of EM Waves (Transverse, Speed, E⊥B)',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.5,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing direction of E, B, and propagation'];

MERGE (c:Concept {id: 'speed_of_light'})
  ON CREATE SET
    c.name = 'Speed of Light and c = 1/√(μ₀ε₀)',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.4,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'em_spectrum'})
  ON CREATE SET
    c.name = 'Electromagnetic Spectrum',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.3,
    c.source = 'expert_defined',
    c.common_misconceptions = ['wrong frequency ordering of spectrum bands'];

MERGE (c:Concept {id: 'em_wave_energy_intensity'})
  ON CREATE SET
    c.name = 'Energy and Intensity of EM Waves',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.55,
    c.source = 'expert_defined';

MERGE (c:Concept {id: 'poynting_vector'})
  ON CREATE SET
    c.name = 'Poynting Vector (S = E×H)',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.65,
    c.source = 'expert_defined',
    c.common_misconceptions = ['confusing time-averaged Poynting vector with instantaneous'];

MERGE (c:Concept {id: 'radiation_pressure'})
  ON CREATE SET
    c.name = 'Radiation Pressure of EM Waves',
    c.chapter = 'electromagnetic_waves',
    c.difficulty = 0.6,
    c.source = 'expert_defined';


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 11 — IS_PART_OF EDGES
// Linking every Concept to its Chapter
// ─────────────────────────────────────────────────────────────────────────────

// Cross-subject concepts
MATCH (c:Concept {id: 'vectors_basics'}), (ch:Chapter {id: 'vectors_mathematics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'vectors_dot_product'}), (ch:Chapter {id: 'vectors_mathematics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'vectors_cross_product'}), (ch:Chapter {id: 'vectors_mathematics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'calculus_derivatives'}), (ch:Chapter {id: 'calculus'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'calculus_integration'}), (ch:Chapter {id: 'calculus'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'calculus_line_integral'}), (ch:Chapter {id: 'calculus'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'exponential_functions'}), (ch:Chapter {id: 'calculus'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'trigonometry_basics'}), (ch:Chapter {id: 'trigonometry'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'newtons_laws'}), (ch:Chapter {id: 'mechanics_basics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'work_energy_theorem'}), (ch:Chapter {id: 'mechanics_basics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'energy_conservation'}), (ch:Chapter {id: 'mechanics_basics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'circular_motion'}), (ch:Chapter {id: 'mechanics_basics'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'torque_mechanics'}), (ch:Chapter {id: 'rotational_motion'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'simple_harmonic_motion'}), (ch:Chapter {id: 'oscillations'}) MERGE (c)-[:IS_PART_OF]->(ch);
MATCH (c:Concept {id: 'phasors'}), (ch:Chapter {id: 'alternating_current'}) MERGE (c)-[:IS_PART_OF]->(ch);

// Electrostatics
MATCH (c:Concept) WHERE c.chapter = 'electrostatics'
MATCH (ch:Chapter {id: 'electrostatics'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Capacitors
MATCH (c:Concept) WHERE c.chapter = 'capacitors'
MATCH (ch:Chapter {id: 'capacitors'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Current Electricity
MATCH (c:Concept) WHERE c.chapter = 'current_electricity'
MATCH (ch:Chapter {id: 'current_electricity'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Magnetic Effects
MATCH (c:Concept) WHERE c.chapter = 'magnetic_effects_current'
MATCH (ch:Chapter {id: 'magnetic_effects_current'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Magnetism and Matter
MATCH (c:Concept) WHERE c.chapter = 'magnetism_matter'
MATCH (ch:Chapter {id: 'magnetism_matter'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Electromagnetic Induction
MATCH (c:Concept) WHERE c.chapter = 'electromagnetic_induction'
MATCH (ch:Chapter {id: 'electromagnetic_induction'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Alternating Current
MATCH (c:Concept) WHERE c.chapter = 'alternating_current'
MATCH (ch:Chapter {id: 'alternating_current'})
MERGE (c)-[:IS_PART_OF]->(ch);

// Electromagnetic Waves
MATCH (c:Concept) WHERE c.chapter = 'electromagnetic_waves'
MATCH (ch:Chapter {id: 'electromagnetic_waves'})
MERGE (c)-[:IS_PART_OF]->(ch);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 12 — REQUIRES EDGES (Prerequisite Graph)
// Format: (A)-[:REQUIRES]->(B)  means "A requires B to be understood first"
// ─────────────────────────────────────────────────────────────────────────────

// ── Internal prerequisites: Vectors ──────────────────────────────────────────
MATCH (a:Concept {id:'vectors_dot_product'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'vectors_cross_product'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'calculus_integration'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'calculus_line_integral'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'calculus_line_integral'}), (b:Concept {id:'vectors_dot_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'work_energy_theorem'}), (b:Concept {id:'newtons_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_conservation'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'circular_motion'}), (b:Concept {id:'newtons_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'torque_mechanics'}), (b:Concept {id:'newtons_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'torque_mechanics'}), (b:Concept {id:'vectors_cross_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'phasors'}), (b:Concept {id:'trigonometry_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'phasors'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);

// ── ELECTROSTATICS prerequisites ─────────────────────────────────────────────
MATCH (a:Concept {id:'charge_quantization'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'charge_conservation'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'coulombs_law'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'coulombs_law'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'superposition_principle_forces'}), (b:Concept {id:'coulombs_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'superposition_principle_forces'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_field_concept'}), (b:Concept {id:'coulombs_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_field_point_charge'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_field_point_charge'}), (b:Concept {id:'coulombs_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'superposition_principle_fields'}), (b:Concept {id:'electric_field_point_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'superposition_principle_fields'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'continuous_charge_distributions'}), (b:Concept {id:'superposition_principle_fields'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'continuous_charge_distributions'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_line_charge'}), (b:Concept {id:'continuous_charge_distributions'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_ring'}), (b:Concept {id:'continuous_charge_distributions'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_disk'}), (b:Concept {id:'field_due_to_ring'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_shell'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_solid_sphere'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_solid_sphere'}), (b:Concept {id:'continuous_charge_distributions'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_field_lines'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_flux'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_flux'}), (b:Concept {id:'vectors_dot_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'gauss_law'}), (b:Concept {id:'electric_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'gauss_law'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_dipole'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_dipole'}), (b:Concept {id:'vectors_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dipole_moment'}), (b:Concept {id:'electric_dipole'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_dipole'}), (b:Concept {id:'dipole_moment'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_dipole'}), (b:Concept {id:'superposition_principle_fields'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dipole_in_uniform_field'}), (b:Concept {id:'dipole_moment'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dipole_in_uniform_field'}), (b:Concept {id:'torque_mechanics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_potential_energy'}), (b:Concept {id:'coulombs_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_potential_energy'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'electric_potential_energy'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'relation_E_and_V'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'relation_E_and_V'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'relation_E_and_V'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'equipotential_surfaces'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_point_charge'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_system'}), (b:Concept {id:'potential_due_to_point_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_dipole'}), (b:Concept {id:'potential_due_to_point_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_dipole'}), (b:Concept {id:'electric_dipole'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_shell'}), (b:Concept {id:'potential_due_to_point_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potential_due_to_shell'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'conductors_electrostatics'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'conductors_electrostatics'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'induced_charges_conductors'}), (b:Concept {id:'conductors_electrostatics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'induced_charges_conductors'}), (b:Concept {id:'electric_dipole'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'charge_distribution_on_surface'}), (b:Concept {id:'conductors_electrostatics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'charge_distribution_on_surface'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electrostatic_pressure'}), (b:Concept {id:'charge_distribution_on_surface'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electrostatic_pressure'}), (b:Concept {id:'energy_density_electric_field'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dielectrics'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dielectrics'}), (b:Concept {id:'electric_dipole'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'polarization'}), (b:Concept {id:'dielectrics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'dielectric_constant'}), (b:Concept {id:'polarization'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'bound_and_free_charges'}), (b:Concept {id:'polarization'}) MERGE (a)-[:REQUIRES]->(b);

// ── CAPACITORS prerequisites ──────────────────────────────────────────────────
MATCH (a:Concept {id:'capacitance'}), (b:Concept {id:'conductors_electrostatics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitance'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'parallel_plate_capacitor'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'parallel_plate_capacitor'}), (b:Concept {id:'gauss_law_applications'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitor_with_dielectric'}), (b:Concept {id:'parallel_plate_capacitor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitor_with_dielectric'}), (b:Concept {id:'dielectric_constant'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_stored_capacitor'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_stored_capacitor'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_density_electric_field'}), (b:Concept {id:'energy_stored_capacitor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_density_electric_field'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitors_series'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitors_parallel'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitors_networks'}), (b:Concept {id:'capacitors_series'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitors_networks'}), (b:Concept {id:'capacitors_parallel'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitors_networks'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'spherical_capacitor'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'spherical_capacitor'}), (b:Concept {id:'potential_due_to_point_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cylindrical_capacitor'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cylindrical_capacitor'}), (b:Concept {id:'field_due_to_line_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'charge_sharing_capacitors'}), (b:Concept {id:'capacitors_parallel'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'charge_sharing_capacitors'}), (b:Concept {id:'energy_stored_capacitor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'exponential_functions'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rc_circuit_discharging'}), (b:Concept {id:'rc_circuit_charging'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'partial_dielectric_insertion'}), (b:Concept {id:'capacitor_with_dielectric'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'partial_dielectric_insertion'}), (b:Concept {id:'capacitors_series'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'van_de_graaff_generator'}), (b:Concept {id:'charge_distribution_on_surface'}) MERGE (a)-[:REQUIRES]->(b);

// ── CURRENT ELECTRICITY prerequisites ────────────────────────────────────────
MATCH (a:Concept {id:'electric_current'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'current_density'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'drift_velocity'}), (b:Concept {id:'current_density'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'drift_velocity'}), (b:Concept {id:'newtons_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ohms_law'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ohms_law'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'resistance_resistivity'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'temp_dependence_resistance'}), (b:Concept {id:'resistance_resistivity'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_current_law'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_current_law'}), (b:Concept {id:'charge_conservation'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_voltage_law'}), (b:Concept {id:'electric_potential'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_voltage_law'}), (b:Concept {id:'emf_internal_resistance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_laws'}), (b:Concept {id:'kirchhoffs_current_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'kirchhoffs_laws'}), (b:Concept {id:'kirchhoffs_voltage_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_parallel_resistors'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_parallel_resistors'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'complex_resistor_networks'}), (b:Concept {id:'series_parallel_resistors'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'complex_resistor_networks'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'wheatstone_bridge'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'wheatstone_bridge'}), (b:Concept {id:'series_parallel_resistors'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'meter_bridge'}), (b:Concept {id:'wheatstone_bridge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potentiometer'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'potentiometer'}), (b:Concept {id:'emf_internal_resistance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_power'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electric_power'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'joule_heating'}), (b:Concept {id:'electric_power'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cells_series_parallel'}), (b:Concept {id:'emf_internal_resistance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cells_series_parallel'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electrical_instruments'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electrical_instruments'}), (b:Concept {id:'series_parallel_resistors'}) MERGE (a)-[:REQUIRES]->(b);

// ── MAGNETIC EFFECTS prerequisites ───────────────────────────────────────────
MATCH (a:Concept {id:'magnetic_force_moving_charge'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_force_moving_charge'}), (b:Concept {id:'electric_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_force_moving_charge'}), (b:Concept {id:'vectors_cross_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lorentz_force'}), (b:Concept {id:'magnetic_force_moving_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lorentz_force'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motion_in_magnetic_field'}), (b:Concept {id:'lorentz_force'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motion_in_magnetic_field'}), (b:Concept {id:'newtons_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motion_in_magnetic_field'}), (b:Concept {id:'circular_motion'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'velocity_selector'}), (b:Concept {id:'lorentz_force'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cyclotron'}), (b:Concept {id:'motion_in_magnetic_field'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'cyclotron'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_force_on_wire'}), (b:Concept {id:'magnetic_force_moving_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_force_on_wire'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'torque_on_current_loop'}), (b:Concept {id:'magnetic_force_on_wire'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'torque_on_current_loop'}), (b:Concept {id:'torque_mechanics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_dipole_moment_current'}), (b:Concept {id:'torque_on_current_loop'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'vectors_cross_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_straight_wire'}), (b:Concept {id:'biot_savart_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_circular_loop'}), (b:Concept {id:'biot_savart_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_axis_circular_loop'}), (b:Concept {id:'field_circular_loop'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'calculus_line_integral'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_solenoid'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_toroid'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'force_between_wires'}), (b:Concept {id:'field_straight_wire'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'force_between_wires'}), (b:Concept {id:'magnetic_force_on_wire'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'moving_coil_galvanometer'}), (b:Concept {id:'torque_on_current_loop'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ammeter_voltmeter'}), (b:Concept {id:'moving_coil_galvanometer'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ammeter_voltmeter'}), (b:Concept {id:'series_parallel_resistors'}) MERGE (a)-[:REQUIRES]->(b);

// ── MAGNETISM AND MATTER prerequisites ───────────────────────────────────────
MATCH (a:Concept {id:'field_due_to_bar_magnet'}), (b:Concept {id:'bar_magnet'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'field_due_to_bar_magnet'}), (b:Concept {id:'magnetic_dipole_moment_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_intensity_H'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_intensity_H'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetization'}), (b:Concept {id:'magnetic_dipole_moment_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_susceptibility'}), (b:Concept {id:'magnetization'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_susceptibility'}), (b:Concept {id:'magnetic_intensity_H'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_permeability'}), (b:Concept {id:'magnetic_susceptibility'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'diamagnetism'}), (b:Concept {id:'magnetic_susceptibility'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'paramagnetism'}), (b:Concept {id:'magnetic_susceptibility'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'paramagnetism'}), (b:Concept {id:'magnetic_dipole_moment_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ferromagnetism'}), (b:Concept {id:'paramagnetism'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'hysteresis'}), (b:Concept {id:'ferromagnetism'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'curie_temperature'}), (b:Concept {id:'ferromagnetism'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'earths_magnetism'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_declination_inclination'}), (b:Concept {id:'earths_magnetism'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'bar_magnet'}), (b:Concept {id:'magnetic_dipole_moment_current'}) MERGE (a)-[:REQUIRES]->(b);

// ── ELECTROMAGNETIC INDUCTION prerequisites ───────────────────────────────────
MATCH (a:Concept {id:'magnetic_flux'}), (b:Concept {id:'magnetic_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'magnetic_flux'}), (b:Concept {id:'vectors_dot_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'faradays_law'}), (b:Concept {id:'magnetic_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'faradays_law'}), (b:Concept {id:'emf_internal_resistance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lenzs_law'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lenzs_law'}), (b:Concept {id:'energy_conservation'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'magnetic_force_moving_charge'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motional_emf_rotating'}), (b:Concept {id:'motional_emf'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'motional_emf_rotating'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'electric_field_concept'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'calculus_line_integral'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'self_inductance'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'self_inductance'}), (b:Concept {id:'magnetic_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'self_inductance_solenoid'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'self_inductance_solenoid'}), (b:Concept {id:'field_solenoid'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'mutual_inductance'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'mutual_inductance_coils'}), (b:Concept {id:'mutual_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'mutual_inductance_coils'}), (b:Concept {id:'field_circular_loop'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_stored_inductor'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_stored_inductor'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_density_magnetic_field'}), (b:Concept {id:'energy_stored_inductor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'energy_density_magnetic_field'}), (b:Concept {id:'field_solenoid'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'energy_stored_inductor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'energy_stored_capacitor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'simple_harmonic_motion'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rl_circuits'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rl_circuits'}), (b:Concept {id:'emf_internal_resistance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rl_circuits'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rl_circuits'}), (b:Concept {id:'exponential_functions'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'eddy_currents'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_generator'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_generator'}), (b:Concept {id:'magnetic_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'transformer'}), (b:Concept {id:'mutual_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'transformer'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);

// ── ALTERNATING CURRENT prerequisites ────────────────────────────────────────
MATCH (a:Concept {id:'ac_basics'}), (b:Concept {id:'electric_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_basics'}), (b:Concept {id:'simple_harmonic_motion'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_basics'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rms_values'}), (b:Concept {id:'ac_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rms_values'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_resistor'}), (b:Concept {id:'ac_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_resistor'}), (b:Concept {id:'ohms_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_capacitor'}), (b:Concept {id:'ac_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_capacitor'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'capacitive_reactance'}), (b:Concept {id:'ac_through_capacitor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_inductor'}), (b:Concept {id:'ac_basics'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'ac_through_inductor'}), (b:Concept {id:'self_inductance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'inductive_reactance'}), (b:Concept {id:'ac_through_inductor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'capacitive_reactance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'inductive_reactance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'ac_through_resistor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'phasors'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'impedance'}), (b:Concept {id:'series_rlc_circuit'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'series_rlc_circuit'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'lc_oscillations'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'quality_factor'}), (b:Concept {id:'resonance_rlc'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'power_ac_circuits'}), (b:Concept {id:'series_rlc_circuit'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'power_ac_circuits'}), (b:Concept {id:'rms_values'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'power_factor'}), (b:Concept {id:'power_ac_circuits'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'wattless_current'}), (b:Concept {id:'power_factor'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'parallel_rlc_circuit'}), (b:Concept {id:'series_rlc_circuit'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'parallel_rlc_circuit'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'choke_coil'}), (b:Concept {id:'inductive_reactance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'choke_coil'}), (b:Concept {id:'power_factor'}) MERGE (a)-[:REQUIRES]->(b);

// ── ELECTROMAGNETIC WAVES prerequisites ───────────────────────────────────────
MATCH (a:Concept {id:'displacement_current'}), (b:Concept {id:'capacitance'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'displacement_current'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'displacement_current'}), (b:Concept {id:'electric_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'displacement_current'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'displacement_current'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'electromagnetic_waves'}), (b:Concept {id:'maxwell_equations'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_wave_properties'}), (b:Concept {id:'electromagnetic_waves'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_wave_properties'}), (b:Concept {id:'vectors_cross_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'speed_of_light'}), (b:Concept {id:'electromagnetic_waves'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_spectrum'}), (b:Concept {id:'em_wave_properties'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_wave_energy_intensity'}), (b:Concept {id:'electromagnetic_waves'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_wave_energy_intensity'}), (b:Concept {id:'energy_density_electric_field'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'em_wave_energy_intensity'}), (b:Concept {id:'energy_density_magnetic_field'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'poynting_vector'}), (b:Concept {id:'em_wave_energy_intensity'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'poynting_vector'}), (b:Concept {id:'magnetic_intensity_H'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'radiation_pressure'}), (b:Concept {id:'em_wave_energy_intensity'}) MERGE (a)-[:REQUIRES]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 13 — CROSS-CHAPTER DEEP PREREQUISITE EDGES
// These are the "invisible" dependencies that cause cascading gaps.
// A student failing Chapter X may actually have a gap in Chapter Y from Class 11.
// These edges are the most strategically important for the Tutor Agent.
// ─────────────────────────────────────────────────────────────────────────────

// EMI ← Mechanics: Motional EMF fundamentally uses work-energy ideas
MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);

// Capacitors ← Electrostatics: the entire capacitor chapter depends on E-field foundations
MATCH (a:Concept {id:'capacitance'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:REQUIRES]->(b);

// Magnetic Force ← Vectors: this is the most common gap causing wrong direction answers
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'vectors_cross_product'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'vectors_dot_product'}) MERGE (a)-[:REQUIRES]->(b);

// LC oscillations deeply require SHM understanding — the analogy is non-trivial
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'simple_harmonic_motion'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'simple_harmonic_motion'}) MERGE (a)-[:REQUIRES]->(b);

// AC circuit phasor analysis requires trigonometry deeply
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'trigonometry_basics'}) MERGE (a)-[:REQUIRES]->(b);

// Potential and field relation requires calculus (missed by many students)
MATCH (a:Concept {id:'relation_E_and_V'}), (b:Concept {id:'calculus_integration'}) MERGE (a)-[:REQUIRES]->(b);

// Gauss's law application requires geometric intuition from vectors
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'vectors_dot_product'}) MERGE (a)-[:REQUIRES]->(b);

// Maxwell's equations: the final convergence of everything
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'electric_flux'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'magnetic_flux'}) MERGE (a)-[:REQUIRES]->(b);

// RC and RL circuit time constants — differential equation conceptual requirement
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);
MATCH (a:Concept {id:'rl_circuits'}), (b:Concept {id:'calculus_derivatives'}) MERGE (a)-[:REQUIRES]->(b);

// Cyclotron: uses conservation of energy (KE gain in electric field)
MATCH (a:Concept {id:'cyclotron'}), (b:Concept {id:'work_energy_theorem'}) MERGE (a)-[:REQUIRES]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// VERIFICATION QUERIES (run separately to check integrity)
// ─────────────────────────────────────────────────────────────────────────────
//
// Total concept count:
//   MATCH (c:Concept) RETURN count(c);
//
// Total REQUIRES edges:
//   MATCH ()-[r:REQUIRES]->() RETURN count(r);
//
// Concepts with no incoming REQUIRES (root concepts — should be few):
//   MATCH (c:Concept) WHERE NOT ()-[:REQUIRES]->(c) RETURN c.id, c.chapter ORDER BY c.chapter;
//
// Concepts with no outgoing REQUIRES (leaf concepts — should be the hardest ones):
//   MATCH (c:Concept) WHERE NOT (c)-[:REQUIRES]->() RETURN c.id, c.chapter ORDER BY c.difficulty DESC;
//
// Cross-chapter prerequisite edges (the most important for gap detection):
//   MATCH (a:Concept)-[r:REQUIRES]->(b:Concept)
//   WHERE a.chapter <> b.chapter
//   RETURN a.id, a.chapter, b.id, b.chapter
//   ORDER BY a.chapter;
//
// Viewport test (student with gap in 'capacitors', 3 hops):
//   MATCH (c:Concept {chapter: 'capacitors'})
//   MATCH path = (c)-[:REQUIRES*1..3]->(prereq:Concept)
//   RETURN c.id, prereq.id, prereq.chapter
//   ORDER BY length(path);
//
// ─────────────────────────────────────────────────────────────────────────────
// END OF SEED SCRIPT
// Total: 8 chapters + 6 prerequisite chapters
//        ~120 concept nodes
//        ~230+ REQUIRES edges (intra + cross-chapter)
// ─────────────────────────────────────────────────────────────────────────────
