from app.prescription_pdf import generate_prescription_pdf

def test_generates_pdf_with_draft_warning() -> None:
    content = generate_prescription_pdf({
        "publicId":"00000000-0000-0000-0000-000000000001", "version":1, "preparedAt":"03/08/2026 10:00",
        "prescriber":{"name":"Dra. Teste","crmvUf":"AM","crmvNumber":"1234","phone":"","address":""},
        "patient":{"name":"Pet","species":"Canina","breed":"SRD","sex":"Fêmea","weight":"10 kg"},
        "owner":{"name":"Responsável","address":"Manaus/AM"},
        "items":[{"medication":"Teste","concentration":"10 mg","form":"Comprimido","quantity":"10","dose":"1","route":"Oral","frequency":"12/12 h","duration":"5 dias","notes":""}],
        "instructions":"Retornar se necessário."
    }, "https://aumiau.app.br/prescriptions/verify/example?token=secret")
    assert content.startswith(b"%PDF-")
    assert len(content) > 2_000
