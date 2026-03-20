# Root Rot Assessment Interface

**Dry Root Rot (DRR)** is one of the predominant diseases affecting chickpea and can cause up to 100% crop loss. Many laboratories across the globe are currently studying DRR, however manual disease detection and assessment tend to be tedious, time-consuming and subject to human bias. 

We introduce **RootRotAI**, an image-based ML-powered software for DRR detection and assessment. The motivation behind RootRot-AI is to introduce an automated DRR assessment system that is not only computationally efficient but also user friendly interface.

---

## Features of RootRotAI

* **Capabilities:** Classifies DRR vs. control and scores disease severity on a scale of 0–5 (0 = healthy, 5 = extreme susceptibility).
* **Supported Modalities:** Camera, root scanner, and microscope images.
* **Batch Processing:** Supports multiple image uploads at a time.
* **Filtering Invalid Images:** The software automatically filters out any invalid images uploaded by the user.
* **Download Results:** The user can download the results in .csv format.

---

## Platforms

### RootRotAI 2.1 (Web Portal)
RootRotAI 2.1 is an online portal intended for users who wish to diagnose large image sets.Since the application does not run locally on an external server, the computational efficiency is not limited by the RAM of the user’s local device.

### RootRotAI 2.2 (Mobile Application)
The RootRot-AI 2.2 is suitable for quick DRR analysisThe app runs locally in the user’s device and does not require internet.The mobile application has an additional “Camera” option allows the user to capture images in the app using the camera of the user’s local device

## Performance Metrics of RootRot-AI

| Model | Accuracy for Classification | RMSE for Severity Score |
| :--- | :---: | :---: |
| **Camera** | 94% | 0.87 |
| **Root Scanner** | 85% | 1.49 |
| **Microscope** | 93% | 1.21 |

