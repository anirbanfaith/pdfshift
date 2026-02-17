# pdfshift

> bulk pdf → structured csv. runs entirely in your browser.

---

## what it does

drop a pile of PDFs — shipping bills, invoices, bills of lading, whatever — and get back a clean, structured CSV file. no backend, no server, no database. everything happens in your browser tab. the only external call is to the gemini api to read and understand your documents.

---

## how it works

```
your pdfs
  → browser reads them (no upload to any server)
  → sent to gemini 1.5 flash api (google)
  → gemini extracts structured fields
  → preview table shown in browser
  → you download the csv
done.
```

---

## the gemini api key — read this

### do you need your own key?

**yes, if you're self-hosting this for yourself or your team.**

the tool has a key input in the top-right corner. every user who opens the tool needs to paste a gemini api key there. here's why, and what your options are:

---

### option 1 — everyone uses their own key (default, recommended for oss)

each person goes to [aistudio.google.com](https://aistudio.google.com), clicks **"Get API key"**, copies the key, and pastes it into the tool. takes 30 seconds. no credit card. the free tier gives you:

- 1,500 requests/day
- 15 requests/minute
- 1 million token context window (massive — handles big PDFs fine)

this is the cleanest approach for an open source tool. no one's key is exposed, no one pays for anyone else's usage.

---

### option 2 — hardcode a shared key (internal team use)

if this is strictly internal and you trust everyone who has the url, you can embed your own key directly in the html. find this line:

```html
<input type="password" id="apiKey" placeholder="AIza..." autocomplete="off" />
```

and replace the input with a hidden field that has your key pre-filled:

```html
<input type="hidden" id="apiKey" value="AIzaSy_YOUR_KEY_HERE" />
```

also remove the key input section from the header so it's not visible.

**caution:** anyone who views the page source will see the key. only do this on a password-protected internal deployment, or a cloudflare pages URL that isn't publicly shared.

---

### option 3 — cloudflare worker as a proxy (best of both worlds)

if you want zero key exposure and a seamless experience for your team (no one has to paste anything), you can put a cloudflare worker in front of the gemini api. the worker holds your key server-side and proxies the request. this is free on cloudflare's worker tier for internal usage volumes.

this is a slightly more involved setup — open an issue or ping me if you want a template for this.

---

## deploy on cloudflare pages

the entire tool is one file: `index.html`. no build step, no dependencies, no node_modules.

**option a — drag and drop (2 minutes):**

1. go to [pages.cloudflare.com](https://pages.cloudflare.com)
2. create a project → choose **"Upload assets"**
3. drag `index.html` into the upload area
4. cloudflare gives you a `*.pages.dev` url instantly

**option b — connect github (auto-deploy on push):**

1. push `index.html` to a github repo (can be private)
2. in cloudflare pages → create a project → connect to github
3. select the repo
4. build command: *(leave empty)*
5. output directory: `/` or `.`
6. deploy — cloudflare watches for new commits and redeploys automatically

---

## how to use the tool

```
1. open the deployed url
2. paste your gemini api key (top right)
3. drag and drop your pdf files into the upload zone
4. optionally edit the "fields hint" to tell gemini what columns you want
5. click "extract all →"
6. watch each file process in real time
7. preview the data table
8. click "download csv"
```

the **fields hint** input is how you control what gets extracted. examples:

```
shipping bill no, date, exporter name, consignee, port of loading, FOB value, HS code
invoice number, buyer, seller, total amount, currency, item description, quantity
bill of lading number, vessel name, container no, weight, destination port
```

if you leave it as-is, the default covers common shipping bill fields. gemini will still extract everything it finds — the hint just guides prioritization.

---

## what gemini can read

gemini 1.5 flash natively understands pdf structure — it reads the actual document, not just raw text. this means it handles:

- multi-column layouts
- tables embedded in pdfs
- scanned pdfs (with reasonable quality)
- mixed-language documents
- documents with multiple records/line items per page (each becomes a separate row)

if a field doesn't exist in a document, it returns null. multiple records in one pdf become multiple rows in the csv.

---

## privacy

- your pdfs are **not uploaded to any server run by this tool**
- pdf bytes are sent directly from your browser to google's gemini api
- google's data usage for api calls is governed by their [api terms](https://ai.google.dev/gemini-api/terms)
- if your documents are sensitive, use option 3 (worker proxy) with your own google cloud project and data residency settings

---

## self-hosting alternatives to cloudflare pages

| platform | free tier | notes |
|---|---|---|
| cloudflare pages | unlimited | best. global cdn, no bandwidth limits |
| netlify | 100gb/month | great dx, also works perfectly |
| vercel | 100gb/month | works, but free tier is for personal projects |
| github pages | unlimited | works if repo is public |

all of them: just upload `index.html`. no build config needed.

---

## local use

no server needed. just open the file:

```bash
open index.html        # macos
start index.html       # windows
xdg-open index.html    # linux
```

---

## tech stack

```
html + css + vanilla js    — no framework, no build step
jetbrains mono             — font (via google fonts)
gemini 1.5 flash api       — document understanding
native file api            — reads pdfs in browser
blob + anchor download     — csv generation without libraries
```

---

## contributing

open source, do whatever you want with it. if you build something on top of it or improve the extraction logic, a PR is welcome.

---

## license

mit