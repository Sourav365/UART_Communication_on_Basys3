# UART_Communication_on_Basys3
<img width="931" alt="image" src="https://user-images.githubusercontent.com/49667585/230661644-889b4489-051e-4e9a-b4a1-743b27c13e46.png">

## 1. UART Transmitter Block
It is a shift reg. that **loads data in parallel** and **shifts bits out serially** at a _specific Baude Rate_.
<img width="815" alt="image" src="https://user-images.githubusercontent.com/49667585/230662199-a2f473dc-7475-4fc3-a172-734155c183c8.png">

## 2. UART Receiver Block
It is a shift reg. that **shifts bits in serially** at a _specific Baud Rate_ and then outputs the reassembled data byte in **parallel**.
<img width="747" alt="image" src="https://user-images.githubusercontent.com/49667585/230662554-6855f58e-2597-4a9e-8bd3-1aa7dc5daa85.png">

### Receiver Oversampling by 16
It is a technique used by receiver block in UART to recover data by discriminating between valied inconing data and noise.
To recognize 1-Bit, it takes 16 samples and based on **Majority**, it takes decision.
<img width="700" alt="image" src="https://user-images.githubusercontent.com/49667585/230663150-b5db840b-e380-4557-ad16-6e2ef2a3cf04.jpg">

## 3. Baud Rate Generator Block
Generates Sample_ticks for the Receiver and Transmitter circuits.
Baudrate = 9600
Oversampled by 16
Sampling rate = 16*9600 = 153600
Clk frequency = 100MHz
SO, Count amount for counter = $`\frac{100*10^6}{153600}`$

