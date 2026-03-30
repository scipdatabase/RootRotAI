# Root Rot Assessment Interface

**Dry Root Rot (DRR)** is one of the predominant diseases affecting chickpea and can cause up to 100% crop loss. Many laboratories across the globe are currently studying DRR, however manual disease detection and assessment tend to be tedious, time-consuming and subject to human bias. 

We introduce **RootRotAI**, an image-based ML-powered software for DRR detection and assessment in chickpea. The motivation behind RootRotAI is to introduce an automated DRR assessment system that is not only computationally efficient but also user friendly interface.

---

## Features of RootRotAI

* **Capabilities:** Classifies DRR vs. control and scores disease severity on a scale of 0–5 (0 = healthy, 5 = extreme susceptibility).
* **Supported Modalities:** Handheld camera, root scanner, and microscope images.
* **Batch Processing:** Supports multiple image uploads at a time.
* **Filtering Invalid Images:** The software automatically filters out any invalid images uploaded by the user.
* **Download Results:** The user can download the results in .csv format.

---

## Platforms

### RootRotAI 2.1 (Web Application)
RootRotAI 2.1 is a web application intended for users who wish to diagnose large image sets.Since the application does not run locally on an external server, the computational efficiency is not limited by the RAM of the user’s local device.

RootRotAI 2.1 can be accessed using the link: http://223.31.159.3/DRR_portal/RootRotAI.html

> [!NOTE]
> Please access this tool using a private network (home/lab) or mobile data, as strict public Wi-Fi networks often block direct IP links.

### RootRotAI 2.2 (Mobile Application)
The RootRotAI 2.2 is suitable for quick DRR analysisThe app runs locally in the user’s device and does not require internet.The mobile application has an additional “Camera” option allows the user to capture images in the app using the camera of the user’s local device.

## Performance Metrics of RootRotAI

| Model | Accuracy for Classification | RMSE for Severity Score |
| :--- | :---: | :---: |
| **Handheld Camera** | 94% | 0.87 |
| **Root Scanner** | 85% | 1.49 |
| **Microscope** | 93% | 1.21 |

## Installation & Setup

To set up a local copy of **RootRotAI** for development or testing, follow these steps:

### 1. Prerequisites
* **Mobile Application:** Ensure you have Flutter installed on your machine.
* **Web Application:** Ensure you have Python 3.8+ and Git installed. You will also need to install the dependencies listed in the `requirements.txt` file located in the portal directory.

### 2. Clone the Repository
Open your terminal or command prompt and run:
```bash
git clone [https://github.com/scipdatabase/RootRotAI.git](https://github.com/scipdatabase/RootRotAI.git)

