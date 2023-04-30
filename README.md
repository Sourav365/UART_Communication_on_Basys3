# UART_Communication_on_Basys3
<img width="800" alt="image" src="https://user-images.githubusercontent.com/49667585/230661644-889b4489-051e-4e9a-b4a1-743b27c13e46.png">

## 1. UART Transmitter Block
It is a shift reg. that **loads data in parallel** and **shifts bits out serially** at a _specific Baude Rate_.
<img width="750" alt="image" src="https://user-images.githubusercontent.com/49667585/230662199-a2f473dc-7475-4fc3-a172-734155c183c8.png">

## 2. UART Receiver Block
It is a shift reg. that **shifts bits in serially** at a _specific Baud Rate_ and then outputs the reassembled data byte in **parallel**.
<img width="750" alt="image" src="https://user-images.githubusercontent.com/49667585/230662554-6855f58e-2597-4a9e-8bd3-1aa7dc5daa85.png">

### Receiver Oversampling by 16
It is a technique used by receiver block in UART to recover data by discriminating between valied inconing data and noise.
To recognize 1-Bit, it takes 16 samples and based on **Majority**, it takes decision.

<img width="400" alt="image" src="https://user-images.githubusercontent.com/49667585/230663150-b5db840b-e380-4557-ad16-6e2ef2a3cf04.jpg">

## 3. Baud Rate Generator Block
Generates Sample_ticks for the Receiver and Transmitter circuits.
Baudrate = 9600
Oversampled by 16
Sampling rate = 16*9600 = 153600
Clk frequency = 100MHz
SO, Count amount for counter = 
```math
\frac{100*10^6}{16*9600}=651
```
When counter counting value goes to 651, 

i) Counter value resets to 0.

ii) sample_tick will be HIGH for 1 clk cycle, then goes to 0.

## 4. FIFO
<img width="531" alt="image" src="https://user-images.githubusercontent.com/49667585/230759421-8d88940c-2881-40f8-8f5e-0e99d4b50269.png">
Components:

1. RAM Memory
2. Read pionter
3. Write pointer




## States
1. Idle
2. Start
3. Data
4. Stop

<img width="816" alt="image" src="https://user-images.githubusercontent.com/49667585/230664426-5fb61bd2-04b3-4da8-ab8a-8398001aff50.png">

## Receiver State Diagram
<img width="515" alt="image" src="https://user-images.githubusercontent.com/49667585/230708750-f00ae132-fdcf-43ac-b252-3909464cd73d.png">

## Transmitter State Diagram
<img width="515" alt="image" src="https://user-images.githubusercontent.com/49667585/230709152-6df6479e-42a6-42a5-beee-7a8569a2689a.png">

## Recevie and transmitt through another pins

```
#Receive through USB-RS232 Interface
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports rx]
```

```
#Transmitt through Pmod Header JA J1-pin and send to other device
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {tx}];
```

<img width="550" alt="image" src="https://user-images.githubusercontent.com/49667585/235340907-ad68e3e9-9fff-4e0f-b8ab-92d8e2285233.png">

<img width="550" alt="image" src="https://user-images.githubusercontent.com/49667585/235341049-da6e867b-c153-4c62-b134-3ed6b5e3e4aa.png">

'e'= 0b01100101 --> LSB is transmitted 1st.

<img width="550" alt="image" src="https://user-images.githubusercontent.com/49667585/235341810-25218929-af4a-451a-8c61-ae1d382822c4.png">


