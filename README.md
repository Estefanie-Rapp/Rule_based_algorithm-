# Application of an Externally Developed Algorithm to Identify Research Cases and Controls from Electronic Health Record Data: Failures and Successes

## Overview
This repository contains an algorithm designed to determine cases and controls from a cohort of patients with rotator cuff disease, based on a series of case/ control definitions. The algorithm uses surgical procedures, ICD and CPT codes to identify relevant events and applies Boolean logic for inclusion or exclusion.

## Case Definitions and Criteria
Below are the detailed case definitions and their associated criteria.

### 1. Specific Surgical Inclusion
- **Description**: The diagnosis (Dx) date is determined by the earliest date associated with a specific surgical procedure.
- **Criteria**:
  - `rct_cpt_surg_spec_include`

---

### 2. Non-Specific Surgical/ICD Inclusion
- **Description**: The Dx date is the earliest date associated with non-specific surgical procedures or ICD codes, with additional criteria for diagnosis within a year.
- **Criteria**:
  - `rct_cpt_surg_nonspec_include`
  - AND (`rct_icd9_diag_include` OR `rct_icd10_diag_include` within 1 year after)

---

### 3. Imaging and Diagnosis
- **Description**: The Dx date is based on imaging CPT/ICD codes, with diagnosis codes within a year and exclusion criteria applied afterward.
- **Criteria**:
  - (`rct_cpt_image_include` OR `rct_icd9_image_include`)
  - AND (`rct_icd9_diag_include` OR `rct_icd10_diag_include` within 1 year after)
  - NOT (`rct_icd9_exclusions` OR `rct_icd10_exclusions` after CPT/ICD image include codes)

---

### 4A. Multiple ICD Inclusions (3 Visits)
- **Description**: The Dx date is determined by the 3rd unique ICD code, ensuring there are 3 visits with the relevant diagnosis without exclusion codes.
- **Criteria**:
  - Exactly 3 unique visits with mentions of `rct_icd9_diag_include` OR `rct_icd10_diag_include`
  - NOT (`rct_icd9_exclusions` OR `rct_icd10_exclusions` after ICD inclusion codes)

---

### 4B. Multiple ICD Inclusions (4 Visits)
- **Description**: The Dx date is set by the 4th unique ICD code, ensuring there are at least 4 mentions of the relevant diagnosis without exclusion codes.
- **Criteria**:
  - Exactly 4 mentions of `rct_icd9_diag_include` OR >= 4 mentions of `rct_icd10_diag_include`
  - NOT (`rct_icd9_exclusions` OR `rct_icd10_exclusions` after ICD diagnosis include codes)

---

# Control Definitions

This document outlines the control group definitions used for identifying patients who are not classified as cases based on specific CPT and ICD codes.

## Control Definitions and Criteria

### 1. Any Non-Case
- **Description**: Any non-case patients from the CPT/ICD list.
- **Criteria and Boolean Logic**:
  - A) `=Non-case from CPT/ICD list`
  - B) `NOT case status FROM CPT/ICD codes`

---

### 2. CPT/ICD Only with Imaging Code Confirmation for In-Tact Rotator Cuff
- **Description**: 
  - Includes all patients with CPT codes for imaging.
  - Includes all patients with ICD-9 codes for imaging.
  - Includes all patients with ICD-10 codes for imaging, with exclusion criteria applied afterward. 
  - If a patient meets the criteria for being a case, they are excluded from the control group.
- **Criteria and Boolean Logic**:
  - A) `(rct_cpt_image_include OR RCT_icd9_image_include OR RCT_icd10_image_include)`
  - B) `NOT case status from CPT/ICD codes`
  - C) `NOT (rct_cpt_surg_spec_include OR rct_cpt_surg_nonspec_include OR RCT_icd9_diag_include OR RCT_icd10_diag_include)`

---

## How to Use
1. **Go to our paper** to find the full table of CPT codes and ICD codes used in this algorithm.
2. Use the definitions provided earlier in this README to understand how the logic is applied.
3. Clone the repository:
   ```bash
   git clone <repository-url>
4. Use or customize the SQL query included in the repository to fit your specific dataset or requirements.
5. Happy coding!

