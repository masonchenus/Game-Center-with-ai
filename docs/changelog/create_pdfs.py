from fpdf import FPDF
import os

md_files = {
    "1.0.0": "1.0.0.md",
    "1.0.1": "1.0.1.md",
    "1.3.x": "1.3.x.md",
    "1.4.0": "1.4.0.md",
    "2.0.0": "2.0.0.md",
    "2.0.1": "2.0.1.md",
    "2.0.1.1": "2.0.1.1.md",
    "2.0.2": "2.0.2.md",
    "2.0.3": "2.0.3.md",
    "2.0.4": "2.0.4.md",
}

for version, md_file in md_files.items():
    if os.path.exists(md_file):
        with open(md_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        pdf = FPDF(format='Letter')
        pdf.add_page()
        pdf.set_font("Helvetica", size=8)
        pdf.set_margins(8, 8, 8)
        
        in_list = False
        for line in lines:
            line = line.rstrip('\n')
            
            # Clean special characters
            for char in ['\u2014', '\u2013', '\u2018', '\u2019', '\u201c', '\u201d', '`']:
                line = line.replace(char, '')
            
            if line.startswith('# '):
                pdf.set_font("Helvetica", "B", size=11)
                pdf.cell(0, 4, line[2:], new_y='NEXT')
                pdf.set_font("Helvetica", size=7.5)
                pdf.ln(0.3)
            elif line.startswith('## '):
                pdf.set_font("Helvetica", "B", size=9)
                pdf.cell(0, 3, line[3:], new_y='NEXT')
                pdf.set_font("Helvetica", size=7.5)
                pdf.ln(0.2)
            elif line.startswith('- ') or line.startswith('  - '):
                text = line.lstrip('- ').strip()
                if text:
                    pdf.cell(2)
                    pdf.cell(0, 2.5, '* ' + text, new_y='NEXT')
            elif line.startswith('**'):
                pdf.set_font("Helvetica", "B", size=7.5)
                pdf.cell(0, 2.5, line.replace('**', ''), new_y='NEXT')
                pdf.set_font("Helvetica", size=7.5)
            elif line.strip():
                try:
                    pdf.multi_cell(0, 2.5, line.strip())
                except Exception:
                    # Skip lines that can't be rendered
                    pass
            # Skip blank lines completely
        
        pdf_file = f"{version}.pdf"
        pdf.output(pdf_file)
        print(f"OK {pdf_file} ({os.path.getsize(pdf_file)} bytes)")

print("Done!")
