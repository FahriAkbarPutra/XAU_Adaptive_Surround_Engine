# XAU Adaptive Surround Engine 📈

A high-frequency, low-latency trapping Expert Advisor (EA) built for MetaTrader 5 (MQL5). Specifically optimized for highly volatile pairs like **XAUUSD (Gold)** on lower timeframes.

## 🚀 Core Mechanics
This EA uses a **Zero-Latency State Machine** to perfectly "surround" the current price. 
Instead of waiting for a Stop Loss (SL) to hit and then reacting, this engine *locks* a Pending Order directly onto the exact price coordinate of the active Stop Loss.
* If a `BUY` position is active, a `SELL STOP` is glued perfectly to the Buy SL.
* When the price moves into profit and the **Trailing Stop** pulls the SL higher, the Pending Order is dynamically dragged along with it.
* If the market reverses and hits the SL, the reversal order is executed instantaneously by the broker's server with absolute zero network latency.

## ✨ Features
* **Absolute Sync Trapping**: Reversal pending orders are dynamically synchronized with the active Trailing SL.
* **Interactive UI Panel**: On-chart draggable panel displaying real-time spread and floating profit.
* **Spread Filter**: Automatically blocks execution during high-spread market events.
* **ECN Compatibility**: Uses `trade.SetTypeFillingBySymbol()` to ensure compatibility with Raw/ECN brokers (e.g., EC Markets, IC Markets).
* **Strategy Tester Auto-Start**: Automatically bypasses the UI start button during backtesting.

## ⚙️ Parameters (Poin Based)
All distance parameters are measured in **Points** (10 Points = 1 Pip) for maximum precision.

| Parameter Group | Name | Description |
| :--- | :--- | :--- |
| **LOT & SPREAD** | `InpLotSize` | Initial volume for the first spawn. |
| | `InpLotMultiplier` | Lot multiplier applied on a reversal (e.g., 1.5x to recover losses). |
| | `InpMaxSpread` | Maximum allowed spread in Points (Match with Market Watch). |
| **TRANSAKSI (POIN)** | `InpPendingDist` | Distance from the current price to spawn the initial Buy/Sell Stops. |
| | `InpInitialSL` | Initial Stop Loss distance for all orders. |
| **TRAILING SL (POIN)** | `InpTrailingStart` | Minimum profit points required to start trailing the SL. |
| | `InpTrailingDist` | The distance to maintain between the current price and the new SL. |
| | `InpTrailingStep` | SL modification step (Prevents server spamming). |
| **SYSTEM** | `InpMagicNumber` | Unique ID for the EA's orders. |

## 🛠️ Installation
1. Download the `XAU_Adaptive_Surround_Engine.mq5` file.
2. Open MetaTrader 5 -> `File` -> `Open Data Folder`.
3. Navigate to `MQL5` -> `Experts`.
4. Paste the `.mq5` file into the folder.
5. Open MetaEditor (F4), find the file, and click **Compile**.
6. Attach the EA to your XAUUSD chart and ensure **"Allow Algo Trading"** is enabled.

## ⚠️ Disclaimer
Trading financial markets involves a high degree of risk. This Expert Advisor is provided for educational and experimental purposes only. Always test thoroughly on a Demo account before deploying real capital. The developer is not responsible for any financial losses incurred.
"# XAU_Adaptive_Surround_Engine" 
"# XAU_Adaptive_Surround_Engine" 

## 📈 1 Month Backtesting Report
This not a real simulation on real chart , this simulation from meta trader 5 , basicly it gonna looks similar but on meta trader no noise price like on real chart
[ReportTester-800203301.xlsx](https://github.com/user-attachments/files/32202549/ReportTester-800203301.xlsx)
