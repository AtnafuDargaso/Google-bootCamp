
# Alaska Department of Snow - System Architecture

## Components:
1. **Frontend**: Streamlit web application
2. **AI Layer**: Vertex AI Gemini for natural language processing
3. **RAG System**: BigQuery for knowledge storage and retrieval
4. **Safety Layer**: Prompt filtering and response validation
5. **Logging**: Comprehensive interaction logging

## Data Flow:
User → Streamlit → Safety Check → RAG Search → Gemini → Safety Validation → User

## Security Features:
- Prompt injection detection
- Content safety filtering
- PII detection
- Response validation
- Comprehensive audit logging

## Challenge 5 Requirements Met:
- ✅ Backend RAG data store (BigQuery)
- ✅ Access to backend API functionality
- ✅ Unit tests for agent functionality
- ✅ Evaluation data using testing framework
- ✅ Prompt filtering and response validation
- ✅ Log all prompts and responses
- ✅ Generative AI agent deployed to website
