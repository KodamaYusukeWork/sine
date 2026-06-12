# sine (Epsilon Project)

A generative sound piece in which an internal‑state system gradually transforms a complex harmonic structure into a single, pure sine tone.

---

## Concept / コンセプト

This work is a generative sound piece in which an internal‑state system gradually transforms a complex harmonic structure into a single, pure sine tone. The composition is driven by five continuously updated internal parameters—tension, vitality, fatigue, internal pressure, and dreaming—received via OSC and smoothed over time. These states modulate micro‑detuning, spectral density, amplitude fluctuations, and spatial characteristics, allowing the sound to behave as if it were a living entity undergoing slow internal change. 

At the core of the piece is a 240‑second purification process. The system begins with a ten‑voice harmonic field containing moiré interference, beating, and subtle inharmonic components. As the purification envelope progresses, these impurities are gradually removed: modulation ceases, detuning collapses, higher partials fade, and the reverberant space becomes increasingly transparent. By the end of the process, all interference has vanished, leaving only a stable, unmodulated sine wave. 

Rather than presenting sine‑wave synthesis or algorithmic composition as technical methods, the work frames them as part of a temporal and existential process. The sound is treated as the audible trace of an internal system unfolding toward simplicity—an irreversible movement from complexity to essence, from fluctuation to stillness. The final sine tone is not merely a sound but the residue of a system that has exhausted its impurities and arrived at its most fundamental state.

---

## Technical Specifications / 技術仕様

- **Language:** SuperCollider
- **Audio Configuration:** 2-Channel Output (Optimized for AirPods Pro / 48,000 Hz)
- **Control Protocol:** OSC (`/epsilon/state`)
