
import streamlit as st
import vertexai
from vertexai.preview.generative_models import GenerativeModel
from datetime import datetime
import hashlib

vertexai.init(project="qwiklabs-gcp-00-850eb8b95938", location="us-central1")

class SimpleAlaskaSnowAgent:
    def __init__(self):
        self.model = GenerativeModel("gemini-2.5-flash")

    def process_query(self, user_id, query):
        prompt = f"""
        You are a helpful assistant for Alaska Department of Snow.
        Answer questions about snow removal, road conditions, school closures, and emergency services.

        Question: {query}

        Provide accurate information. If unsure, suggest calling 511 or 1-800-ALASKA-SNOW.
        """

        try:
            response = self.model.generate_content(prompt)
            return {
                "response": response.text,
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            return {
                "response": "Please call 511 for road conditions or 1-800-ALASKA-SNOW for assistance.",
                "timestamp": datetime.now().isoformat()
            }

st.set_page_config(
    page_title="Alaska Department of Snow - Online Agent",
    page_icon="❄️",
    layout="wide"
)

st.title("❄️ Alaska Department of Snow - Online Agent")
st.markdown("""
I can help with:
- 🚜 Snow plowing schedules
- 🛣️ Road conditions
- 🏫 School closures
- 🚨 Emergency services
- ⚠️ Weather alerts
""")

if 'agent' not in st.session_state:
    st.session_state.agent = SimpleAlaskaSnowAgent()
if 'conversation' not in st.session_state:
    st.session_state.conversation = []

for msg in st.session_state.conversation:
    with st.chat_message(msg["role"]):
        st.write(msg["content"])

if prompt := st.chat_input("Ask about snow conditions or road closures..."):
    st.session_state.conversation.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.write(prompt)

    with st.spinner("Searching Alaska snow database..."):
        response_data = st.session_state.agent.process_query(
            f"user_{hashlib.md5(prompt.encode()).hexdigest()[:8]}",
            prompt
        )

    st.session_state.conversation.append({"role": "assistant", "content": response_data["response"]})
    with st.chat_message("assistant"):
        st.write(response_data["response"])

    st.caption(f"Response at {response_data['timestamp']}")

with st.sidebar:
    st.header("📞 Emergency Contacts")
    st.info("""
    **Immediate Assistance:**
    - 🚨 Emergency: 911
    - 🛣️ Road Conditions: 511
    - 🚜 Snow Reporting: 1-800-ALASKA-SNOW
    - 🌐 Website: alaska.gov/snow
    """)

    st.header("ℹ️ About This Agent")
    st.write("""
    This AI agent helps answer common questions about
    Alaska Department of Snow services.

    For complex or emergency situations,
    please contact us directly.
    """)

st.markdown("---")
st.caption("Alaska Department of Snow - Secure AI Assistant | Challenge 5 Implementation")
