// =============================================================================
// PRISMA AI — EXTENDED EDGE TYPE SEED SCRIPT
// Adds: COMMONLY_CONFUSED_WITH · ANALOGY_OF · GENERALIZES
//       USED_TOGETHER · CONTRASTS_WITH · APPEARS_IN_PROBLEM_TYPE · EXTENDS
// Run AFTER kg_seed_electrodynamics.cypher
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — ProblemType NODES
// ─────────────────────────────────────────────────────────────────────────────

MERGE (:ProblemType {
  id: 'rod_on_rails',
  name: 'Conducting Rod on Rails in Magnetic Field',
  difficulty: 0.65,
  jee_frequency: 0.08,
  key_concepts: ['motional_emf', 'magnetic_force_on_wire', 'kirchhoffs_laws', 'lenzs_law'],
  typical_traps: ['forgetting circuit resistance', 'wrong direction of induced current',
                  'not accounting for changing flux when rod accelerates']
});

MERGE (:ProblemType {
  id: 'charged_particle_fields',
  name: 'Charged Particle Motion in Combined E and B Fields',
  difficulty: 0.70,
  jee_frequency: 0.09,
  key_concepts: ['lorentz_force', 'motion_in_magnetic_field', 'velocity_selector', 'circular_motion'],
  typical_traps: ['wrong radius formula', 'forgetting helical path when v has component along B',
                  'sign of charge in direction of force']
});

MERGE (:ProblemType {
  id: 'capacitor_circuit',
  name: 'Capacitor Network with DC/AC Source',
  difficulty: 0.60,
  jee_frequency: 0.07,
  key_concepts: ['capacitors_networks', 'kirchhoffs_laws', 'capacitors_series', 'capacitors_parallel'],
  typical_traps: ['using resistor combination rules', 'steady-state vs transient confusion',
                  'charge on plates in asymmetric networks']
});

MERGE (:ProblemType {
  id: 'rc_transient',
  name: 'RC Circuit Transient (Charging/Discharging)',
  difficulty: 0.60,
  jee_frequency: 0.06,
  key_concepts: ['rc_circuit_charging', 'rc_circuit_discharging', 'exponential_functions', 'kirchhoffs_laws'],
  typical_traps: ['confusing τ=RC with half-life', 'initial conditions errors',
                  'superposition with initial charge on capacitor']
});

MERGE (:ProblemType {
  id: 'spherical_conductor_system',
  name: 'Concentric Spherical Conductors and Shells',
  difficulty: 0.65,
  jee_frequency: 0.06,
  key_concepts: ['conductors_electrostatics', 'gauss_law_applications', 'potential_due_to_shell',
                 'induced_charges_conductors'],
  typical_traps: ['wrong charge distribution after grounding', 'potential inside shell vs outside',
                  'net charge on inner surface of outer shell']
});

MERGE (:ProblemType {
  id: 'resonance_circuit',
  name: 'RLC Resonance and Power',
  difficulty: 0.65,
  jee_frequency: 0.07,
  key_concepts: ['series_rlc_circuit', 'resonance_rlc', 'quality_factor', 'power_factor'],
  typical_traps: ['series vs parallel resonance confusion', 'Q-factor formula variants',
                  'power at frequencies away from resonance']
});

MERGE (:ProblemType {
  id: 'infinite_resistor_network',
  name: 'Infinite or Symmetric Resistor Networks',
  difficulty: 0.80,
  jee_frequency: 0.04,
  key_concepts: ['complex_resistor_networks', 'kirchhoffs_laws', 'series_parallel_resistors'],
  typical_traps: ['not exploiting symmetry', 'wrong star-delta conversion', 'loop selection errors']
});

MERGE (:ProblemType {
  id: 'electromagnetic_energy',
  name: 'Energy in LC and RLC Systems',
  difficulty: 0.70,
  jee_frequency: 0.06,
  key_concepts: ['lc_oscillations', 'energy_stored_inductor', 'energy_stored_capacitor',
                 'energy_density_magnetic_field', 'energy_density_electric_field'],
  typical_traps: ['confusing energy at t=0 with max energy', 'energy at quarter-period in LC',
                  'total energy not conserved if R is present']
});

MERGE (:ProblemType {
  id: 'dipole_problems',
  name: 'Electric and Magnetic Dipole in External Field',
  difficulty: 0.60,
  jee_frequency: 0.05,
  key_concepts: ['electric_dipole', 'dipole_in_uniform_field', 'field_due_to_dipole',
                 'potential_due_to_dipole'],
  typical_traps: ['axial vs equatorial formula mix-up', 'torque direction', 'stable equilibrium angle']
});

MERGE (:ProblemType {
  id: 'electromagnetic_induction_combined',
  name: 'EMI with Self/Mutual Inductance and Energy',
  difficulty: 0.75,
  jee_frequency: 0.07,
  key_concepts: ['faradays_law', 'lenzs_law', 'self_inductance', 'mutual_inductance',
                 'energy_stored_inductor', 'rl_circuits'],
  typical_traps: ['sign of mutual EMF', 'direction of induced current in coupled coils',
                  'time constant in RL vs RC']
});


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — COMMONLY_CONFUSED_WITH EDGES
// These are the "error of commission" edges — student HAS knowledge, just misfiled
// ─────────────────────────────────────────────────────────────────────────────

// Electric field vs potential (most common confusion in electrostatics)
MATCH (a:Concept {id:'electric_field_concept'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'electric_field_concept'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Potential vs Potential energy
MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'electric_potential_energy'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'electric_potential_energy'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Resistance vs Resistivity
MATCH (a:Concept {id:'resistance_resistivity'}), (b:Concept {id:'current_density'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Gauss's law vs Coulomb's law (flux vs force)
MATCH (a:Concept {id:'gauss_law'}), (b:Concept {id:'coulombs_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'coulombs_law'}), (b:Concept {id:'gauss_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Dipole axial vs equatorial field
MATCH (a:Concept {id:'field_due_to_dipole'}), (b:Concept {id:'potential_due_to_dipole'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'potential_due_to_dipole'}), (b:Concept {id:'field_due_to_dipole'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Capacitive vs inductive reactance (opposite phase effects, often swapped)
MATCH (a:Concept {id:'capacitive_reactance'}), (b:Concept {id:'inductive_reactance'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'inductive_reactance'}), (b:Concept {id:'capacitive_reactance'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// RMS vs peak
MATCH (a:Concept {id:'rms_values'}), (b:Concept {id:'ac_basics'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Faraday's law vs Lenz's law (magnitude vs direction)
MATCH (a:Concept {id:'faradays_law'}), (b:Concept {id:'lenzs_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'lenzs_law'}), (b:Concept {id:'faradays_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Self inductance vs mutual inductance
MATCH (a:Concept {id:'self_inductance'}), (b:Concept {id:'mutual_inductance'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'mutual_inductance'}), (b:Concept {id:'self_inductance'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Biot-Savart vs Ampere's law (both give B, students use wrong one)
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'amperes_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'biot_savart_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Electric flux vs magnetic flux
MATCH (a:Concept {id:'electric_flux'}), (b:Concept {id:'magnetic_flux'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'magnetic_flux'}), (b:Concept {id:'electric_flux'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Impedance vs resistance
MATCH (a:Concept {id:'impedance'}), (b:Concept {id:'resistance_resistivity'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// EMF vs terminal voltage
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Magnetic force on wire vs Biot-Savart (both involve current, different phenomena)
MATCH (a:Concept {id:'magnetic_force_on_wire'}), (b:Concept {id:'biot_savart_law'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Torque on loop vs force on wire
MATCH (a:Concept {id:'torque_on_current_loop'}), (b:Concept {id:'magnetic_force_on_wire'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Motional EMF vs induced electric field (conductor presence vs not)
MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'induced_electric_field'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'motional_emf'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Diamagnetism vs paramagnetism
MATCH (a:Concept {id:'diamagnetism'}), (b:Concept {id:'paramagnetism'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);
MATCH (a:Concept {id:'paramagnetism'}), (b:Concept {id:'diamagnetism'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);

// Series resonance vs parallel resonance behavior
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'parallel_rlc_circuit'})
MERGE (a)-[:COMMONLY_CONFUSED_WITH]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — ANALOGY_OF EDGES
// Structural, mathematical, or physical analogies across chapters
// strength: 0.0–1.0 | domain: structural / mathematical / physical
// ─────────────────────────────────────────────────────────────────────────────

// The single strongest analogy in all of electrodynamics
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'simple_harmonic_motion'})
MERGE (a)-[:ANALOGY_OF {strength: 0.95, domain: 'mathematical',
  mapping: 'q↔x, L↔m, 1/C↔k, i↔v, ½Li²↔½mv², q²/2C↔½kx²'}]->(b);

// Gauss's law ↔ Ampere's law (both are integral laws, flux vs circulation)
MATCH (a:Concept {id:'gauss_law'}), (b:Concept {id:'amperes_law'})
MERGE (a)-[:ANALOGY_OF {strength: 0.80, domain: 'structural',
  mapping: 'surface integral of E ↔ line integral of B'}]->(b);

// Electric flux ↔ Magnetic flux (both ∫F·dA)
MATCH (a:Concept {id:'electric_flux'}), (b:Concept {id:'magnetic_flux'})
MERGE (a)-[:ANALOGY_OF {strength: 0.90, domain: 'mathematical',
  mapping: 'ΦE = ∫E·dA ↔ ΦB = ∫B·dA, different source equations'}]->(b);

// Coulomb's law ↔ Biot-Savart law (both 1/r² source laws)
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'coulombs_law'})
MERGE (a)-[:ANALOGY_OF {strength: 0.75, domain: 'structural',
  mapping: 'dq as source ↔ Idl as source, same 1/r² decay, both need superposition'}]->(b);

// Energy stored in capacitor ↔ energy stored in inductor (dual energy forms)
MATCH (a:Concept {id:'energy_stored_capacitor'}), (b:Concept {id:'energy_stored_inductor'})
MERGE (a)-[:ANALOGY_OF {strength: 0.90, domain: 'mathematical',
  mapping: '½CV² ↔ ½LI², electric energy ↔ magnetic energy, Q↔Φ, C↔1/L'}]->(b);
MATCH (a:Concept {id:'energy_stored_inductor'}), (b:Concept {id:'energy_stored_capacitor'})
MERGE (a)-[:ANALOGY_OF {strength: 0.90, domain: 'mathematical',
  mapping: '½LI² ↔ ½CV², magnetic energy ↔ electric energy'}]->(b);

// Capacitive reactance ↔ inductive reactance (both frequency-dependent resistance)
MATCH (a:Concept {id:'capacitive_reactance'}), (b:Concept {id:'inductive_reactance'})
MERGE (a)-[:ANALOGY_OF {strength: 0.70, domain: 'structural',
  mapping: 'both oppose AC, both frequency-dependent, opposite phase effects'}]->(b);

// Electric dipole ↔ magnetic dipole (identical torque formula, field forms)
MATCH (a:Concept {id:'electric_dipole'}), (b:Concept {id:'magnetic_dipole_moment_current'})
MERGE (a)-[:ANALOGY_OF {strength: 0.85, domain: 'physical',
  mapping: 'p=qd ↔ m=NIA, τ=p×E ↔ τ=m×B, field expressions identical in form'}]->(b);
MATCH (a:Concept {id:'magnetic_dipole_moment_current'}), (b:Concept {id:'electric_dipole'})
MERGE (a)-[:ANALOGY_OF {strength: 0.85, domain: 'physical',
  mapping: 'm=NIA ↔ p=qd, τ=m×B ↔ τ=p×E'}]->(b);

// Parallel plate capacitor ↔ solenoid (uniform field inside, zero outside)
MATCH (a:Concept {id:'field_solenoid'}), (b:Concept {id:'parallel_plate_capacitor'})
MERGE (a)-[:ANALOGY_OF {strength: 0.70, domain: 'physical',
  mapping: 'uniform B inside solenoid ↔ uniform E inside capacitor, edge effects ignored in both'}]->(b);

// Bar magnet ↔ electric dipole (identical field pattern, different source)
MATCH (a:Concept {id:'field_due_to_bar_magnet'}), (b:Concept {id:'field_due_to_dipole'})
MERGE (a)-[:ANALOGY_OF {strength: 0.90, domain: 'mathematical',
  mapping: 'identical 1/r³ field expressions, just p↔m and ε₀↔1/μ₀'}]->(b);

// RC circuit ↔ RL circuit (same exponential form, different time constants)
MATCH (a:Concept {id:'rc_circuit_charging'}), (b:Concept {id:'rl_circuits'})
MERGE (a)-[:ANALOGY_OF {strength: 0.80, domain: 'mathematical',
  mapping: 'τ=RC ↔ τ=L/R, Q=Q₀(1-e^-t/τ) ↔ I=I₀(1-e^-t/τ)'}]->(b);

// Displacement current ↔ ordinary current (both contribute to Amperian integral)
MATCH (a:Concept {id:'displacement_current'}), (b:Concept {id:'electric_current'})
MERGE (a)-[:ANALOGY_OF {strength: 0.65, domain: 'structural',
  mapping: 'Id=ε₀ dΦE/dt acts like I in Ampere generalized law'}]->(b);

// Power factor ↔ efficiency concepts from mechanics
MATCH (a:Concept {id:'power_factor'}), (b:Concept {id:'work_energy_theorem'})
MERGE (a)-[:ANALOGY_OF {strength: 0.60, domain: 'physical',
  mapping: 'cos φ describes fraction of power that does useful work, like η in mechanics'}]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — GENERALIZES EDGES
// (general)-[:GENERALIZES]->(special_case)
// ─────────────────────────────────────────────────────────────────────────────

// Gauss's law applications generalizes all specific field calculations
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'field_due_to_shell'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'field_due_to_solid_sphere'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'field_due_to_line_charge'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'conductors_electrostatics'})
MERGE (a)-[:GENERALIZES]->(b);

// Faraday's law generalizes motional EMF (motional is a special case of flux change)
MATCH (a:Concept {id:'faradays_law'}), (b:Concept {id:'motional_emf'})
MERGE (a)-[:GENERALIZES]->(b);

// Biot-Savart generalizes all specific field formulas
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'field_straight_wire'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'field_circular_loop'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'field_axis_circular_loop'})
MERGE (a)-[:GENERALIZES]->(b);

// Ampere's law generalizes solenoid and toroid
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'field_solenoid'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'field_toroid'})
MERGE (a)-[:GENERALIZES]->(b);

// Kirchhoff's laws generalize series-parallel analysis
MATCH (a:Concept {id:'kirchhoffs_laws'}), (b:Concept {id:'series_parallel_resistors'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'kirchhoffs_laws'}), (b:Concept {id:'capacitors_networks'})
MERGE (a)-[:GENERALIZES]->(b);

// Complex networks generalize Wheatstone bridge
MATCH (a:Concept {id:'complex_resistor_networks'}), (b:Concept {id:'wheatstone_bridge'})
MERGE (a)-[:GENERALIZES]->(b);

// Series RLC generalizes each pure element circuit
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'ac_through_resistor'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'ac_through_capacitor'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'ac_through_inductor'})
MERGE (a)-[:GENERALIZES]->(b);

// Superposition principle generalizes individual field calculations
MATCH (a:Concept {id:'superposition_principle_fields'}), (b:Concept {id:'field_due_to_ring'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'superposition_principle_fields'}), (b:Concept {id:'field_due_to_disk'})
MERGE (a)-[:GENERALIZES]->(b);

// Lorentz force generalizes magnetic force on charge
MATCH (a:Concept {id:'lorentz_force'}), (b:Concept {id:'magnetic_force_moving_charge'})
MERGE (a)-[:GENERALIZES]->(b);

// Maxwell equations generalize all individual laws
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'gauss_law'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'faradays_law'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'amperes_law'})
MERGE (a)-[:GENERALIZES]->(b);

// LC oscillations generalizes the single-element energy storage
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'energy_stored_capacitor'})
MERGE (a)-[:GENERALIZES]->(b);
MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'energy_stored_inductor'})
MERGE (a)-[:GENERALIZES]->(b);

// Continuous charge distributions generalizes discrete superposition
MATCH (a:Concept {id:'continuous_charge_distributions'}), (b:Concept {id:'superposition_principle_fields'})
MERGE (a)-[:GENERALIZES]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — USED_TOGETHER EDGES
// Co-occurrence in standard JEE problems
// frequency: 0.0–1.0 | problem_type: context string
// ─────────────────────────────────────────────────────────────────────────────

MATCH (a:Concept {id:'kirchhoffs_laws'}), (b:Concept {id:'emf_internal_resistance'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.90, problem_type: 'multi_cell_circuit'}]->(b);
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'kirchhoffs_laws'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.90, problem_type: 'multi_cell_circuit'}]->(b);

MATCH (a:Concept {id:'faradays_law'}), (b:Concept {id:'lenzs_law'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.95, problem_type: 'induction_direction'}]->(b);
MATCH (a:Concept {id:'lenzs_law'}), (b:Concept {id:'faradays_law'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.95, problem_type: 'induction_direction'}]->(b);

MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'magnetic_force_on_wire'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'rod_on_rails'}]->(b);
MATCH (a:Concept {id:'magnetic_force_on_wire'}), (b:Concept {id:'motional_emf'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'rod_on_rails'}]->(b);

MATCH (a:Concept {id:'lorentz_force'}), (b:Concept {id:'circular_motion'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.88, problem_type: 'charged_particle_trajectory'}]->(b);
MATCH (a:Concept {id:'circular_motion'}), (b:Concept {id:'lorentz_force'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.88, problem_type: 'charged_particle_trajectory'}]->(b);

MATCH (a:Concept {id:'gauss_law'}), (b:Concept {id:'conductors_electrostatics'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.80, problem_type: 'charge_distribution'}]->(b);
MATCH (a:Concept {id:'conductors_electrostatics'}), (b:Concept {id:'gauss_law'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.80, problem_type: 'charge_distribution'}]->(b);

MATCH (a:Concept {id:'series_rlc_circuit'}), (b:Concept {id:'resonance_rlc'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'rlc_analysis'}]->(b);
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'series_rlc_circuit'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'rlc_analysis'}]->(b);

MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'work_energy_theorem'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.82, problem_type: 'charge_movement_work'}]->(b);
MATCH (a:Concept {id:'work_energy_theorem'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.82, problem_type: 'charge_movement_work'}]->(b);

MATCH (a:Concept {id:'self_inductance'}), (b:Concept {id:'energy_stored_inductor'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.88, problem_type: 'magnetic_energy_problems'}]->(b);
MATCH (a:Concept {id:'energy_stored_inductor'}), (b:Concept {id:'self_inductance'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.88, problem_type: 'magnetic_energy_problems'}]->(b);

MATCH (a:Concept {id:'wheatstone_bridge'}), (b:Concept {id:'temp_dependence_resistance'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.70, problem_type: 'thermistor_bridge'}]->(b);
MATCH (a:Concept {id:'temp_dependence_resistance'}), (b:Concept {id:'wheatstone_bridge'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.70, problem_type: 'thermistor_bridge'}]->(b);

MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'superposition_principle_fields'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.80, problem_type: 'multi_wire_field'}]->(b);
MATCH (a:Concept {id:'superposition_principle_fields'}), (b:Concept {id:'biot_savart_law'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.80, problem_type: 'multi_wire_field'}]->(b);

MATCH (a:Concept {id:'capacitor_with_dielectric'}), (b:Concept {id:'energy_stored_capacitor'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.75, problem_type: 'dielectric_insertion_energy'}]->(b);
MATCH (a:Concept {id:'energy_stored_capacitor'}), (b:Concept {id:'capacitor_with_dielectric'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.75, problem_type: 'dielectric_insertion_energy'}]->(b);

MATCH (a:Concept {id:'potentiometer'}), (b:Concept {id:'emf_internal_resistance'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'emf_measurement'}]->(b);
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'potentiometer'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.85, problem_type: 'emf_measurement'}]->(b);

MATCH (a:Concept {id:'lc_oscillations'}), (b:Concept {id:'energy_stored_capacitor'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.90, problem_type: 'lc_energy_exchange'}]->(b);
MATCH (a:Concept {id:'energy_stored_capacitor'}), (b:Concept {id:'lc_oscillations'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.90, problem_type: 'lc_energy_exchange'}]->(b);

MATCH (a:Concept {id:'power_ac_circuits'}), (b:Concept {id:'rms_values'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.92, problem_type: 'ac_power_calculation'}]->(b);
MATCH (a:Concept {id:'rms_values'}), (b:Concept {id:'power_ac_circuits'})
MERGE (a)-[:USED_TOGETHER {frequency: 0.92, problem_type: 'ac_power_calculation'}]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — CONTRASTS_WITH EDGES
// Concepts understood by comparison; dimension = what distinguishes them
// ─────────────────────────────────────────────────────────────────────────────

// Electric field (vector) vs electric potential (scalar)
MATCH (a:Concept {id:'electric_field_concept'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'vector_vs_scalar'}]->(b);
MATCH (a:Concept {id:'electric_potential'}), (b:Concept {id:'electric_field_concept'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'vector_vs_scalar'}]->(b);

// Capacitors in series vs parallel (charge same vs voltage same)
MATCH (a:Concept {id:'capacitors_series'}), (b:Concept {id:'capacitors_parallel'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'charge_same_vs_voltage_same'}]->(b);
MATCH (a:Concept {id:'capacitors_parallel'}), (b:Concept {id:'capacitors_series'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'charge_same_vs_voltage_same'}]->(b);

// Self inductance vs mutual inductance (own flux vs mutual flux)
MATCH (a:Concept {id:'self_inductance'}), (b:Concept {id:'mutual_inductance'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'own_flux_vs_shared_flux'}]->(b);
MATCH (a:Concept {id:'mutual_inductance'}), (b:Concept {id:'self_inductance'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'own_flux_vs_shared_flux'}]->(b);

// Diamagnetism (χ<0) vs paramagnetism (χ>0)
MATCH (a:Concept {id:'diamagnetism'}), (b:Concept {id:'paramagnetism'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'susceptibility_sign'}]->(b);
MATCH (a:Concept {id:'paramagnetism'}), (b:Concept {id:'diamagnetism'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'susceptibility_sign'}]->(b);

// Electric flux (nonzero for enclosed charge) vs magnetic flux (always zero Gauss for B)
MATCH (a:Concept {id:'electric_flux'}), (b:Concept {id:'magnetic_flux'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'source_enclosed_vs_no_monopole'}]->(b);
MATCH (a:Concept {id:'magnetic_flux'}), (b:Concept {id:'electric_flux'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'source_enclosed_vs_no_monopole'}]->(b);

// Series resonance (I max, Z min) vs parallel resonance (I min, Z max)
MATCH (a:Concept {id:'resonance_rlc'}), (b:Concept {id:'parallel_rlc_circuit'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'current_max_vs_current_min_at_resonance'}]->(b);
MATCH (a:Concept {id:'parallel_rlc_circuit'}), (b:Concept {id:'resonance_rlc'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'current_max_vs_current_min_at_resonance'}]->(b);

// EMF vs terminal voltage
MATCH (a:Concept {id:'emf_internal_resistance'}), (b:Concept {id:'electric_potential'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'open_circuit_vs_loaded_terminal_voltage'}]->(b);

// AC through capacitor (current leads voltage) vs inductor (current lags)
MATCH (a:Concept {id:'ac_through_capacitor'}), (b:Concept {id:'ac_through_inductor'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'phase_lead_vs_phase_lag'}]->(b);
MATCH (a:Concept {id:'ac_through_inductor'}), (b:Concept {id:'ac_through_capacitor'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'phase_lead_vs_phase_lag'}]->(b);

// Motional EMF (needs conductor) vs induced E field (exists in free space)
MATCH (a:Concept {id:'motional_emf'}), (b:Concept {id:'induced_electric_field'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'requires_conductor_vs_free_space'}]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'motional_emf'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'requires_conductor_vs_free_space'}]->(b);

// Soft magnets (low coercivity) vs hard magnets (high coercivity) — from hysteresis
MATCH (a:Concept {id:'hysteresis'}), (b:Concept {id:'ferromagnetism'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'soft_vs_hard_magnetic_material'}]->(b);

// Biot-Savart (any geometry) vs Ampere's law (symmetric only)
MATCH (a:Concept {id:'biot_savart_law'}), (b:Concept {id:'amperes_law'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'arbitrary_vs_symmetric_geometry'}]->(b);
MATCH (a:Concept {id:'amperes_law'}), (b:Concept {id:'biot_savart_law'})
MERGE (a)-[:CONTRASTS_WITH {dimension: 'arbitrary_vs_symmetric_geometry'}]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7 — APPEARS_IN_PROBLEM_TYPE EDGES
// ─────────────────────────────────────────────────────────────────────────────

// rod_on_rails
MATCH (c:Concept {id:'motional_emf'}), (p:ProblemType {id:'rod_on_rails'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'magnetic_force_on_wire'}), (p:ProblemType {id:'rod_on_rails'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'kirchhoffs_laws'}), (p:ProblemType {id:'rod_on_rails'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'lenzs_law'}), (p:ProblemType {id:'rod_on_rails'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'faradays_law'}), (p:ProblemType {id:'rod_on_rails'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// charged_particle_fields
MATCH (c:Concept {id:'lorentz_force'}), (p:ProblemType {id:'charged_particle_fields'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'motion_in_magnetic_field'}), (p:ProblemType {id:'charged_particle_fields'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'velocity_selector'}), (p:ProblemType {id:'charged_particle_fields'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'circular_motion'}), (p:ProblemType {id:'charged_particle_fields'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'electric_field_concept'}), (p:ProblemType {id:'charged_particle_fields'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// capacitor_circuit
MATCH (c:Concept {id:'capacitors_networks'}), (p:ProblemType {id:'capacitor_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'kirchhoffs_laws'}), (p:ProblemType {id:'capacitor_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'capacitors_series'}), (p:ProblemType {id:'capacitor_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'capacitors_parallel'}), (p:ProblemType {id:'capacitor_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_stored_capacitor'}), (p:ProblemType {id:'capacitor_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// rc_transient
MATCH (c:Concept {id:'rc_circuit_charging'}), (p:ProblemType {id:'rc_transient'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'rc_circuit_discharging'}), (p:ProblemType {id:'rc_transient'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'exponential_functions'}), (p:ProblemType {id:'rc_transient'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'kirchhoffs_laws'}), (p:ProblemType {id:'rc_transient'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// spherical_conductor_system
MATCH (c:Concept {id:'conductors_electrostatics'}), (p:ProblemType {id:'spherical_conductor_system'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'gauss_law_applications'}), (p:ProblemType {id:'spherical_conductor_system'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'potential_due_to_shell'}), (p:ProblemType {id:'spherical_conductor_system'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'induced_charges_conductors'}), (p:ProblemType {id:'spherical_conductor_system'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'charge_sharing_capacitors'}), (p:ProblemType {id:'spherical_conductor_system'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// resonance_circuit
MATCH (c:Concept {id:'series_rlc_circuit'}), (p:ProblemType {id:'resonance_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'resonance_rlc'}), (p:ProblemType {id:'resonance_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'quality_factor'}), (p:ProblemType {id:'resonance_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'power_factor'}), (p:ProblemType {id:'resonance_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'impedance'}), (p:ProblemType {id:'resonance_circuit'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// infinite_resistor_network
MATCH (c:Concept {id:'complex_resistor_networks'}), (p:ProblemType {id:'infinite_resistor_network'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'kirchhoffs_laws'}), (p:ProblemType {id:'infinite_resistor_network'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'series_parallel_resistors'}), (p:ProblemType {id:'infinite_resistor_network'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// electromagnetic_energy
MATCH (c:Concept {id:'lc_oscillations'}), (p:ProblemType {id:'electromagnetic_energy'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_stored_inductor'}), (p:ProblemType {id:'electromagnetic_energy'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_stored_capacitor'}), (p:ProblemType {id:'electromagnetic_energy'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_density_magnetic_field'}), (p:ProblemType {id:'electromagnetic_energy'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_density_electric_field'}), (p:ProblemType {id:'electromagnetic_energy'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// dipole_problems
MATCH (c:Concept {id:'electric_dipole'}), (p:ProblemType {id:'dipole_problems'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'dipole_in_uniform_field'}), (p:ProblemType {id:'dipole_problems'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'field_due_to_dipole'}), (p:ProblemType {id:'dipole_problems'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'potential_due_to_dipole'}), (p:ProblemType {id:'dipole_problems'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'dipole_moment'}), (p:ProblemType {id:'dipole_problems'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);

// electromagnetic_induction_combined
MATCH (c:Concept {id:'faradays_law'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'lenzs_law'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'self_inductance'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'mutual_inductance'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'rl_circuits'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);
MATCH (c:Concept {id:'energy_stored_inductor'}), (p:ProblemType {id:'electromagnetic_induction_combined'}) MERGE (c)-[:APPEARS_IN_PROBLEM_TYPE]->(p);


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8 — EXTENDS EDGES
// Softer than REQUIRES — deeper treatment, proactive suggestion for mastered concepts
// ─────────────────────────────────────────────────────────────────────────────

MATCH (a:Concept {id:'gauss_law_applications'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'induced_electric_field'}), (b:Concept {id:'faradays_law'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'amperes_law'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'maxwell_equations'}), (b:Concept {id:'gauss_law'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'poynting_vector'}), (b:Concept {id:'em_wave_energy_intensity'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'complex_resistor_networks'}), (b:Concept {id:'kirchhoffs_laws'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'partial_dielectric_insertion'}), (b:Concept {id:'capacitor_with_dielectric'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'motional_emf_rotating'}), (b:Concept {id:'motional_emf'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'field_axis_circular_loop'}), (b:Concept {id:'field_circular_loop'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'mutual_inductance_coils'}), (b:Concept {id:'mutual_inductance'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'electrostatic_pressure'}), (b:Concept {id:'charge_distribution_on_surface'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'bound_and_free_charges'}), (b:Concept {id:'polarization'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'wattless_current'}), (b:Concept {id:'power_factor'}) MERGE (a)-[:EXTENDS]->(b);
MATCH (a:Concept {id:'radiation_pressure'}), (b:Concept {id:'em_wave_energy_intensity'}) MERGE (a)-[:EXTENDS]->(b);


// ─────────────────────────────────────────────────────────────────────────────
// VERIFICATION QUERIES
// ─────────────────────────────────────────────────────────────────────────────
//
// Count all edge types:
//   MATCH ()-[r]->() RETURN type(r), count(r) ORDER BY count(r) DESC;
//
// Full confusion network for one concept:
//   MATCH (c:Concept {id:'faradays_law'})-[:COMMONLY_CONFUSED_WITH]-(x)
//   RETURN c.name, x.name;
//
// Find all analogies the student could use to learn a weak concept:
//   MATCH (weak:Concept {id:'lc_oscillations'})-[r:ANALOGY_OF]->(bridge)
//   RETURN weak.name, bridge.name, r.strength, r.mapping;
//
// Pull all concepts in a given problem type:
//   MATCH (c:Concept)-[:APPEARS_IN_PROBLEM_TYPE]->(p:ProblemType {id:'rod_on_rails'})
//   RETURN c.name, c.chapter ORDER BY c.difficulty;
//
// Find generalizes chain from a special case concept:
//   MATCH path = (:Concept {id:'field_straight_wire'})<-[:GENERALIZES*1..3]-(general)
//   RETURN path;
//
// Complete agent context fetch for a weak concept (Q1+Q2+Q3+Q4 in one query):
//   MATCH (target:Concept {id: 'series_rlc_circuit'})
//   OPTIONAL MATCH (target)-[:REQUIRES]->(prereq:Concept)
//   OPTIONAL MATCH (target)-[:COMMONLY_CONFUSED_WITH]-(confused:Concept)
//   OPTIONAL MATCH (general:Concept)-[:GENERALIZES]->(target)
//   OPTIONAL MATCH (target)-[an:ANALOGY_OF]->(bridge:Concept)
//   OPTIONAL MATCH (target)-[:APPEARS_IN_PROBLEM_TYPE]->(pt:ProblemType)
//   RETURN target.name,
//          collect(DISTINCT prereq.name)    AS prerequisites,
//          collect(DISTINCT confused.name)  AS confusion_candidates,
//          collect(DISTINCT general.name)   AS generalizing_concepts,
//          collect(DISTINCT {concept: bridge.name, strength: an.strength}) AS analogies,
//          collect(DISTINCT pt.name)        AS problem_types;
//
// =============================================================================
// END OF EXTENDED EDGE SEED SCRIPT
// New edges added:
//   COMMONLY_CONFUSED_WITH : ~40 edges
//   ANALOGY_OF             : ~26 edges
//   GENERALIZES            : ~36 edges
//   USED_TOGETHER          : ~28 edges
//   CONTRASTS_WITH         : ~26 edges
//   APPEARS_IN_PROBLEM_TYPE: ~56 edges
//   EXTENDS                : ~14 edges
//   Total new edges        : ~226
//   Total with REQUIRES    : ~511
// =============================================================================
