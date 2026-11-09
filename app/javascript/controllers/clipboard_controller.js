import { Controller } from "@hotwired/stimulus"
// Copia o texto de data-clipboard-text para a área de transferência,
// mostrando um feedback rápido ("Copiado!") no botão.
export default class extends Controller {
    static values = { text: String }

    async copy() {
        try {
            await navigator.clipboard.writeText(this.textValue)
            const textoOriginal = this.element.textContent
            this.element.textContent = "Copiado!"
            setTimeout(() => { this.element.textContent = textoOriginal }, 1500)
        } catch (erro) {
            console.error("Não foi possível copiar", erro)
        }
    }
}
