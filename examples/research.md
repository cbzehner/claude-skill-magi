# Research Example: Node.js PDF Library

## Request

"Best Node.js PDF library for generating invoices?"

## Query Advisors

For research, Gemini's web search is most valuable:

```bash
gemini "Topic: Node.js PDF generation libraries 2025
Context: Generating invoices and reports, need tables and styling
Provide: 1) Key findings 2) Sources 3) Applicability 4) Caveats" --sandbox -o text
```

Optionally query others for implementation patterns:

```bash
codex exec --sandbox read-only --skip-git-repo-check -- "Topic: Node.js PDF generation for invoices
Context: Need tables, headers, footers, styling
Provide: 1) Key findings 2) Sources 3) Applicability 4) Caveats"
```

## Advisor Responses

**Gemini** (primary for research):
- **PDFKit**: Low-level, programmatic control, good for custom layouts
- **Puppeteer/Playwright**: HTML-to-PDF, use existing CSS, heavier runtime
- **jsPDF**: Client-side capable, lighter weight
- **pdfmake**: Declarative, good table support
- Sources: npm trends, GitHub stars, recent blog comparisons

**Codex**:
- For invoices, recommends pdfmake (declarative table syntax)
- PDFKit for custom graphics/charts
- Consider HTML template + Puppeteer for complex styling

**Claude**:
- pdfmake best for structured data like invoices
- Watch for memory with large PDFs - stream if >100 pages
- Consider accessibility: tagged PDFs for compliance

## Synthesis

**Pattern**: Complementary

**Decision**:
- **Simple invoices**: pdfmake (declarative, great tables)
- **Complex styling**: Puppeteer + HTML template (reuse CSS)
- **Custom graphics**: PDFKit (full control)

**Reasoning**: Gemini provided current landscape; Codex added practical patterns; Claude flagged memory and accessibility concerns. Choice depends on invoice complexity.

## Result

Recommended pdfmake for the invoice use case:

```javascript
const pdfMake = require('pdfmake');

const invoice = {
  content: [
    { text: 'Invoice #1234', style: 'header' },
    {
      table: {
        body: [
          ['Item', 'Qty', 'Price'],
          ['Widget', '2', '$50.00'],
        ]
      }
    }
  ]
};
```
