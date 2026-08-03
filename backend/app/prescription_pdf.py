from __future__ import annotations

import io
from typing import Any

import qrcode
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import Image, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

FOREST = colors.HexColor("#1E4D40")
MANGO = colors.HexColor("#FFB627")
MUTED = colors.HexColor("#6B7A73")
PAPER = colors.HexColor("#FBF9F4")

def _safe(value: object) -> str:
    return str(value or "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def generate_prescription_pdf(data: dict[str, Any], verification_url: str) -> bytes:
    output = io.BytesIO()
    document = SimpleDocTemplate(output, pagesize=A4, rightMargin=18*mm, leftMargin=18*mm, topMargin=16*mm, bottomMargin=16*mm, title="Receituário veterinário AuMiau", author=str(data["prescriber"].get("name", "AuMiau")))
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name="AuTitle", parent=styles["Title"], textColor=FOREST, fontSize=19, leading=23))
    styles.add(ParagraphStyle(name="AuHeading", parent=styles["Heading2"], textColor=FOREST, fontSize=11, leading=14, spaceBefore=7, spaceAfter=4))
    styles.add(ParagraphStyle(name="AuSmall", parent=styles["BodyText"], textColor=MUTED, fontSize=8, leading=10))
    styles.add(ParagraphStyle(name="Watermark", parent=styles["Heading1"], textColor=colors.HexColor("#B42318"), alignment=TA_CENTER, fontSize=13, leading=16, backColor=colors.HexColor("#FEE4E2"), borderPadding=7))
    prescriber, patient, owner = data["prescriber"], data["patient"], data["owner"]
    story: list[Any] = [
        Paragraph("AuMiau — Receituário veterinário", styles["AuTitle"]),
        Paragraph("RASCUNHO — SEM VALIDADE PARA DISPENSAÇÃO", styles["Watermark"]),
        Spacer(1, 6*mm),
        Paragraph("Profissional responsável", styles["AuHeading"]),
        Paragraph(f"<b>{_safe(prescriber.get('name'))}</b><br/>CRMV-{_safe(prescriber.get('crmvUf'))} {_safe(prescriber.get('crmvNumber'))}<br/>{_safe(prescriber.get('phone'))} · {_safe(prescriber.get('address'))}", styles["BodyText"]),
        Paragraph("Paciente e responsável", styles["AuHeading"]),
        Paragraph(f"Paciente: <b>{_safe(patient.get('name'))}</b> · Espécie: {_safe(patient.get('species'))} · Raça: {_safe(patient.get('breed'))} · Sexo: {_safe(patient.get('sex'))} · Peso: {_safe(patient.get('weight'))}<br/>Responsável: <b>{_safe(owner.get('name'))}</b> · {_safe(owner.get('address'))}", styles["BodyText"]),
        Paragraph("Prescrição", styles["AuHeading"]),
    ]
    rows = [["Medicamento", "Posologia e orientações"]]
    for item in data["items"]:
        medicine = f"<b>{_safe(item['medication'])}</b><br/>{_safe(item['concentration'])} · {_safe(item['form'])}<br/>Quantidade: {_safe(item['quantity'])}"
        directions = f"Dose: {_safe(item['dose'])}<br/>Via: {_safe(item['route'])}<br/>Frequência: {_safe(item['frequency'])}<br/>Duração: {_safe(item['duration'])}"
        if item.get("notes"): directions += f"<br/>Observações: {_safe(item['notes'])}"
        rows.append([Paragraph(medicine, styles["BodyText"]), Paragraph(directions, styles["BodyText"])])
    table = Table(rows, colWidths=[68*mm, 100*mm], repeatRows=1)
    table.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),FOREST),("TEXTCOLOR",(0,0),(-1,0),colors.white),("FONTNAME",(0,0),(-1,0),"Helvetica-Bold"),("GRID",(0,0),(-1,-1),.35,colors.HexColor("#D6DED9")),("VALIGN",(0,0),(-1,-1),"TOP"),("BACKGROUND",(0,1),(-1,-1),PAPER),("LEFTPADDING",(0,0),(-1,-1),7),("RIGHTPADDING",(0,0),(-1,-1),7),("TOPPADDING",(0,0),(-1,-1),6),("BOTTOMPADDING",(0,0),(-1,-1),6)]))
    story.append(table)
    if data.get("instructions"):
        story.extend([Paragraph("Orientações adicionais", styles["AuHeading"]), Paragraph(_safe(data["instructions"]), styles["BodyText"])])
    qr_buffer = io.BytesIO(); qrcode.make(verification_url).save(qr_buffer, format="PNG"); qr_buffer.seek(0)
    verification = Table([[Image(qr_buffer, width=30*mm, height=30*mm), Paragraph(f"Documento nº {_safe(data['publicId'])}<br/>Versão {_safe(data['version'])}<br/>Preparado em {_safe(data['preparedAt'])}<br/><br/>Consulte o QR Code para verificar o estado. Este arquivo não possui assinatura eletrônica e não é válido para dispensação.", styles["AuSmall"])]], colWidths=[36*mm,132*mm])
    verification.setStyle(TableStyle([("VALIGN",(0,0),(-1,-1),"MIDDLE"),("BOX",(0,0),(-1,-1),.5,MANGO),("BACKGROUND",(0,0),(-1,-1),colors.white)]))
    story.extend([Spacer(1,8*mm), verification])
    document.build(story)
    return output.getvalue()
