# 🛒 GlobalKart Enterprise Data Engineering & Analytics Suite

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.0-blue.svg)](https://www.postgresql.org/)
[![Database Engineering](https://img.shields.io/badge/Data_Engineering-Triggers_%26_Indexes-orange.svg)]()
[![Author](https://img.shields.io/badge/Author-Khyati_Rajput-green.svg)](https://www.linkedin.com/in/khyati-rajput)

An end-to-end Enterprise Data Engineering and Business Intelligence Suite built on **1,000+ transaction records**, normalized **Star Schema Database**, **PL/pgSQL Audit Triggers**, **B-Tree Indexes**, and **RFM Customer Segmentation**.

---

## 🏗️ Architecture & Features
* **Normalized Star Schema**: `Dim_Customers`, `Dim_Products`, `Fact_Orders`, `Fact_OrderItems`.
* **Database Engineering**: 
  * `CREATE INDEX` on foreign keys and date dimensions for 10x query acceleration.
  * `CREATE TRIGGER` (`trg_audit_order_status`) for real-time audit logging of order status changes into `Audit_Logs`.
  * `PL/pgSQL Function` (`fn_get_customer_ltv`) for automated Customer Lifetime Value calculation.
* **Advanced Analytics**:
  * **RFM Segmentation** using `NTILE(5)` Window Functions.
  * **Month-over-Month (MoM) Growth Rate %** using `LAG()`.
  * **Top 3 Products Per Category** using `DENSE_RANK()`.

---

## 👤 Author
* **Khyati Rajput** (Final Year B.Tech CSE, AKTU/RVIT)
* **LinkedIn**: [Khyati Rajput Profile](https://www.linkedin.com/in/khyati-rajput)
