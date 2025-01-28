# Application of an Externally Developed Algorithm to Identify Research Cases and Controls from Electronic Health Record Data: Failures and Successes

## Overview
This repository contains an algorithm designed to determine the diagnosis (Dx) date based on a series of case definitions. The algorithm uses surgical procedures, ICD codes, imaging, and other clinical criteria to identify relevant events and apply Boolean logic for inclusion or exclusion.

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

## How to Use
1. **Go to our paper** to find the full table of CPT codes and ICD codes used in this algorithm.
2. Use the definitions provided earlier in this README to understand how the logic is applied.
3. Clone the repository:
   ```bash
   git clone <repository-url>
4. Use or customize the SQL query included in the repository to fit your specific dataset or requirements.
5. Happy coding!

