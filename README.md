# 🛍️ Market Basket Analysis with Apriori Algorithm

This project was developed as the final assignment for a Data Mining course. It applies Market Basket Analysis using the **Apriori algorithm** to discover meaningful associations among products purchased by customers. The goal is to generate actionable insights for product bundling, recommendation engines and cross-selling strategies.

---

## 📌 Project Overview

**Objective:**  
To analyze customer purchase behavior and uncover frequent itemsets and strong association rules using transactional data from a retail dataset.

**Tech Stack:**
- **Language:** R
- **Libraries Used:** `arules`, `arulesViz`, `ggplot2`, `dplyr`, `caTools`, `cluster`, `h2o`

---

## 🔍 Data Description

- `customer_data.csv` - Contains demographic and loyalty information for 50,000 customers  
- `customer_purchase_history_final.csv` - Contains 83,384 purchase transactions  
- Data was cleaned, merged and preprocessed (factor conversion, normalization, etc.) before analysis.

---

## ⚙️ Key Steps

1. **Data Cleaning & Preparation**
   - Merged customer and purchase history
   - Scaled numeric features, converted factors
   - Handled missing values

2. **Transaction Conversion**
   - Converted the dataset into transaction format using `arules`

3. **Apriori Algorithm**
   - Applied with `support = 0.001` and `confidence = 0.2`
   - Rules were sorted by **lift** to identify the most influential product associations

4. **Visualization**
   - Matrix plot of LHS vs RHS rules
   - Graph network of co-occurring items
   - Scatter plot of support vs confidence

---

## 📈 Insights

- High-lift rules indicate potential product pairs for cross-selling
- Visualization of rule structure provides intuitive understanding of product relationships
- This analysis can be used to build personalized recommendation systems

---

## 📸 Sample Visuals

- Support vs Confidence Plot
  ![ssss](https://github.com/user-attachments/assets/acb51cdb-dc4e-4aa1-a0a4-790b3e041ae8)

- Association Rule Network Graph
  ![plot 1](https://github.com/user-attachments/assets/e9540542-8273-48dc-ac06-85b266358d36)

- Top 10 Rule Matrix  
![matrix for 10 rules](https://github.com/user-attachments/assets/3b4c1f34-51e0-4cd0-92c8-6603540502ad)


---

