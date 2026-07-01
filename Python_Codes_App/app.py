import streamlit as st
import joblib
import numpy as np
import pandas as pd

# Premium corporate wide layout engine
st.set_page_config(page_title="Czechoslovakia Financial Intelligence Suite", layout="wide")

# --- 1. MODEL MATRIX LOADING (Exact 13-feature Predictive Model) ---
@st.cache_resource
def load_ml_pipeline():
    try:
        model = joblib.load('banking_model.pkl')
        scaler = joblib.load('banking_scaler.pkl')
        return model, scaler
    except:
        return None, None

model, scaler = load_ml_pipeline()

# --- 2. COMPREHENSIVE DATAFRAMES ENGINE ---
@st.cache_data
def load_comprehensive_insights():
    age_df = pd.DataFrame({
        'Age Segment': ['26-60 Years (Working Class)', '60+ Years (Senior Citizens)'],
        'Customer Count': [1625, 3744]
    })
    gender_df = pd.DataFrame({'Gender': ['Male', 'Female'], 'Count': [450, 410]})
    card_df = pd.DataFrame({
        'Card Variant': ['No Card', 'Classic Card', 'Junior Card', 'Gold Card'],
        'Total Issued': [444, 320, 141, 95]
    })
    account_type_df = pd.DataFrame({
        'Account Type': ['Savings Account', 'Salary Account', 'NRI Account'],
        'Proportion Share (%)': [33.5, 31.2, 35.3]
    })
    financial_trends_df = pd.DataFrame({
        'Year': ['2016', '2017', '2018', '2019', '2020', '2021'],
        'Total Balance ($)': [52000, 71000, 94000, 126000, 158000, 189000],
        'Total Credits ($)': [45000, 58000, 79000, 102000, 114000, 131000],
        'Total Withdrawals ($)': [49000, 64000, 85000, 111000, 129000, 148000]
    })
    monthly_seasonality_df = pd.DataFrame({
        'Month': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        'Transaction Volume': [2800, 1200, 1900, 1750, 1600, 1850, 1900, 1700, 2100, 2900, 3100, 3400]
    })
    operational_channels_df = pd.DataFrame({
        'Operation Type': ['Withdrawal in Cash', 'Remittance to Other Bank', 'Credit in Cash', 'Interest Credit', 'Electronic Fund Transfer'],
        'Volume Count': [18450, 12900, 9100, 7800, 4200]
    })
    regional_df = pd.DataFrame({
        'District/Region': ['South Moravia', 'North Moravia', 'Prague (Metropolitan)', 'North Bohemia', 'East Bohemia'],
        'Customer Base': [1520, 1480, 1210, 640, 519],
        'Average District Salary ($)': [10450, 9810, 12540, 8920, 9400],
        'Unemployment Rate (%)': [3.1, 4.2, 1.8, 5.4, 2.9]
    })
    loan_portfolio_df = pd.DataFrame({
        'Loan Status Group': ['A (Finished/Good)', 'B (Finished/Defaulter)', 'C (Running/Good)', 'D (Running/Debt)'],
        'Share Proportion (%)': [30.0, 5.0, 56.0, 9.0],
        'Average Loan Amount ($)': [91000, 210000, 185000, 249000],
        'Average EMI Outflow ($)': [4264.13, 5396.25, 3938.53, 5286.64]
    })
    return age_df, gender_df, card_df, account_type_df, financial_trends_df, monthly_seasonality_df, operational_channels_df, regional_df, loan_portfolio_df

# Unpacking components safely
age_data, gender_data, card_data, acc_type_data, financial_trends, month_data, ops_data, region_data, loan_data = load_comprehensive_insights()

# --- 3. SESSION STATE FOR ENTERPRISE SECURITY ---
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

if not st.session_state.logged_in:
    st.markdown("<h2 style='text-align: center; color: #1E3A8A; margin-top: 80px;'>🔐 Czechoslovakia Financial Suite Login</h2>", unsafe_allow_html=True)
    col_l, _ = st.columns([1, 1])
    with col_l:
        with st.form("login_suite"):
            uid = st.text_input("User Identification Code")
            pwd = st.text_input("Security Protocol Password", type="password")
            if st.form_submit_button("Verify Access Rights", use_container_width=True):
                if uid == "admin" and pwd == "banking123":
                    st.session_state.logged_in = True
                    st.rerun()
                else:
                    st.error("Invalid Operational Parameters.")

# --- 4. SECURE PLATFORM DASHBOARD SUITE ---
else:
    st.sidebar.title("⚡ Operational Suite Navigation")
    # FIXED: Module name exactly mapped across strings
    selected_module = st.sidebar.radio("Go To Module Layer:", ["Database Analytical Insights Hub", "Loan Eligibility Prediction Engine"])

    if st.sidebar.button("Terminate Active Session", use_container_width=True):
        st.session_state.logged_in = False
        st.rerun()

    if selected_module == "Database Analytical Insights Hub":
        st.title("📊 Financial Intelligence & Business Analysis Suite")
        st.markdown("---")

        tab_cust, tab_fin, tab_prod, tab_reg, tab_loan = st.tabs([
            "👥 Customer Segmentation", "📈 Financial Data Streams", 
            "💳 Product Penetration Matrix", "📍 Regional Economic Mappings", "💰 Loan Portfolio Risks"
        ])

        with tab_cust:
            st.header("Demographics & Age Structure Analytics")
            col1, col2 = st.columns(2)
            with col1:
                st.write("**📊 Customer Weight Across Age Segments**")
                st.bar_chart(data=age_data, x='Age Segment', y='Customer Count', color='#1E3A8A')
            with col2:
                st.write("**👥 Gender Distribution Metrics**")
                st.bar_chart(data=gender_data, x='Gender', y='Count', color='#4F46E5')
            st.info("""- **60+ Generation Dominance:** Skewed heavily towards senior citizens. Flat transactional growth vector.
- **Missing Pipeline (18-25):** Core youth demographic is absent, creating future structural risks.
- **Underpenetrated Working Class:** High potential 26-60 tier is small relative to credit capability.""")

        with tab_fin:
            st.header("Timeline Growth Volumes & Seasonality Vectors")
            col1, col2 = st.columns(2)
            with col1:
                st.write("**📈 Year-on-Year Flow Outflows (2016 - 2021)**")
                st.line_chart(data=financial_trends, x='Year', y=['Total Balance ($)', 'Total Credits ($)', 'Total Withdrawals ($)'])
            with col2:
                st.write("**📅 Month-on-Month Seasonality Peak Trends**")
                st.bar_chart(data=month_data, x='Month', y='Transaction Volume', color='#10B981')
            st.write("**📊 Channels Activity Structure Metrics**")
            st.bar_chart(data=ops_data, x='Operation Type', y='Volume Count', color='#059669')
            st.info("""- **Cash Outflow Tendency:** Cash withdrawals consistently outpace total incoming credits.
- **Seasonality Highs:** Volume transaction peaks observed in January and the Q4 cycle (Oct-Dec).
- **Weak Digital Adoption:** 'Withdrawal in Cash' remains the apex channel; low digital transaction share.""")

        with tab_prod:
            st.header("Product Share Breakdown & Card Deficits")
            col1, col2 = st.columns(2)
            with col1:
                st.write("**💳 Card Variant Distribution - 'No Card' Deficit**")
                st.bar_chart(data=card_data, x='Card Variant', y='Total Issued', color='#FF9800')
            with col2:
                st.write("**📋 Operational Account Type Split Proportion**")
                st.bar_chart(data=acc_type_data, x='Account Type', y='Proportion Share (%)', color='#059669')
            st.info("""- **Critical Product Deficit:** Over 4,400 clients maintain 'No Card' attached to their primary schema.
- **Flat Differentiation:** Savings, Salary, and NRI accounts uniform at ~30-35% split each.
- **Lack of Cross-Selling Depth:** Users restricted heavily to 1:1 single-product mappings.""")

        with tab_reg:
            st.header("Regional Customer Penetration & Economic Disconnects")
            col1, col2 = st.columns(2)
            with col1:
                st.write("**📍 Client Concentration Across Regional Districts**")
                st.bar_chart(data=region_data, x='District/Region', y='Customer Base', color='#4F46E5')
            with col2:
                st.write("**📉 Average District Unemployment Indices (%)**")
                st.line_chart(data=region_data, x='District/Region', y='Unemployment Rate (%)', color='#EF4444')
            st.info("""- **Urban Clustering Nodes:** Primary customer density rests inside South and North Moravia regions.
- **Salary vs. Savings Mismatch:** High-cost urban environments like Prague show high spending but lower relative savings balances.""")

        with tab_loan:
            st.header("Loan Allocation Matrix & Structural Exposure Strain")
            col1, col2 = st.columns(2)
            with col1:
                st.write("**💰 Average Loan Ticket Size per Category Status Group**")
                st.bar_chart(data=loan_data, x='Loan Status Group', y='Average Loan Amount ($)', color='#DC2626')
            with col2:
                st.write("**📉 EMI Repayment Strain Trajectories**")
                st.line_chart(data=loan_data, x='Loan Status Group', y='Average EMI Outflow ($)', color='#B91C1C')
            st.info("""- **Latent Exposure Risks:** Over 65%+ profiles locked inside active running loans.
- **Ticket Size Risk Driver:** Critical defaulters (Group B) and debt-stressed runs (Group D) feature oversized ticket exposures.
- **Repayment Mismatch:** Stressed groups display heavily inflated monthly EMI commitments.""")

    # FIXED: String perfectly matches with the sidebar selection definition block
    elif selected_module == "Loan Eligibility Prediction Engine":
        st.header("🔮 AI Machine Loan Eligibility Engine")
        st.write("Trained standard scaler matrix execution environment for credit risk mapping:")

        if model is None or scaler is None:
            st.warning("Workspace missing core framework pickle binaries (`banking_model.pkl` / `banking_scaler.pkl`).")

        col_in1, col_in2 = st.columns(2)
        with col_in1:
            age = st.number_input("Client Age Profile Integer", min_value=18, max_value=120, value=35)
            avg_balance = st.number_input("Average Monthly Account Balance ($)", min_value=0, value=15000)
            total_accounts = st.number_input("Total Joint/Individual Accounts Held", min_value=1, max_value=5, value=1)
            total_trans = st.number_input("Monthly Transactions Executed Count", min_value=0, value=12)

        with col_in2:
            gender = st.selectbox("Legal Gender Profile Mapping", ["male", "female"])
            card_type = st.selectbox("Active Operational Card Product", ["No card", "Classic", "Junior", "Gold"])
            salary_flag = st.selectbox("Salary Account Verification Flag? (1=Yes, 0=No)", [1, 0])
            saving_flag = st.selectbox("Active Savings Account Flag? (1=Yes, 0=No)", [1, 0])

        col_in3, col_in4 = st.columns(2)
        with col_in3:
            monthly_fee = st.selectbox("Fixed Monthly Cost Charge Covered? (1=Yes, 0=No)", [1, 0])
        with col_in4:
            trans_fee = st.selectbox("Per Transaction Variable Fee Covered? (1=Yes, 0=No)", [0, 1])

        # Feature engineering derived equations
        estimated_income = avg_balance * 2
        emi_capacity = estimated_income * 0.3

        # One-hot encoded vector variables reconstruction
        gender_male = 1 if gender == "male" else 0
        card_Classic = 1 if card_type == "Classic" else 0
        card_Gold = 1 if card_type == "Gold" else 0
        card_Junior = 1 if card_type == "Junior" else 0

        if st.button("Evaluate Credit Clearance Matrix", use_container_width=True):
            if model is not None and scaler is not None:
                input_vector = np.array([[
                    avg_balance, total_trans, total_accounts, salary_flag, 
                    saving_flag, age, monthly_fee, trans_fee, 
                    emi_capacity, gender_male, card_Classic, card_Gold, card_Junior
                ]])
                try:
                    processed_vector = scaler.transform(input_vector)
                    prediction = model.predict(processed_vector)[0]
                    probability = model.predict_proba(processed_vector)[0][1]

                    st.markdown("---")
                    if prediction == 1:
                        st.success(f"🎉 **System Clearance Confirmed! Credit Approved.** (Confidence: {probability:.2%})")
                        st.balloons()
                    else:
                        st.error(f"❌ **Risk Limit Transgressed. Application Denied.** (Risk Score: {1 - probability:.2%})")
                except Exception as ex:
                    st.error(f"Scalar preprocessing mismatch error: {ex}")
            else:
                st.error("Execution Aborted: Saved model matrices parameters unavailable.")
