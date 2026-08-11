from app.legal_pages import (
    PRIVACY_CONTACT_EMAIL,
    PRIVACY_POLICY_EFFECTIVE_DATE,
    privacy_policy_html,
)


def test_privacy_policy_is_public_document_ready() -> None:
    page = privacy_policy_html()

    assert '<html lang="pt-BR">' in page
    assert "Política de Privacidade" in page
    assert PRIVACY_POLICY_EFFECTIVE_DATE in page
    assert PRIVACY_CONTACT_EMAIL in page
    assert "Lei Geral de Proteção de Dados Pessoais (LGPD)" in page
    assert "Google Play" in page
    assert "Mercado Pago" in page
    assert "exclusão da conta" in page
    assert "18 anos ou mais" in page


def test_privacy_policy_does_not_claim_data_sale() -> None:
    page = privacy_policy_html()

    assert "não vende dados pessoais" in page
    assert "número completo do cartão" in page
