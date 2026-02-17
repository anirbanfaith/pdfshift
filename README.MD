# pdfduck

> bulk pdf → structured csv. python backend + browser frontend.

---

## what it does

drop PDFs (shipping bills, invoices, BoL, any tabular documents) and get clean, structured CSV output. 

**backend** extracts tables using pdfplumber. **frontend** displays results and downloads CSV. zero AI API costs. no gemini, no openai — pure python pdf parsing.

---

## architecture

```
Frontend (Cloudflare Pages)
  → uploads PDF via POST
  → displays preview table
  → downloads CSV

Backend (Railway - Python FastAPI)
  → receives PDF
  → extracts tables with pdfplumber
  → returns structured JSON
  → falls back to text pattern matching if no tables
```

---

## quick start

### 1. deploy backend to railway

```bash
cd backend
git init
git add .
git commit -m "initial commit"
git remote add origin https://github.com/yourusername/pdfduck-backend.git
git push -u origin main
```

then:

1. go to [railway.app](https://railway.app) → **New Project** → **Deploy from GitHub**
2. select your repo → railway auto-deploys
3. **Settings** → **Networking** → **Generate Domain**
4. copy the URL (e.g., `pdfduck-backend-production.up.railway.app`)

see `backend/README.md` for detailed deployment instructions.

### 2. deploy frontend to cloudflare pages

**Important:** Your Railway backend URL is injected as an environment variable during build. This keeps it private.

1. push frontend files (including `build.sh`) to github
2. go to [pages.cloudflare.com](https://pages.cloudflare.com)
3. **Create project** → **Connect to Git** → select your repo
4. build settings:
   - **Build command:** `bash build.sh`
   - **Build output directory:** `/`
5. after first deploy, go to **Settings** → **Environment variables**
6. add variable:
   - **Name:** `BACKEND_URL`
   - **Value:** `https://your-pdfduck-backend.up.railway.app` (your Railway URL)
   - **Environment:** Production
7. **Deployments** → **Retry deployment**

see `DEPLOYMENT.md` for detailed Cloudflare Pages setup.

---

## why environment variables?

Your Railway backend URL is kept secret via Cloudflare Pages environment variables. This means:

- ✓ backend URL never appears in public repo
- ✓ only your deployed site has the real URL
- ✓ people who clone the repo can't abuse your Railway instance
- ✓ you can change the backend URL without touching code

---

## how it works

**extraction logic:**

1. **pdfplumber** opens the PDF and scans for tables
2. first row of each table = column headers
3. remaining rows = data rows
4. all rows from all tables are merged into a single JSON array
5. if no tables found, it falls back to regex pattern matching for common fields:
   - invoice number, date, amounts, consignee, shipper, email, phone, etc.
6. if still minimal data, it extracts line-by-line (useful for resumes, general docs)

**what works best:**

- PDFs with clear tabular structure (bordered or grid-based tables)
- invoices, shipping bills, BoL with line-item tables
- multi-page documents with consistent table formats

**what doesn't work:**

- heavily scanned/skewed PDFs (poor OCR quality)
- PDFs with complex multi-column layouts that aren't tables
- pure image PDFs without embedded text

---

## project structure

```
.
├── backend/
│   ├── main.py              # FastAPI app
│   ├── requirements.txt     # Python deps
│   ├── Procfile             # Railway start command (optional)
│   ├── railway.json         # Railway config
│   └── README.md            # Backend deployment guide
│
├── index.html               # Frontend (Cloudflare Pages)
├── favicon.ico              # Icon
├── build.sh                 # Cloudflare Pages build script (injects env vars)
├── DEPLOYMENT.md            # Cloudflare Pages deployment guide
└── README.md                # This file
```

---

## features

✓ bulk upload (multiple PDFs at once)  
✓ per-file status tracking (pending → reading → done/error)  
✓ live progress bar  
✓ preview table before download  
✓ CSV generation (client-side, zero server storage)  
✓ copy to clipboard  
✓ mobile responsive  
✓ no AI API costs — pure PDF parsing  
✓ secure backend URL via environment variables  

---

## costs

**railway free tier:**
- 500 hours/month
- $5 credit/month
- enough for internal tooling processing hundreds of PDFs/day

**cloudflare pages:**
- unlimited bandwidth
- unlimited requests
- free forever

**total cost: $0 for typical internal use.**

---

## local development

### backend

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
# runs on http://localhost:8000
```

### frontend

just open `index.html` in a browser.

**to test with local backend:**

edit `index.html` line 318:

```javascript
const API_URL = typeof BACKEND_URL !== 'undefined' ? BACKEND_URL : 'http://localhost:8000';
```

then open `index.html` — it will hit your local backend.

---

## api reference

### POST /extract

upload a PDF, get structured JSON back.

**request:**

```bash
curl -X POST http://your-backend/extract \
  -F "file=@document.pdf"
```

**response (success - tables found):**

```json
{
  "success": true,
  "method": "table_extraction",
  "rows": 15,
  "data": [
    {
      "item": "Widget A",
      "quantity": "100",
      "price": "50.00",
      "_source_page": 1,
      "_source_table": 1,
      "_source_row": 1
    }
  ]
}
```

**response (success - text extraction):**

```json
{
  "success": true,
  "method": "text_extraction",
  "rows": 1,
  "data": [
    {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1-555-0100",
      "line_1": "Software Engineer",
      "_full_text": "...",
      "_text_length": 1523
    }
  ]
}
```

---

## security notes

- backend URL is injected during build, never committed to repo
- for additional security, add rate limiting via Railway or Cloudflare Workers
- Railway backends are public by default — consider adding auth headers if needed

---

## upgrading to AI extraction

if you want smarter extraction (handles messy PDFs, understands context, better field mapping), you can swap pdfplumber for:

- **anthropic claude** (most accurate, ~$0.50 per 1000 pages)
- **openai gpt-4o** (similar pricing, slightly worse on tables)
- **ollama + llama** (free, runs locally on railway, slower and less accurate)

just replace the extraction logic in `backend/main.py`. the frontend stays the same.

---

## contributing

open source. do what you want. PRs welcome.

---

## license

mit