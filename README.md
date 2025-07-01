# FeFET-Model-for-Computing-in-Memory
This project demonstrates a Compute-in-Memory (CiM) architecture using Ferroelectric Field-Effect Transistors (FeFETs), focusing on read and write operations simulated using appropriate models and plotting the ID–VGS characteristics under different polarization states.

# Objective
To simulate and demonstrate how FeFETs can be used as memory elements in CiM architectures, enabling in-memory logic operations and data storage. The project aims to: <br>

- Understand the write mechanism via polarization switching. <br>

- Observe the read behavior using ID–VGS curves. <br>

- Simulate nonvolatile behavior by showing distinct threshold voltages (Vth). <br>

- Enable logic-level detection for use in CiM applications. <br>

# Background
Traditional computing separates memory and logic (von Neumann bottleneck). CiM architectures break this by performing computations where the data is stored — in memory. <br>

- FeFETs are ideal for such architectures because: <br>

- They retain data using the ferroelectric polarization of the gate insulator. <br>

- Their threshold voltage (Vth) shifts depending on the remanent polarization. <br>

- They allow nonvolatile data storage and efficient read/write operations. <br>

#  Device Model: FeFET
The FeFET used in this simulation is based on a MOSFET with a ferroelectric layer (e.g., HfZrO₂) in the gate stack. <br>

- Write Operation: Polarization is switched by applying a high positive or negative gate voltage pulse. <br>

- Read Operation: A smaller gate voltage sweep is applied to plot ID vs VGS, reflecting different threshold voltages for ‘0’ and ‘1’. <br>
Metal Gate
↓
Ferroelectric HfZrO₂
↓
Interfacial Layer (optional)
↓
Silicon Substrate (n-type/p-type)

# Methodology
**Step 1**: Initialization <br>
- Simulate FeFET using a compact model (e.g., using Verilog-A or TCAD with ferroelectric polarization equations). <br>

- Define default material and geometric parameters: <br>

  - Ferroelectric thickness <br>

  - Polarization coefficients <br>

  - Channel length, width <br>

Step 2: Write Operation <br>
- Logic '1': Apply a high positive gate voltage pulse (e.g., +4V for 1µs) <br>
   → Polarization aligns downwards → Vth decreases <br>

- Logic '0': Apply a high negative gate voltage pulse (e.g., –4V for 1µs) <br>
   → Polarization aligns upwards → Vth increases <br>

🧠 Polarization Effect: <br>
- The direction of polarization alters the built-in electric field, shifting the threshold voltage of the FeFET. <br>

Step 3: Read Operation <br>
- Apply a sweep of gate voltage (e.g., 0V to 2V) with a small drain voltage (e.g., VDS = 50 mV). <br>

- Measure drain current (ID) for both logic states. <br>

- No polarization switching should occur (keep read voltages below coercive voltages). <br>

- Output: Two distinct ID-VGS curves: <br>

   - Lower Vth for ‘1’ <br>

   - Higher Vth for ‘0’ <br>

# ID–VGS Plot
The final ID–VGS characteristics represent the nonvolatile states of the FeFET: <br>

- After writing '1': Curve shifts left → Lower Vth <br>

- After writing '0': Curve shifts right → Higher Vth <br>

This plot is key to: <br>

- Demonstrating state distinction <br>

- Validating reliability of the FeFET as a memory bit <br>

- Enabling threshold-based logic detection in CiM operations <br>

# Outcomes
- Successfully simulated write/read operation of FeFET. <br>

- Validated Vth shift due to polarization. <br>

- Generated ID–VGS plots showing two distinct curves. <br>

- Demonstrated potential of FeFETs in non-volatile Compute-in-Memory designs. <br>

# Tools Used
- **Cadence Virtuoso**

# Next Steps
- Implement CiM logic operations (e.g., AND, OR) using FeFET arrays. <br>

- Optimize read/write voltage margins. <br>

- Integrate FeFET with peripheral circuits for sensing and logic. <br>



